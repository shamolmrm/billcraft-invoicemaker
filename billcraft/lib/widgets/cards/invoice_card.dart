import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/invoice_model.dart';
import '../common/status_badge.dart';

class InvoiceCard extends StatelessWidget {
  final InvoiceModel invoice;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const InvoiceCard({
    super.key,
    required this.invoice,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.card,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ClientAvatar(name: invoice.clientName),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.clientName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: invoice.status),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CurrencyFormatter.format(invoice.total,
                          symbol: invoice.currencySymbol),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (invoice.status == InvoiceStatus.partiallyPaid) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Paid: ${CurrencyFormatter.format(invoice.amountPaid, symbol: invoice.currencySymbol)}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.partiallyPaid),
                      ),
                    ],
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormatter.formatFull(invoice.issueDate),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textTertiary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormatter.formatDueIn(invoice.dueDate),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: invoice.status == InvoiceStatus.overdue
                            ? AppColors.overdue
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (invoice.status == InvoiceStatus.partiallyPaid) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: invoice.amountPaidPercent / 100,
                  backgroundColor: AppColors.border,
                  color: AppColors.partiallyPaid,
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ClientAvatar extends StatelessWidget {
  final String name;
  const _ClientAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase();
    final hue = (name.codeUnits.fold(0, (a, b) => a + b) % 6);
    final colors = [
      AppColors.primary, AppColors.unpaid, AppColors.partiallyPaid,
      AppColors.overdue, const Color(0xFF6A1B9A), const Color(0xFF00838F),
    ];
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors[hue].withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colors[hue],
          ),
        ),
      ),
    );
  }
}
