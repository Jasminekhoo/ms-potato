import 'package:flutter/material.dart';

import '../../widgets/layout/app_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'About AI Rent Advisor',
      child: ListView(
        children: const [
          Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What this app does',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'AI Rent Advisor helps renters in Malaysia avoid hidden rental costs and landlord risk by turning listing details and complaint signals into a clear verdict.',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Core outputs',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text('1. Rental verdict: Great Deal / Acceptable / Avoid'),
                  SizedBox(height: 6),
                  Text('2. True all-in cost including hidden fees'),
                  SizedBox(height: 6),
                  Text('3. Risk radar from review and complaint patterns'),
                  SizedBox(height: 6),
                  Text('4. Negotiation coaching points'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
