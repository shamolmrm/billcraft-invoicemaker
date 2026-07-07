import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/client_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../widgets/cards/invoice_card.dart';

class ClientDetailScreen extends StatelessWidget {
  final String clientId;
  const ClientDetailScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    final client = context.watch<ClientProvider>().getById(clientId);
    final invoices = context.watch<InvoiceProvider>().getByClientId(clientId);

    if (client == null) {
      return Scaffold(appBar: AppBar(title: const Text('Client')),
          body: const Center(child: Text('Client not found')));
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(RouteNames.addClient, extra: {'clientId': clientId}),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client avatar + name
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(client.initials,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(client.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        if (client.company != null)
                          Text(client.company!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        Text(client.email, style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                        if (client.phone != null)
                          Text(client.phone!, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Summary cards
            Row(
              children: [
                _StatCard('Total Invoiced', client.totalInvoiced, AppColors.primary),
                const SizedBox(width: 8),
                _StatCard('Total Paid', client.totalPaid, AppColors.paid),
                const SizedBox(width: 8),
                _StatCard('Outstanding', client.outstanding, AppColors.overdue),
              ],
            ),
            if (client.address != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
                    const SizedBox(height: 4),
                    Text(client.fullAddress, style: const TextStyle(fontSize: 13, height: 1.5)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Invoice History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                TextButton.icon(
                  onPressed: () => context.push(RouteNames.createInvoice),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Invoice'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (invoices.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No invoices yet for this client',
                      style: TextStyle(color: AppColors.textTertiary)),
                ),
              )
            else
              ...invoices.map((inv) => InvoiceCard(
                    invoice: inv,
                    onTap: () => context.push('${RouteNames.invoiceDetail}/${inv.id}'),
                  )),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  const _StatCard(this.label, this.amount, this.color);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(CurrencyFormatter.formatCompact(amount),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}
