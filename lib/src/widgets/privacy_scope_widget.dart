import 'package:flutter/widgets.dart';
import '../controller/privacy_controller.dart';
import '../controller/scope_registration.dart';
import '../core/privacy_policy.dart';

/// An inherited widget that exposes the active [PrivacyScope] context to descendants.
class _InheritedPrivacyScope extends InheritedWidget {
  final int depth;
  final PrivacyPolicy policy;
  final ScopeRegistration? registration;

  const _InheritedPrivacyScope({
    required this.depth,
    required this.policy,
    required this.registration,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedPrivacyScope oldWidget) {
    return depth != oldWidget.depth ||
        policy != oldWidget.policy ||
        registration != oldWidget.registration;
  }
}

/// A widget that applies a [PrivacyPolicy] while it is mounted in the widget tree.
///
/// When the widget is mounted, its policy is registered with [PrivacyController].
/// When it is disposed (e.g., when navigating back from a screen), the scope is
/// unregistered, and the previous policy is automatically restored.
///
/// Nested scopes take precedence over parent scopes.
///
/// Example:
/// ```dart
/// PrivacyScope(
///   policy: PrivacyPolicy.strict(),
///   child: const PaymentScreen(),
/// )
/// ```
class PrivacyScope extends StatefulWidget {
  /// The privacy policy to enforce while this scope is mounted.
  final PrivacyPolicy policy;

  /// The widget subtree protected by this privacy scope.
  final Widget child;

  /// Optional custom controller. Defaults to [PrivacyController.instance].
  final PrivacyController? controller;

  /// Optional debug label for inspector and debugging tools.
  final String? debugLabel;

  /// Creates a [PrivacyScope].
  const PrivacyScope({
    super.key,
    required this.policy,
    required this.child,
    this.controller,
    this.debugLabel,
  });

  /// Finds the nearest [PrivacyScope] policy up the widget tree, or returns null.
  static PrivacyPolicy? maybeOf(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_InheritedPrivacyScope>();
    return inherited?.policy;
  }

  /// Finds the nearest [PrivacyScope] policy up the widget tree, or returns [PrivacyPolicy.standard].
  static PrivacyPolicy of(BuildContext context) {
    return maybeOf(context) ?? const PrivacyPolicy.standard();
  }

  @override
  State<PrivacyScope> createState() => _PrivacyScopeState();
}

class _PrivacyScopeState extends State<PrivacyScope> {
  ScopeRegistration? _registration;
  int _depth = 0;
  bool _initialized = false;

  PrivacyController get _controller =>
      widget.controller ?? PrivacyController.instance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final parentScope =
        context.dependOnInheritedWidgetOfExactType<_InheritedPrivacyScope>();
    final parentDepth = parentScope?.depth ?? -1;
    _depth = parentDepth + 1;

    if (!_initialized) {
      _registration = _controller.registerScope(
        policy: widget.policy,
        depth: _depth,
        debugLabel: widget.debugLabel,
      );
      _initialized = true;
    }
  }

  @override
  void didUpdateWidget(PrivacyScope oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_registration != null && widget.policy != oldWidget.policy) {
      _controller.updateScope(_registration!, widget.policy);
    }
  }

  @override
  void dispose() {
    if (_registration != null) {
      _controller.unregisterScope(_registration!);
      _registration = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedPrivacyScope(
      depth: _depth,
      policy: widget.policy,
      registration: _registration,
      child: widget.child,
    );
  }
}
