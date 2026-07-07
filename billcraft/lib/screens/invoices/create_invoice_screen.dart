import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/invoice_model.dart';
import '../../models/invoice_item_model.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/business_provider.dart';
import '../../widgets/inputs/custom_text_field.dart';
import '../../widgets/buttons/gradient_button.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final String? invoiceId;
  const CreateInvoiceScreen({super.key, this.invoiceId});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _invoiceNumberCtrl;
  late DateTime _issueDate;
  late DateTime _dueDate;
  String? _selectedClientId;
  String _selectedClientName = '';
  String _selectedClientEmail = '';
  String _selectedClientAddress = '';
  final List<_EditableItem> _items = [];
  final _notesCtrl = TextEditingController();
  final _termsCtrl = TextEditingController();
  final _paymentMethodCtrl = TextEditingController();
  final _poCtrl = TextEditingController();
  String _templateId = 'modern';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _issueDate = DateTime.now();
    _dueDate = DateTime.now().add(const Duration(days: 30));
    final provider = context.read<InvoiceProvider>();
    final business = context.read<BusinessProvider>().business;
    _invoiceNumberCtrl = TextEditingController(
        text: widget.invoiceId != null
            ? provider.getById(widget.invoiceId!)?.invoiceNumber ?? ''
            : provider.generateNextInvoiceNumber());

    if (widget.invoiceId != null) {
      final inv = provider.getById(widget.invoiceId!);
      if (inv != null) _loadExisting(inv);
    } else {
      _notesCtrl.text = business.defaultNotes ?? '';
      _termsCtrl.text = business.defaultTerms ?? 'Payment due within 30 days.';
      _paymentMethodCtrl.text = business.bankDetails ?? '';
      _items.add(_EditableItem());
    }
  }

  void _loadExisting(InvoiceModel inv) {
    _issueDate = inv.issueDate;
    _dueDate = inv.dueDate;
    _selectedClientId = inv.clientId;
    _selectedClientName = inv.clientName;
    _selectedClientEmail = inv.clientEmail;
    _selectedClientAddress = inv.clientAddress;
    _notesCtrl.text = inv.notes ?? '';
    _termsCtrl.text = inv.terms ?? '';
    _paymentMethodCtrl.text = inv.paymentMethod ?? '';
    _poCtrl.text = inv.poNumber ?? '';
    _templateId = inv.templateId;
    for (final item in inv.items) {
      _items.add(_EditableItem.fromModel(item));
    }
  }

  @override
  void dispose() {
    _invoiceNumberCtrl.dispose();
    _notesCtrl.dispose();
    _termsCtrl.dispose();
    _paymentMethodCtrl.dispose();
    _poCtrl.dispose();
    super.dispose();
  }

  double get _subtotal => _items.fold(0, (s, i) => s + i.baseAmount);
  double get _discountTotal => _items.fold(0, (s, i) => s + i.discountAmt);
  double get _taxTotal => _items.fold(0, (s, i) => s + i.taxAmt);
  double get _total => _items.fold(0, (s, i) => s + i.total);

  Future<void> _selectDate(bool isIssue) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isIssue ? _issueDate : _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isIssue) _issueDate = picked;
        else _dueDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a client')));
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Add at least one item')));
      return;
    }
    setState(() => _isSaving = true);

    final provider = context.read<InvoiceProvider>();
    final invoiceItems = _items.map((e) => e.toModel()).toList();

    final invoice = InvoiceModel(
      id: widget.invoiceId ?? const Uuid().v4(),
      invoiceNumber: _invoiceNumberCtrl.text,
      clientId: _selectedClientId!,
      clientName: _selectedClientName,
      clientEmail: _selectedClientEmail,
      clientAddress: _selectedClientAddress,
      issueDate: _issueDate,
      dueDate: _dueDate,
      poNumber: _poCtrl.text.isEmpty ? null : _poCtrl.text,
      items: invoiceItems,
      subtotal: _subtotal,
      discountPercent: _subtotal > 0 ? _discountTotal / _subtotal * 100 : 0,
      discountAmount: _discountTotal,
      taxPercent: _subtotal > 0 ? _taxTotal / (_subtotal - _discountTotal) * 100 : 0,
      taxAmount: _taxTotal,
      total: _total,
      amountPaid: 0,
      balanceDue: _total,
      status: InvoiceStatus.unpaid,
      paymentMethod: _paymentMethodCtrl.text.isEmpty ? null : _paymentMethodCtrl.text,
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
      terms: _termsCtrl.text.isEmpty ? null : _termsCtrl.text,
      templateId: _templateId,
      currency: 'USD',
      currencySymbol: '\$',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.invoiceId != null) {
      provider.updateInvoice(invoice);
    } else {
      provider.addInvoice(invoice);
    }

    setState(() => _isSaving = false);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.invoiceId != null ? 'Edit Invoice' : 'New Invoice',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            onPressed: () {
              if (_selectedClientId != null) {
                context.push(RouteNames.invoicePreview,
                    extra: {'invoiceId': widget.invoiceId ?? 'new'});
              }
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('Invoice Info', _buildInvoiceInfo()),
            _buildSection('Bill To', _buildClientSection()),
            _buildSection('Items', _buildItemsSection()),
            _buildSection('Summary', _buildSummary()),
            _buildSection('Payment Method', _buildPaymentMethod()),
            _buildSection('Notes & Terms', _buildNotesTerms()),
            _buildSection('Template', _buildTemplateSection()),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSection(String title, Widget content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceInfo() {
    return Column(
      children: [
        CustomTextField(
          controller: _invoiceNumberCtrl,
          label: 'Invoice Number',
          prefixIcon: Icons.tag,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DatePicker(
                label: 'Issue Date',
                date: _issueDate,
                onTap: () => _selectDate(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DatePicker(
                label: 'Due Date',
                date: _dueDate,
                onTap: () => _selectDate(false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _poCtrl,
          label: 'P.O. Number (optional)',
          prefixIcon: Icons.numbers,
        ),
      ],
    );
  }

  Widget _buildClientSection() {
    return Column(
      children: [
        if (_selectedClientId != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedClientName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(_selectedClientEmail,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _selectClient,
                  child: const Text('Change'),
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: _selectClient,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 1.5),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.surfaceVariant,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_outlined, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Select Client',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _selectClient() {
    final clients = context.read<ClientProvider>().clients;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (ctx, ctrl) => Column(
          children: [
            Container(width: 40, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Select Client', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: clients.length + 1,
                itemBuilder: (ctx, i) {
                  if (i == 0) {
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primaryContainer,
                        child: Icon(Icons.add, color: AppColors.primary),
                      ),
                      title: const Text('Add New Client',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push(RouteNames.addClient);
                      },
                    );
                  }
                  final c = clients[i - 1];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(c.initials,
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ),
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(c.email, style: const TextStyle(fontSize: 12)),
                    onTap: () {
                      setState(() {
                        _selectedClientId = c.id;
                        _selectedClientName = c.name;
                        _selectedClientEmail = c.email;
                        _selectedClientAddress = c.fullAddress;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Column(
      children: [
        if (_items.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: const [
                Expanded(flex: 4, child: Text('Description', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary))),
                Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('Price', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('Amount', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary), textAlign: TextAlign.right)),
                SizedBox(width: 32),
              ],
            ),
          ),
          ..._items.asMap().entries.map((e) => _ItemRow(
            key: ValueKey(e.key),
            item: e.value,
            onRemove: () => setState(() => _items.removeAt(e.key)),
            onChanged: () => setState(() {}),
          )),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _items.add(_EditableItem())),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Item'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectFromLibrary,
                icon: const Icon(Icons.library_books_outlined, size: 18),
                label: const Text('From Library'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _selectFromLibrary() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ItemLibraryPicker(
        onSelect: (item) {
          setState(() {
            _items.add(_EditableItem.fromLibrary(item));
          });
        },
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      children: [
        _SummaryRow('Subtotal', _subtotal),
        if (_discountTotal > 0) _SummaryRow('Discount', -_discountTotal, color: AppColors.overdue),
        if (_taxTotal > 0) _SummaryRow('Tax', _taxTotal, color: AppColors.info),
        const Divider(),
        _SummaryRow('TOTAL', _total, large: true),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return CustomTextField(
      controller: _paymentMethodCtrl,
      label: 'Payment Method / Bank Details',
      hint: 'Paypal: you@example.com\nor Bank: Account 12345...',
      maxLines: 3,
      prefixIcon: Icons.payment_outlined,
    );
  }

  Widget _buildNotesTerms() {
    return Column(
      children: [
        CustomTextField(
          controller: _notesCtrl,
          label: 'Notes',
          hint: 'Thank you for your business!',
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _termsCtrl,
          label: 'Terms & Conditions',
          hint: 'Payment due within 30 days.',
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildTemplateSection() {
    final templates = [
      ('classic', 'Classic', Colors.grey.shade800),
      ('modern', 'Modern', AppColors.primary),
      ('bold_dark', 'Bold Dark', Colors.blueGrey.shade900),
      ('corporate', 'Corporate', Colors.blue.shade800),
      ('gold', 'Gold', Colors.amber.shade700),
      ('minimal', 'Minimal', Colors.blueGrey),
    ];
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: templates.length,
        itemBuilder: (ctx, i) {
          final (id, name, color) = templates[i];
          final isSelected = _templateId == id;
          return GestureDetector(
            onTap: () => setState(() => _templateId = id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              width: 70,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : AppColors.border,
                  width: isSelected ? 2.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected)
                    Icon(Icons.check_circle, color: color, size: 20)
                  else
                    Icon(Icons.description_outlined, color: color, size: 20),
                  const SizedBox(height: 4),
                  Text(name,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GradientButton(
              label: widget.invoiceId != null ? 'Update Invoice' : 'Save Invoice',
              isLoading: _isSaving,
              onPressed: _save,
              height: 48,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool large;
  final Color? color;

  const _SummaryRow(this.label, this.amount, {this.large = false, this.color});

  @override
  Widget build(BuildContext context) {
    final display = amount < 0
        ? '-${CurrencyFormatter.format(-amount)}'
        : CurrencyFormatter.format(amount);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: large ? 15 : 13,
                  fontWeight: large ? FontWeight.w700 : FontWeight.w400,
                  color: large ? AppColors.textPrimary : AppColors.textSecondary)),
          Text(display,
              style: TextStyle(
                  fontSize: large ? 18 : 13,
                  fontWeight: large ? FontWeight.w800 : FontWeight.w600,
                  color: color ?? (large ? AppColors.textPrimary : AppColors.textPrimary))),
        ],
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DatePicker({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                Text(DateFormatter.formatFull(date),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableItem {
  final TextEditingController descCtrl;
  final TextEditingController qtyCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController discCtrl;
  final TextEditingController taxCtrl;

  _EditableItem()
      : descCtrl = TextEditingController(),
        qtyCtrl = TextEditingController(text: '1'),
        priceCtrl = TextEditingController(text: '0.00'),
        discCtrl = TextEditingController(),
        taxCtrl = TextEditingController();

  _EditableItem.fromModel(InvoiceItemModel m)
      : descCtrl = TextEditingController(text: m.description),
        qtyCtrl = TextEditingController(text: m.quantity.toString()),
        priceCtrl = TextEditingController(text: m.price.toStringAsFixed(2)),
        discCtrl = TextEditingController(text: m.discountPercent?.toString() ?? ''),
        taxCtrl = TextEditingController(text: m.taxPercent?.toString() ?? '');

  _EditableItem.fromLibrary(dynamic item)
      : descCtrl = TextEditingController(text: item.name ?? ''),
        qtyCtrl = TextEditingController(text: '1'),
        priceCtrl = TextEditingController(text: (item.price ?? 0).toStringAsFixed(2)),
        discCtrl = TextEditingController(),
        taxCtrl = TextEditingController(text: item.taxRate?.toString() ?? '');

  double get qty => double.tryParse(qtyCtrl.text) ?? 1;
  double get price => double.tryParse(priceCtrl.text) ?? 0;
  double get disc => double.tryParse(discCtrl.text) ?? 0;
  double get tax => double.tryParse(taxCtrl.text) ?? 0;
  double get baseAmount => qty * price;
  double get discountAmt => baseAmount * disc / 100;
  double get taxAmt => (baseAmount - discountAmt) * tax / 100;
  double get total => baseAmount - discountAmt + taxAmt;

  InvoiceItemModel toModel() => InvoiceItemModel(
    description: descCtrl.text.isEmpty ? 'Item' : descCtrl.text,
    quantity: qty,
    price: price,
    discountPercent: disc > 0 ? disc : null,
    taxPercent: tax > 0 ? tax : null,
  );

  void dispose() {
    descCtrl.dispose(); qtyCtrl.dispose(); priceCtrl.dispose();
    discCtrl.dispose(); taxCtrl.dispose();
  }
}

class _ItemRow extends StatefulWidget {
  final _EditableItem item;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _ItemRow({super.key, required this.item, required this.onRemove, required this.onChanged});

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: TextField(
                  controller: item.descCtrl,
                  onChanged: (_) => widget.onChanged(),
                  decoration: const InputDecoration(
                    hintText: 'Description',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: item.qtyCtrl,
                  onChanged: (_) => widget.onChanged(),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: item.priceCtrl,
                  onChanged: (_) => widget.onChanged(),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero, prefixText: '\$'),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 2,
                child: Text(
                  CurrencyFormatter.format(item.total),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: widget.onRemove,
                child: const Icon(Icons.close, size: 18, color: AppColors.overdue),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Text('Discount & Tax  ',
                      style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                      size: 14, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: item.discCtrl,
                    onChanged: (_) => widget.onChanged(),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Discount %', isDense: true),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: item.taxCtrl,
                    onChanged: (_) => widget.onChanged(),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Tax %', isDense: true),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemLibraryPicker extends StatelessWidget {
  final void Function(dynamic) onSelect;
  const _ItemLibraryPicker({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: 40, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Item Library', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
        const Text('Select item to add to invoice', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
      ],
    );
  }
}
