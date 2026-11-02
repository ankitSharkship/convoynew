import AVFoundation
import CallKit
import Flutter
import PushKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Must be set up before launch finishes: when a call wakes a closed phone, iOS
    // delivers the VoIP push here, possibly long before Flutter is running.
    CallKitBridge.shared.start()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let messenger = engineBridge.pluginRegistry.registrar(forPlugin: "ConvoyCallKit")?.messenger() {
      CallKitBridge.shared.connect(messenger: messenger)
    }
  }
}

/// The iPhone's incoming-call screen for paid 1:1 calls (CallKit), fed by VoIP pushes (PushKit).
///
/// Self-contained on purpose. iOS requires every VoIP push to be reported to CallKit *immediately*,
/// and an app that doesn't gets terminated and eventually stops receiving VoIP pushes. So this class
/// reports the call itself, with no dependence on Flutter being up. What the person does with the call
/// (answer, decline, end, time out) is queued here and handed to Dart as soon as it attaches
/// (`attach` on the "convoy/callkit" channel), so an answer given while the app was closed is not lost.
///
/// The call's UUID is the call request's id (the backend sends it as `requestId`).
final class CallKitBridge: NSObject, PKPushRegistryDelegate, CXProviderDelegate {
  static let shared = CallKitBridge()

  private struct ActiveCall {
    let requestId: String
    var answered = false
    var timeout: DispatchWorkItem?
  }

  private let provider: CXProvider
  private var registry: PKPushRegistry?
  private var channel: FlutterMethodChannel?
  private var attached = false
  private var voipToken: String?
  private var pendingEvents: [[String: String]] = []
  private var pendingToken: String?
  private var calls: [UUID: ActiveCall] = [:]

  /// Used when a push does not say how long the ring lasts.
  private let defaultRingSeconds: TimeInterval = 45

  private override init() {
    let configuration = CXProviderConfiguration()
    configuration.supportsVideo = false  // the person called sends only a microphone
    configuration.maximumCallGroups = 1
    configuration.maximumCallsPerCallGroup = 1
    configuration.supportedHandleTypes = [.generic]
    configuration.includesCallsInRecents = false
    provider = CXProvider(configuration: configuration)
    super.init()
    provider.setDelegate(self, queue: .main)
  }

  // MARK: Setup

  /// Asks iOS for VoIP pushes. Idempotent.
  func start() {
    guard registry == nil else { return }
    let registry = PKPushRegistry(queue: .main)
    registry.delegate = self
    registry.desiredPushTypes = [.voIP]
    self.registry = registry
  }

