import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/business_provider.dart';
import '../../services/pdf_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/common/status_badge.dart';

class EstimateDetailScreen extends StatelessWidget {
  final String estimateId;
  const EstimateDetailScreen({super.key, required this.estimateId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvoiceProvider>();
    final business = context.read<BusinessProvider>().business;
    final estimate = provider.estimates.where((e) => e.id == estimateId).firstOrNull;

    if (estimate == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Estimate')),
        body: const Center(child: Text('Estimate not found')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(estimate.invoiceNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF26A69A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(estimate.clientName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                      StatusBadge(status: estimate.status, large: true),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(CurrencyFormatter.format(estimate.total, symbol: estimate.currencySymbol),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 4),
                  if (estimate.validUntil != null)
                    Text('Valid until: ${estimate.validUntil}',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
              ),
              child: Column(
                children: estimate.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text('${item.quantity} × ${CurrencyFormatter.format(item.price)}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                      Text(CurrencyFormatter.format(item.amount),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      provider.convertEstimateToInvoice(estimateId);
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Estimate converted to invoice!'), backgroundColor: AppColors.paid),
                      );
                    },
                    icon: const Icon(Icons.receipt_long_outlined, color: Colors.white),
                    label: const Text('Convert to Invoice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final bytes = await PdfService.generateInvoicePdf(invoice: estimate, business: business);
                      await PdfService.sharePdf(bytes, estimate.invoiceNumber);
                    },
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
