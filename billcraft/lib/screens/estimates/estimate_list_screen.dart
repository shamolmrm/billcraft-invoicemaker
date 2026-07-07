import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/invoice_model.dart';
import '../../providers/invoice_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/status_badge.dart';
import '../../core/theme/app_shadows.dart';

class EstimateListScreen extends StatelessWidget {
  const EstimateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final estimates = context.watch<InvoiceProvider>().estimates;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estimates', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: estimates.isEmpty
          ? EmptyState(
              emoji: '📋',
              title: 'No estimates yet',
              subtitle: 'Create estimates to send to potential clients',
              buttonLabel: '+ Create Estimate',
              onButtonTap: () => context.push(RouteNames.createEstimate),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: estimates.length,
              itemBuilder: (ctx, i) {
                final est = estimates[i];
                return _EstimateCard(
                  estimate: est,
                  onTap: () => context.push('${RouteNames.estimateDetail}/${est.id}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.createEstimate),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Estimate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _EstimateCard extends StatelessWidget {
  final InvoiceModel estimate;
  final VoidCallback? onTap;
  const _EstimateCard({required this.estimate, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.card,
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(estimate.clientName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                StatusBadge(status: estimate.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(estimate.invoiceNumber,
                style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(CurrencyFormatter.format(estimate.total, symbol: estimate.currencySymbol),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(DateFormatter.formatFull(estimate.issueDate),
                        style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                    if (estimate.validUntil != null)
                      Text('Valid until ${estimate.validUntil}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