  /// Hooks up the Dart side. Nothing is sent to Dart until it calls `attach`.
  func connect(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "convoy/callkit", binaryMessenger: messenger)
    self.channel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    switch call.method {
    case "attach":
      attached = true
      if let token = pendingToken {
        channel?.invokeMethod("voipToken", arguments: token)
        pendingToken = nil
      }
      let queued = pendingEvents
      pendingEvents.removeAll()
      for event in queued { channel?.invokeMethod("event", arguments: event) }
      result(nil)
    case "voipToken":
      result(voipToken)
    case "pushEnvironment":
      result(Self.pushEnvironment())
    case "show":
      let id = args?["requestId"] as? String ?? ""
      let name = args?["callerName"] as? String ?? "Incoming call"
      let topic = args?["topic"] as? String ?? ""
      var ringEnds: Date?
      if let ms = args?["ringEndsAtMs"] as? Double { ringEnds = Date(timeIntervalSince1970: ms / 1000) }
      if let ms = args?["ringEndsAtMs"] as? Int { ringEnds = Date(timeIntervalSince1970: Double(ms) / 1000) }
      report(requestId: id, callerName: name, topic: topic, ringEndsAt: ringEnds, completion: nil)
      result(nil)
    case "end":
      end(requestId: args?["requestId"] as? String ?? "")
      result(nil)
    case "connected":
      result(nil)  // an answered CallKit call is already shown as ongoing
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func emit(_ type: String, _ requestId: String) {
    let event = ["type": type, "requestId": requestId]
    if attached {
      channel?.invokeMethod("event", arguments: event)
    } else if pendingEvents.count < 20 {
      pendingEvents.append(event)
    }
  }

  // MARK: Reporting calls

  /// Shows the system call screen. Calls [completion] once CallKit has been told, which is what
  /// PushKit's completion handler must wait for.
  private func report(
    requestId: String, callerName: String, topic: String, ringEndsAt: Date?, completion: (() -> Void)?
  ) {
    // A push with a request id that is not a UUID still has to be reported (iOS demands it), then dropped.
    let parsed = UUID(uuidString: requestId)
    let uuid = parsed ?? UUID()

    let update = CXCallUpdate()
    update.remoteHandle = CXHandle(type: .generic, value: topic.isEmpty ? callerName : topic)
    update.localizedCallerName = callerName
    update.hasVideo = false
    update.supportsHolding = false
    update.supportsGrouping = false
    update.supportsUngrouping = false
    update.supportsDTMF = false

    calls[uuid] = ActiveCall(requestId: parsed == nil ? "" : requestId)
    provider.reportNewIncomingCall(with: uuid, update: update) { [weak self] error in
      DispatchQueue.main.async {
        guard let self = self else {
          completion?()
          return
        }
        if error != nil {
          // Filtered by Do Not Disturb, or this call is already being shown (a repeated push).
          if self.calls[uuid]?.answered != true { self.calls[uuid] = nil }
          completion?()
          return
        }
        let remaining = ringEndsAt?.timeIntervalSinceNow ?? self.defaultRingSeconds
        if parsed == nil || remaining <= 0 {
          // Nobody can still answer (or the push was malformed): it had to be shown, now take it down.
          self.finish(uuid, reason: .unanswered, event: parsed == nil ? nil : "timedOut")
        } else {
          self.emit("shown", requestId)
          let work = DispatchWorkItem { [weak self] in
            guard let self = self, self.calls[uuid]?.answered == false else { return }
            self.finish(uuid, reason: .unanswered, event: "timedOut")
          }
          self.calls[uuid]?.timeout = work
          DispatchQueue.main.asyncAfter(deadline: .now() + remaining, execute: work)
        }
        completion?()
      }
    }
  }

  /// Ends a call from our side (the system is told; it does not call back with an end action).
  private func finish(_ uuid: UUID, reason: CXCallEndedReason, event: String?) {
    guard let call = calls.removeValue(forKey: uuid) else { return }
    call.timeout?.cancel()
    provider.reportCall(with: uuid, endedAt: Date(), reason: reason)
    if let event = event, !call.requestId.isEmpty { emit(event, call.requestId) }
  }

  /// Dart says the call is over (finished, the driver hung up, ...).
  private func end(requestId: String) {
    guard !requestId.isEmpty,
      let uuid = calls.first(where: { $0.value.requestId == requestId })?.key
    else { return }
    finish(uuid, reason: .remoteEnded, event: nil)
  }

  // MARK: PKPushRegistryDelegate

  func pushRegistry(
    _ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType
  ) {
    guard type == .voIP else { return }
    let token = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
    voipToken = token
    if attached {
      channel?.invokeMethod("voipToken", arguments: token)
    } else {
      pendingToken = token
    }
  }

  func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    if type == .voIP { voipToken = nil }
  }

  func pushRegistry(
    _ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload,
    for type: PKPushType, completion: @escaping () -> Void
  ) {
    guard type == .voIP else {
      completion()
      return
    }
    let data = payload.dictionaryPayload
    var ringEnds: Date?
    if let text = data["ringEndsAt"] as? String {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      ringEnds = formatter.date(from: text)
      if ringEnds == nil {
        formatter.formatOptions = [.withInternetDateTime]
        ringEnds = formatter.date(from: text)
      }
    }
    report(
      requestId: data["requestId"] as? String ?? "",
      callerName: data["callerName"] as? String ?? "Incoming call",
      topic: data["topic"] as? String ?? "",
      ringEndsAt: ringEnds,
      completion: completion)
  }

  // MARK: CXProviderDelegate

  func providerDidReset(_ provider: CXProvider) {
    for (_, call) in calls { call.timeout?.cancel() }
    calls.removeAll()
  }

  func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
    guard var call = calls[action.callUUID] else {
      action.fail()
      return
    }
    call.answered = true
    call.timeout?.cancel()
    call.timeout = nil
    calls[action.callUUID] = call
    if !call.requestId.isEmpty { emit("accepted", call.requestId) }
    action.fulfill()
  }

  func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
    if let call = calls.removeValue(forKey: action.callUUID) {
      call.timeout?.cancel()
      // Before answering this is "Decline"; after answering it is the system's own hang-up.
      if !call.requestId.isEmpty { emit(call.answered ? "ended" : "declined", call.requestId) }
    }
    action.fulfill()
  }

  func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
    action.fulfill()  // the app's own mute button drives the microphone
  }

  func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {}

  func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {}

  // MARK: Helpers

  /// Which Apple push server this install's VoIP token belongs to. Installs from Xcode carry a
  /// development provisioning profile ("sandbox"); TestFlight and App Store installs carry none
  /// ("production").
  private static func pushEnvironment() -> String {
    guard let path = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision"),
      let data = FileManager.default.contents(atPath: path),
      let text = String(data: data, encoding: .isoLatin1),
      let key = text.range(of: "<key>aps-environment</key>")
    else { return "production" }
    let after = text[key.upperBound...].prefix(80)
    return after.contains("development") ? "sandbox" : "production"
  }
}
