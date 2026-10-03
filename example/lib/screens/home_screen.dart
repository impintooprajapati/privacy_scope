import 'package:flutter/material.dart';
import 'package:privacy_scope/privacy_scope.dart';
import '../widgets/privacy_debug_panel.dart';
import 'payment_screen.dart';
import 'private_notes_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrivacyScope(
      policy: const PrivacyPolicy.standard(),
      debugLabel: 'HomeScreen (Standard)',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PrivacyScope Demo'),
          elevation: 0,
        ),
        bottomNavigationBar: const PrivacyDebugPanel(),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Standard Policy Active',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No privacy restrictions are active on this screen. Screenshots and standard app switcher previews are permitted.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select a Demo Scenario:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDemoTile(
              context,
              icon: Icons.person_outline,
              title: '1. Profile Screen',
              subtitle: 'App switcher blurred; screenshots allowed.',
              policyTag: 'AppSwitcher: Blur',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildDemoTile(
              context,
              icon: Icons.credit_card,
              title: '2. Payment & Checkout',
              subtitle:
                  'Screenshots blocked on Android; App switcher hidden on iOS & Android.',
              policyTag: 'Screenshots: Block, Switcher: Hide',
              color: Colors.deepPurple,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PaymentScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildDemoTile(
              context,
              icon: Icons.lock_outline,
              title: '3. Private Notes & Vault',
              subtitle:
                  'PrivacyPolicy.strict() + nested scope for sensitive secret vault.',
              policyTag: 'PrivacyPolicy.strict() + Nested',
              color: Colors.teal,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PrivateNotesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String policyTag,
    required VoidCallback onTap,
    Color color = Colors.indigo,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                policyTag,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
