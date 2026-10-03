import '../core/privacy_policy.dart';

/// Represents an active scope token registered with [PrivacyController].
class ScopeRegistration {
  /// Unique identifier for this scope registration.
  final String id;

  /// The hierarchical depth of this scope in the widget tree (0 for root scopes).
  final int depth;

  /// Monotonic sequence index indicating registration order (later is higher).
  final int sequence;

  /// The privacy policy associated with this scope.
  PrivacyPolicy policy;

  /// Optional label used for debugging and inspector panels.
  final String? debugLabel;

  /// Timestamp when this scope was registered.
  final DateTime registeredAt;

  /// Creates a new [ScopeRegistration].
  ScopeRegistration({
    required this.id,
    required this.depth,
    required this.sequence,
    required this.policy,
    this.debugLabel,
    DateTime? registeredAt,
  }) : registeredAt = registeredAt ?? DateTime.now();

  @override
  String toString() =>
      'ScopeRegistration(id: $id, depth: $depth, sequence: $sequence, policy: $policy, label: $debugLabel)';
}
