import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/property_input.dart';
import '../../providers/property_provider.dart';
import '../../widgets/forms/property_form.dart';
import '../../widgets/layout/app_scaffold.dart';

class InputScreen extends StatelessWidget {
  const InputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Rental Input',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'analysis-verdict-hero',
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F766E)
                                    .withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Running decision intelligence...',
                                style: TextStyle(
                                  color: Color(0xFF0F766E),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        PropertyForm(
                          onSubmit: (PropertyInput input) async {
                            await context
                                .read<PropertyProvider>()
                                .analyse(input);
                            if (context.mounted) {
                              context.push('/result');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (constraints.maxWidth > 900) const SizedBox(width: 14),
              if (constraints.maxWidth > 900)
                const Expanded(
                  flex: 2,
                  child: _TipPanel(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TipPanel extends StatelessWidget {
  const _TipPanel();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Tips',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            SizedBox(height: 12),
            Text(
                '1. Include exact monthly income for better affordability guidance.'),
            SizedBox(height: 8),
            Text(
                '2. Use postcode/building name to improve market benchmark matching.'),
            SizedBox(height: 8),
            Text(
                '3. Result includes hidden fee estimate and negotiation script.'),
          ],
        ),
      ),
    );
  }
}
