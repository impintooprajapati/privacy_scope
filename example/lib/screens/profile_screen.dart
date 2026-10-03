import 'package:flutter/material.dart';
import 'package:privacy_scope/privacy_scope.dart';
import '../widgets/privacy_debug_panel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrivacyScope(
      policy: const PrivacyPolicy(
        screenshot: ScreenshotPolicy.allow,
        appSwitcher: AppSwitcherPolicy.blur,
      ),
      debugLabel: 'ProfileScreen (Blur AppSwitcher)',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Profile'),
        ),
        bottomNavigationBar: const PrivacyDebugPanel(),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.blur_on, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'App Switcher Blur Active\nScreenshots are allowed, but leaving the app obscures this screen in the app switcher.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.indigo,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.verified, size: 20, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Alex Morgan',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const Center(
              child: Text(
                'Product Security Lead (Demo Profile)',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            const Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.email_outlined),
                    title: Text('Email (Demo)'),
                    subtitle: Text('alex.morgan@company.internal'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.phone_outlined),
                    title: Text('Phone (Demo)'),
                    subtitle: Text('+1 (555) 019-2834'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.location_on_outlined),
                    title: Text('Location'),
                    subtitle: Text('San Francisco, CA'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Home (Restores Standard Policy)'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
