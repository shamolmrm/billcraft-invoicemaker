import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/invoice_model.dart';

class StatusBadge extends StatelessWidget {
  final InvoiceStatus status;
  final bool large;

  const StatusBadge({super.key, required this.status, this.large = false});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 7 : 4,
      ),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(large ? 10 : 6),
        border: Border.all(color: config.textColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontSize: large ? 13 : 11,
          fontWeight: FontWeight.w600,
          color: config.textColor,
        ),
      ),
    );
  }

  _StatusConfig _getConfig(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return const _StatusConfig('Paid', AppColors.paid, AppColors.paidBg);
      case InvoiceStatus.unpaid:
        return const _StatusConfig('Unpaid', AppColors.unpaid, AppColors.unpaidBg);
      case InvoiceStatus.partiallyPaid:
        return const _StatusConfig(
            'Partially Paid', AppColors.partiallyPaid, AppColors.partiallyPaidBg);
      case InvoiceStatus.overdue:
        return const _StatusConfig('Overdue', AppColors.overdue, AppColors.overdueBg);
      case InvoiceStatus.cancelled:
        return const _StatusConfig('Cancelled', AppColors.textTertiary, AppColors.surfaceVariant);
      default:
        return const _StatusConfig('Draft', AppColors.textTertiary, AppColors.surfaceVariant);
    }
  }
}

class _StatusConfig {
  final String label;
  final Color textColor;
  final Color bgColor;
  const _StatusConfig(this.label, this.textColor, this.bgColor);
}
