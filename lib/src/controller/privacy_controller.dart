import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/privacy_event.dart';
import '../core/privacy_policy.dart';
import '../core/privacy_state.dart';
import '../platform/privacy_platform.dart';
import '../platform/privacy_platform_event.dart';
import 'scope_registration.dart';

/// Central controller that coordinates active privacy scopes, resolves effective
/// policies, and updates the native platform.
class PrivacyController {
  static PrivacyController? _instance;

  /// The active singleton instance of [PrivacyController].
  static PrivacyController get instance => _instance ??= PrivacyController();

  /// Sets the active singleton instance of [PrivacyController] (primarily for testing).
  static set instance(PrivacyController? customInstance) {
    _instance = customInstance;
  }

  final PrivacyPlatform _platform;
  final StreamController<PrivacyEvent> _eventController =
      StreamController<PrivacyEvent>.broadcast();

  final List<ScopeRegistration> _registrations = [];
  int _sequenceCounter = 0;
  int _idCounter = 0;

  PrivacyState _state = const PrivacyState.initial();
  StreamSubscription<PrivacyPlatformEvent>? _platformSub;

  /// Creates a new [PrivacyController] with an optional custom [PrivacyPlatform].
  PrivacyController({PrivacyPlatform? platform})
      : _platform = platform ?? PrivacyPlatform.instance {
    _initPlatformListener();
  }

  void _initPlatformListener() {
    _platformSub = _platform.events.listen((event) {
      switch (event) {
        case PlatformScreenCaptureStarted():
          _state = _state.copyWith(isCaptured: true);
          _eventController.add(const ScreenCaptureDetected());
          _eventController.add(const ScreenCaptureStarted());
        case PlatformScreenCaptureStopped():
          _state = _state.copyWith(isCaptured: false);
          _eventController.add(const ScreenCaptureStopped());
      }
    });
  }

  /// The current resolved [PrivacyState].
  PrivacyState get state => _state;

  /// Stream of privacy-related events such as policy changes and screen recording alerts.
  Stream<PrivacyEvent> get events => _eventController.stream;

  /// Unmodifiable view of currently registered scopes.
  List<ScopeRegistration> get activeRegistrations =>
      List.unmodifiable(_registrations);

  /// Registers a new scope token and re-evaluates the effective policy.
  ScopeRegistration registerScope({
    required PrivacyPolicy policy,
    int depth = 0,
    String? debugLabel,
  }) {
    final registration = ScopeRegistration(
      id: 'scope_${++_idCounter}',
      depth: depth,
      sequence: ++_sequenceCounter,
      policy: policy,
      debugLabel: debugLabel,
    );

    _registrations.add(registration);
    _recomputeEffectivePolicy();
    return registration;
  }

  /// Updates the policy for an existing [ScopeRegistration] and re-evaluates.
  void updateScope(ScopeRegistration registration, PrivacyPolicy newPolicy) {
    if (registration.policy == newPolicy) return;
    registration.policy = newPolicy;
    _recomputeEffectivePolicy();
  }

  /// Unregisters a scope token when its widget is disposed.
  void unregisterScope(ScopeRegistration registration) {
    final removed = _registrations.remove(registration);
    if (removed) {
      _recomputeEffectivePolicy();
    }
  }

  /// Resolves the highest priority active policy and applies it to the platform
  /// if it differs from the currently applied policy.
  void _recomputeEffectivePolicy() {
    final effectivePolicy = _resolveEffectivePolicy();
    final previousPolicy = _state.activePolicy;

    if (effectivePolicy == previousPolicy) {
      return;
    }

    _state = _state.copyWith(
      activePolicy: effectivePolicy,
      screenshotProtectionEnabled:
          effectivePolicy.screenshot == ScreenshotPolicy.block,
      appSwitcherPolicy: effectivePolicy.appSwitcher,
    );

    // Apply asynchronously to native platform
    _platform
        .applyPolicy(effectivePolicy)
        .catchError((Object error, StackTrace stack) {
      debugPrint(
          'PrivacyController: Failed to apply policy to native platform: $error');
    });

    _eventController.add(
      PrivacyPolicyChanged(
        previous: previousPolicy,
        current: effectivePolicy,
      ),
    );
  }

  /// Determines the effective policy by prioritizing deeper nested scopes first,
  /// then the most recently mounted scopes for ties.
  PrivacyPolicy _resolveEffectivePolicy() {
    if (_registrations.isEmpty) {
      return const PrivacyPolicy.standard();
    }

    // Sort by depth descending, then sequence descending
    final sorted = List<ScopeRegistration>.from(_registrations)
      ..sort((a, b) {
        final depthCompare = b.depth.compareTo(a.depth);
        if (depthCompare != 0) return depthCompare;
        return b.sequence.compareTo(a.sequence);
      });

    return sorted.first.policy;
  }

  /// Manually reapplies the current effective policy to the native platform.
  Future<void> refresh() async {
    final effectivePolicy = _resolveEffectivePolicy();
    await _platform.applyPolicy(effectivePolicy);
  }

  /// Cleans up resources, subscriptions, and registrations.
  void dispose() {
    _platformSub?.cancel();
    _platformSub = null;
    _eventController.close();
    _registrations.clear();
  }
}
