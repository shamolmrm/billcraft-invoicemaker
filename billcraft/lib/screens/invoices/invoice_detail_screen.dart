import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/routes/route_names.dart';
import '../../models/invoice_model.dart';
import '../../models/payment_model.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/business_provider.dart';
import '../../services/pdf_service.dart';
import '../../widgets/common/status_badge.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvoiceProvider>();
    final business = context.read<BusinessProvider>().business;
    final invoice = provider.getById(invoiceId);

    if (invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice')),
        body: const Center(child: Text('Invoice not found')),
      );
    }

    final payments = provider.getPaymentsForInvoice(invoiceId);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(invoice.invoiceNumber,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('${RouteNames.editInvoice}/${invoice.id}'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMore(context, invoice, provider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          children: [
            _StatusCard(invoice: invoice),
            const SizedBox(height: 16),
            _InvoiceInfoCard(invoice: invoice),
            const SizedBox(height: 16),
            _ItemsCard(invoice: invoice),
            const SizedBox(height: 16),
            _TotalsCard(invoice: invoice),
            if (payments.isNotEmpty) ...[
              const SizedBox(height: 16),
              _PaymentHistoryCard(payments: payments),
            ],
            if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _NotesCard(notes: invoice.notes!),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: _BottomActionBar(
        invoice: invoice,
        business: business,
        onMarkPaid: () => _recordPayment(context, invoice, provider),
      ),
    );
  }

  void _showMore(BuildContext context, InvoiceModel invoice, InvoiceProvider provider) {
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
            if (invoice.status != InvoiceStatus.paid)
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: AppColors.paid),
                title: const Text('Mark as Fully Paid'),
                onTap: () {
                  Navigator.pop(context);
                  _markFullyPaid(context, invoice, provider);
                },
              ),
            ListTile(
              leading: const Icon(Icons.copy_outlined, color: AppColors.info),
              title: const Text('Clone Invoice'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.overdue),
              title: const Text('Delete Invoice', style: TextStyle(color: AppColors.overdue)),
              onTap: () {
                Navigator.pop(context);
                provider.deleteInvoice(invoice.id);
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _markFullyPaid(BuildContext context, InvoiceModel invoice, InvoiceProvider provider) {
    final payment = PaymentModel(
      invoiceId: invoice.id,
      amount: invoice.balanceDue,
      date: DateTime.now(),
      method: 'Cash',
    );
    provider.recordPayment(payment);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invoice marked as fully paid! 🎉'),
        backgroundColor: AppColors.paid,
      ),
    );
  }

  void _recordPayment(BuildContext context, InvoiceModel invoice, InvoiceProvider provider) {
    if (invoice.status == InvoiceStatus.paid) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This invoice is already fully paid.')));
      return;
    }
    final amountCtrl = TextEditingController(
        text: invoice.balanceDue.toStringAsFixed(2));
    String method = 'Bank Transfer';
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (ctx, setS) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
              const Text('Record Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$ '),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: ['Bank Transfer', 'PayPal', 'Cash', 'Credit Card', 'Cheque', 'Other']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setS(() => method = v ?? method),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final amount = double.tryParse(amountCtrl.text) ?? 0;
                    if (amount <= 0) return;
                    final payment = PaymentModel(
                      invoiceId: invoice.id,
                      amount: amount,
                      date: DateTime.now(),
                      method: method,
                      note: noteCtrl.text.isEmpty ? null : noteCtrl.text,
                    );
                    provider.recordPayment(payment);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment of ${CurrencyFormatter.format(amount)} recorded!'),
                          backgroundColor: AppColors.paid),
                    );
                  },
                  child: const Text('Save Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final InvoiceModel invoice;
  const _StatusCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice.clientName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(invoice.invoiceNumber,
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                const SizedBox(height: 12),
                Text(
                  CurrencyFormatter.format(invoice.total, symbol: invoice.currencySymbol),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                if (invoice.balanceDue > 0 && invoice.balanceDue < invoice.total)
                  Text('Balance: ${CurrencyFormatter.format(invoice.balanceDue, symbol: invoice.currencySymbol)}',
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(status: invoice.status, large: true),
              const SizedBox(height: 8),
              Text(DateFormatter.formatFull(invoice.dueDate),
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
              Text('Due date', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6))),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvoiceInfoCard extends StatelessWidget {
  final InvoiceModel invoice;
  const _InvoiceInfoCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Invoice Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _Row('Invoice #', invoice.invoiceNumber),
          _Row('Issue Date', DateFormatter.formatMedium(invoice.issueDate)),
          _Row('Due Date', DateFormatter.formatMedium(invoice.dueDate)),
          if (invoice.poNumber != null) _Row('P.O. #', invoice.poNumber!),
          const Divider(height: 20),
          const Text('Bill To', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(invoice.clientName, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (invoice.clientCompany != null)
            Text(invoice.clientCompany!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          if (invoice.clientEmail.isNotEmpty)
            Text(invoice.clientEmail, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          if (invoice.clientAddress.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(invoice.clientAddress,
                  style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            ),
        ],
      ),
    );
  }

  Widget _Row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _ItemsCard extends StatelessWidget {
  final InvoiceModel invoice;
  const _ItemsCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Items', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              Text('${invoice.items.length} items',
                  style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            ],
          ),
          const SizedBox(height: 12),
          ...invoice.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.description,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(
                        '${item.quantity} ${item.unit} × ${CurrencyFormatter.format(item.price)}' +
                            (item.discountPercent != null ? ' · ${item.discountPercent}% off' : '') +
                            (item.taxPercent != null ? ' · ${item.taxPercent}% tax' : ''),
                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.format(item.amount, symbol: invoice.currencySymbol),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  final InvoiceModel invoice;
  const _TotalsCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          _TotalRow('Subtotal', invoice.subtotal, invoice.currencySymbol),
          if (invoice.discountAmount > 0)
            _TotalRow('Discount (${invoice.discountPercent}%)', -invoice.discountAmount, invoice.currencySymbol, color: AppColors.overdue),
          if (invoice.taxAmount > 0)
            _TotalRow('Tax (${invoice.taxPercent.toStringAsFixed(1)}%)', invoice.taxAmount, invoice.currencySymbol, color: AppColors.info),
          const Divider(height: 16),
          _TotalRow('Total', invoice.total, invoice.currencySymbol, large: true),
          if (invoice.amountPaid > 0) ...[
            _TotalRow('Amount Paid', -invoice.amountPaid, invoice.currencySymbol, color: AppColors.paid),
            const Divider(height: 16),
            _TotalRow('Balance Due', invoice.balanceDue, invoice.currencySymbol, large: true,
                color: invoice.balanceDue > 0 ? AppColors.overdue : AppColors.paid),
          ],
        ],
      ),
    );
  }

  Widget _TotalRow(String label, double amount, String symbol, {bool large = false, Color? color}) {
    final absAmount = amount.abs();
    final sign = amount < 0 ? '-' : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontSize: large ? 15 : 13,
            fontWeight: large ? FontWeight.w700 : FontWeight.w400,
            color: large ? AppColors.textPrimary : AppColors.textSecondary,
          )),
          Text(
            '$sign${CurrencyFormatter.format(absAmount, symbol: symbol)}',
            style: TextStyle(
              fontSize: large ? 18 : 13,
              fontWeight: large ? FontWeight.w800 : FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentHistoryCard extends StatelessWidget {
  final List<PaymentModel> payments;
  const _PaymentHistoryCard({required this.payments});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment History', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...payments.map((p) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.paidBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.paid, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.method, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      if (p.note != null)
                        Text(p.note!, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(CurrencyFormatter.format(p.amount),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.paid)),
                    Text(DateFormatter.formatMedium(p.date),
                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String notes;
  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Notes & Terms', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(notes, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final InvoiceModel invoice;
  final dynamic business;
  final VoidCallback onMarkPaid;

  const _BottomActionBar({required this.invoice, required this.business, required this.onMarkPaid});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _ActionBtn(icon: Icons.share_outlined, label: 'Share', onTap: () async {
                final bytes = await PdfService.generateInvoicePdf(invoice: invoice, business: business);
                await PdfService.sharePdf(bytes, invoice.invoiceNumber);
              }),
              _ActionBtn(icon: Icons.print_outlined, label: 'Print', onTap: () async {
                final bytes = await PdfService.generateInvoicePdf(invoice: invoice, business: business);
                await PdfService.printPdf(bytes);
              }),
              _ActionBtn(icon: Icons.picture_as_pdf_outlined, label: 'PDF', onTap: () async {
                final bytes = await PdfService.generateInvoicePdf(invoice: invoice, business: business);
                final path = await PdfService.savePdfToDevice(bytes, invoice.invoiceNumber);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to $path')));
                }
              }),
              _ActionBtn(icon: Icons.visibility_outlined, label: 'Preview', onTap: () => context.push(
                RouteNames.invoicePreview,
                extra: {'invoiceId': invoice.id},
              )),
            ],
          ),
          if (invoice.status != InvoiceStatus.paid) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.paid,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onMarkPaid,
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: Text(
                  invoice.amountPaid > 0 ? 'Record Partial Payment' : 'Mark as Paid',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
