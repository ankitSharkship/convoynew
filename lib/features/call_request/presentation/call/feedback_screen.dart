import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/call_request_entity.dart';
import 'call_screen_registry.dart';
import 'satisfaction_prompt.dart';

/// The satisfaction question as a screen of its own: for a call that ended
/// while the person was away from the call screen, or a question put off with
/// "Decide later".
class FeedbackScreen extends ConsumerStatefulWidget {
  final CallRequestEntity request;

  const FeedbackScreen({super.key, required this.request});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  late final CallScreenRegistry _registry;

  @override
  void initState() {
    super.initState();
    _registry = ref.read(callScreenRegistryProvider)
      ..enter(widget.request.id, live: false);
  }

  @override
  void dispose() {
    _registry.leave(widget.request.id, live: false);
    super.dispose();
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: SatisfactionPrompt(
                request: widget.request,
                onLater: _leave,
                onDone: _leave,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
