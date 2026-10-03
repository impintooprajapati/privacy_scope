import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:privacy_scope/privacy_scope.dart';

/// A live debug HUD overlay that displays the currently active privacy state,
/// platform, and scope stack.
class PrivacyDebugPanel extends StatefulWidget {
  const PrivacyDebugPanel({super.key});

  @override
  State<PrivacyDebugPanel> createState() => _PrivacyDebugPanelState();
}

class _PrivacyDebugPanelState extends State<PrivacyDebugPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final controller = PrivacyController.instance;

    return StreamBuilder<PrivacyEvent>(
      stream: controller.events,
      builder: (context, _) {
        final state = controller.state;
        final policy = state.activePolicy;
        final registrations = controller.activeRegistrations;

        final platformName = kIsWeb
            ? 'Web'
            : Platform.isAndroid
                ? 'Android'
                : Platform.isIOS
                    ? 'iOS'
                    : Platform.operatingSystem;

        final theme = Theme.of(context);

        return Card(
          margin: const EdgeInsets.all(12),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: policy.hasRestrictions
                  ? Colors.redAccent.withValues(alpha: 0.5)
                  : Colors.greenAccent.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Row(
                    children: [
                      Icon(
                        policy.hasRestrictions
                            ? Icons.security
                            : Icons.lock_open,
                        color: policy.hasRestrictions
                            ? Colors.redAccent
                            : Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Privacy HUD ($platformName)',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: policy.hasRestrictions
                              ? Colors.red.withValues(alpha: 0.12)
                              : Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          policy.hasRestrictions ? 'PROTECTED' : 'STANDARD',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: policy.hasRestrictions
                                ? Colors.redAccent
                                : Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                if (_expanded) ...[
                  const Divider(height: 20),
                  _buildRow('Screenshots', policy.screenshot.name.toUpperCase(),
                      policy.screenshot == ScreenshotPolicy.block),
                  _buildRow('App Switcher',
                      policy.appSwitcher.name.toUpperCase(),
                      policy.appSwitcher != AppSwitcherPolicy.allow),
                  _buildRow(
                      'Screen Capture Detected',
                      state.isCaptured ? 'YES (Active)' : 'No',
                      state.isCaptured),
                  _buildRow(
                    'Active Scopes in Stack',
                    '${registrations.length} registered',
                    false,
                  ),
                  if (registrations.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Scope Stack (depth / label):',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    ...registrations.map(
                      (reg) => Padding(
                        padding: const EdgeInsets.only(left: 8, top: 2),
                        child: Text(
                          '• [d=${reg.depth}, seq=${reg.sequence}] ${reg.debugLabel ?? reg.id}: ${reg.policy}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.refresh, size: 14),
                      label: const Text('Re-sync Platform'),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => controller.refresh(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String value, bool isHighlighted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.redAccent : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
