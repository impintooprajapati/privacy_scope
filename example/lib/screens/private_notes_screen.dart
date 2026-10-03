import 'package:flutter/material.dart';
import 'package:privacy_scope/privacy_scope.dart';

import '../widgets/privacy_debug_panel.dart';

class PrivateNotesScreen extends StatefulWidget {
  const PrivateNotesScreen({super.key});

  @override
  State<PrivateNotesScreen> createState() => _PrivateNotesScreenState();
}

class _PrivateNotesScreenState extends State<PrivateNotesScreen> {
  bool _vaultUnlocked = false;

  @override
  Widget build(BuildContext context) {
    return PrivacyScope(
      policy: const PrivacyPolicy.strict(),
      debugLabel: 'PrivateNotes (Strict)',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Confidential Notes'),
          backgroundColor: Colors.teal.shade800,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBar: const PrivacyDebugPanel(),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock, color: Colors.teal),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Strict Privacy Scope Active\nDemonstrates nested scopes below. Tapping the Vault unlocks an inner PrivacyScope.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: ListTile(
                leading: Icon(Icons.note, color: Colors.teal),
                title: Text('Product Roadmap Strategy 2027'),
                subtitle: Text('Confidential internal release notes...'),
              ),
            ),
            const SizedBox(height: 8),
            const Card(
              child: ListTile(
                leading: Icon(Icons.vpn_key, color: Colors.teal),
                title: Text('API Keys Backup'),
                subtitle: Text('Master token hashes and rotating secrets...'),
              ),
            ),
            const SizedBox(height: 20),
            // Nested Scope Demonstration Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nested Vault Scope Demo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Switch(
                        value: _vaultUnlocked,
                        activeThumbColor: Colors.teal,
                        onChanged: (val) =>
                            setState(() => _vaultUnlocked = val),
                      ),
                    ],
                  ),
                  const Text(
                    'Toggle the switch to mount an inner PrivacyScope widget inside this screen. Observe how the HUD stack increments depth and priority.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  if (_vaultUnlocked)
                    PrivacyScope(
                      policy: const PrivacyPolicy(
                        screenshot: ScreenshotPolicy.block,
                        appSwitcher: AppSwitcherPolicy.hide,
                      ),
                      debugLabel: 'Inner Nested Vault Scope (Depth 1)',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade900,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.security,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'NESTED PRIVACY SCOPE MOUNTED',
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Seed Phrase (Demo):',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              'ocean velvet castle guitar timber echo lantern quantum',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
