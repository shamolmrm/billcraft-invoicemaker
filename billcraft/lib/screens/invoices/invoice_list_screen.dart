import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../models/invoice_model.dart';
import '../../providers/invoice_provider.dart';
import '../../widgets/cards/invoice_card.dart';
import '../../widgets/common/empty_state.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});
  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  bool _searching = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvoiceProvider>();
    final invoices = provider.invoices;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search invoices...',
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: provider.setSearch,
              )
            : const Text('Invoices', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _searching = !_searching);
              if (!_searching) {
                _searchCtrl.clear();
                provider.setSearch('');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(
            current: provider.filterStatus,
            onFilter: provider.setFilter,
          ),
          Expanded(
            child: invoices.isEmpty
                ? EmptyState(
                    emoji: '📄',
                    title: 'No invoices yet',
                    subtitle: 'Create your first invoice and start getting paid',
                    buttonLabel: '+ Create Invoice',
                    onButtonTap: () => context.push(RouteNames.createInvoice),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: invoices.length,
                    itemBuilder: (ctx, i) {
                      final inv = invoices[i];
                      return InvoiceCard(
                        invoice: inv,
                        onTap: () => context.push('${RouteNames.invoiceDetail}/${inv.id}'),
                        onLongPress: () => _showActions(context, inv),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showActions(BuildContext context, InvoiceModel inv) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
              title: const Text('Edit Invoice'),
              onTap: () { Navigator.pop(context); context.push('${RouteNames.editInvoice}/${inv.id}'); },
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined, color: AppColors.info),
              title: const Text('Clone Invoice'),
              onTap: () { Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined, color: AppColors.success),
              title: const Text('Share Invoice'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.overdue),
              title: const Text('Delete', style: TextStyle(color: AppColors.overdue)),
              onTap: () {
                Navigator.pop(context);
                context.read<InvoiceProvider>().deleteInvoice(inv.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final InvoiceStatus? current;
  final void Function(InvoiceStatus?) onFilter;

  const _FilterBar({required this.current, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    final filters = [
      (null, 'All'),
      (InvoiceStatus.unpaid, 'Unpaid'),
      (InvoiceStatus.partiallyPaid, 'Partially Paid'),
      (InvoiceStatus.overdue, 'Overdue'),
      (InvoiceStatus.paid, 'Paid'),
    ];
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: filters.length,
        itemBuilder: (ctx, i) {
          final (status, label) = filters[i];
          final isActive = current == status;
          return GestureDetector(
            onTap: () => onFilter(status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
