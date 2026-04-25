import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/utils.dart';
import '../../models/analysis_result.dart';
import '../../providers/property_provider.dart';
import '../../services/report_export_service.dart';
import '../../widgets/cards/cost_breakdown_card.dart';
import '../../widgets/cards/negotiation_card.dart';
import '../../widgets/cards/risk_radar_card.dart';
import '../../widgets/cards/source_transparency_card.dart';
import '../../widgets/cards/verdict_card.dart';
import '../../widgets/common/loading_skeleton.dart';
import '../../widgets/common/staggered_reveal.dart';
import '../../widgets/layout/app_scaffold.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PropertyProvider>();
    final isLoading = provider.isLoading;
    // Note: ensure your provider uses the getter name 'result' or 'analysisResult'
    final result = provider.result; 

    return AppScaffold(
      title: 'Analysis Result',
      child: isLoading
          ? const LoadingSkeleton()
          : result == null
              ? const _EmptyState()
              : _ResultContent(result: result),
    );
  }
}

class _ResultContent extends StatelessWidget {
  const _ResultContent({required this.result});

  final AnalysisResult result;
  static final _exportService = ReportExportService();

  String _buildExportSummary() {
    final costLines = result.hiddenCosts.entries
        .map((e) => '- ${e.key}: ${Currency.rm(e.value)}')
        .join('\n');
    final tips = result.negotiationTips
        .take(3)
        .toList()
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');
    final sources = result.sources
        .take(4)
        .map((s) => '- ${s.title}${s.url.isNotEmpty ? ' (${s.url})' : ''}')
        .join('\n');

    return '''AI Rent Advisor Report
Verdict: ${result.verdict} (${result.label})
Reason: ${result.explanation}
Suggestion: ${result.suggestion}

Listed Rent: ${Currency.rm(result.listedRent)}
True First-Year Monthly Cost: ${Currency.rm(result.trueCostMonthly)}
Hidden Costs:
$costLines

Risk Score: ${result.riskScore.toStringAsFixed(1)}/10
Risk Summary: ${result.riskSummary}

Negotiation Coach:
$tips

Confidence: ${(result.confidenceScore * 100).toStringAsFixed(0)}%
Data Freshness: ${result.dataFreshness}
Sources:
$sources
''';
  }

  @override
  Widget build(BuildContext context) {
    // Determine color based on the "label" field from your API
    final bool isDangerous = result.label.toUpperCase() == 'DANGEROUS' || result.verdict.toUpperCase() == 'AVOID';
    final themeColor = isDangerous ? const Color(0xFFB91C1C) : const Color(0xFF0F766E);
    final bgColor = themeColor.withValues(alpha: 0.10);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Hero(
          tag: 'analysis-verdict-hero',
          child: Material(
            color: Colors.transparent,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Verdict generated: ${result.verdict} • ${result.label}',
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: _buildExportSummary()),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Full analysis summary copied.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                ),
                if (kIsWeb)
                  IconButton(
                    onPressed: () async {
                      final ok = await _exportService.exportTextFile(
                        filename: 'ai_rent_advisor_report.txt',
                        content: _buildExportSummary(),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ok ? 'Report downloaded' : 'Download failed')),
                      );
                    },
                    icon: const Icon(Icons.download, size: 16),
                    tooltip: 'Download TXT',
                  ),
              ],
            ),
          ),
        ),
        StaggeredReveal(
          index: 0,
          child: VerdictCard(
            verdict: result.verdict,
            explanation: result.explanation,
            // If VerdictCard supports it, pass result.suggestion here
          ),
        ),
        if (result.suggestion.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(
              "Recommendation: ${result.suggestion}",
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey),
            ),
          ),
        const SizedBox(height: 12),
        StaggeredReveal(
          index: 1,
          child: CostBreakdownCard(
            listedRent: result.listedRent,
            trueCost: result.trueCostMonthly,
            hiddenCosts: result.hiddenCosts,
          ),
        ),
        const SizedBox(height: 12),
        StaggeredReveal(
          index: 2,
          child: RiskRadarCard(
            score: result.riskScore,
            summary: result.riskSummary,
          ),
        ),
        const SizedBox(height: 12),
        StaggeredReveal(
          index: 3,
          child: NegotiationCard(tips: result.negotiationTips),
        ),
        const SizedBox(height: 12),
        StaggeredReveal(
          index: 4,
          child: SourceTransparencyCard(
            confidenceScore: result.confidenceScore,
            dataFreshness: result.dataFreshness,
            sources: result.sources,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.analytics_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No result yet. Submit a property first.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/input'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Go to Input'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}