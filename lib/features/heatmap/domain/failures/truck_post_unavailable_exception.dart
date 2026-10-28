/// The tapped truck's post is gone — expired or removed since its pin was
/// loaded. Not a failure of the app: the pin is simply out of date.
class TruckPostUnavailableException implements Exception {
  const TruckPostUnavailableException();

  @override
  String toString() => 'This truck post is no longer available';
}
