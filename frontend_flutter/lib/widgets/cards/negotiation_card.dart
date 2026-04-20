import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NegotiationCard extends StatelessWidget {
  const NegotiationCard({
    super.key,
    required this.tips,
  });

  final List<String> tips;

  String _buildScript() {
    final selected = tips.take(3).toList();
    if (selected.isEmpty) return '';
    return selected
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Negotiation Coach',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  final script = _buildScript();
                  if (script.isEmpty) return;
                  await Clipboard.setData(ClipboardData(text: script));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Negotiation script copied.')),
                    );
                  }
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy Script'),
              ),
            ),
            ...tips.take(3).map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Icon(Icons.circle, size: 7),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(tip)),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
