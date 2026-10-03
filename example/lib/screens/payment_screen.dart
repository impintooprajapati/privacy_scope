import 'package:flutter/material.dart';
import 'package:privacy_scope/privacy_scope.dart';
import '../widgets/privacy_debug_panel.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrivacyScope(
      policy: const PrivacyPolicy(
        screenshot: ScreenshotPolicy.block,
        appSwitcher: AppSwitcherPolicy.hide,
      ),
      debugLabel: 'PaymentScreen (Strict Protection)',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Checkout & Payment'),
          backgroundColor: Colors.deepPurple.shade700,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBar: const PrivacyDebugPanel(),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'High Security Policy Active\n• Android: Screenshots & recordings blocked.\n• iOS: App-switcher preview masked; capture events detected.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Dummy Credit Card Card
            Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DEMO VAULT CARD',
                        style: TextStyle(
                          color: Colors.white70,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.contactless, color: Colors.white70),
                    ],
                  ),
                  Text(
                    '4532 •••• •••• 8842',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 3,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CARDHOLDER (DEMO)',
                              style: TextStyle(color: Colors.white54, fontSize: 10)),
                          Text('JANE DOE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EXPIRES',
                              style: TextStyle(color: Colors.white54, fontSize: 10)),
                          Text('12/28',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CVV (DEMO)',
                              style: TextStyle(color: Colors.white54, fontSize: 10)),
                          Text('942',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Amount Due:'),
                        Text('\$149.00 USD',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Bank Account:'),
                        Text('Chase Premier Checking (••9102)'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment processed safely!')),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Complete Payment & Return'),
            ),
          ],
        ),
      ),
    );
  }
}
