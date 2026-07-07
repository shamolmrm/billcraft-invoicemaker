import 'package:flutter/material.dart';
import '../../models/invoice_model.dart';
import '../../models/business_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';

class InvoiceTemplateWidget extends StatelessWidget {
  final InvoiceModel invoice;
  final BusinessModel business;
  final String templateId;

  const InvoiceTemplateWidget({
    super.key,
    required this.invoice,
    required this.business,
    required this.templateId,
  });

  @override
  Widget build(BuildContext context) {
    switch (templateId) {
      case 'classic':       return _ClassicTemplate(invoice: invoice, business: business);
      case 'bold_dark':     return _BoldDarkTemplate(invoice: invoice, business: business);
      case 'minimalist':    return _MinimalistTemplate(invoice: invoice, business: business);
      case 'corporate':     return _CorporateTemplate(invoice: invoice, business: business);
      case 'colorful':      return _ColorfulTemplate(invoice: invoice, business: business);
      case 'nature':        return _NatureTemplate(invoice: invoice, business: business);
      case 'royal':         return _RoyalTemplate(invoice: invoice, business: business);
      case 'sunset':        return _SunsetTemplate(invoice: invoice, business: business);
      case 'ocean':         return _OceanTemplate(invoice: invoice, business: business);
      case 'tech_dark':     return _TechDarkTemplate(invoice: invoice, business: business);
      case 'pastel':        return _PastelTemplate(invoice: invoice, business: business);
      case 'gold':          return _GoldTemplate(invoice: invoice, business: business);
      case 'watercolor':    return _WatercolorTemplate(invoice: invoice, business: business);
      case 'marble':        return _MarbleTemplate(invoice: invoice, business: business);
      default:              return _ModernTemplate(invoice: invoice, business: business);
    }
  }
}

// ─── Shared helpers ────────────────────────────────────────────────────────

class _InvoiceBody extends StatelessWidget {
  final InvoiceModel invoice;
  final BusinessModel business;
  final Color headerColor;
  final Color accentColor;
  final Color textColor;
  final Color bgColor;
  final Color tableHeaderColor;
  final Color tableHeaderText;
  final bool darkHeader;

  const _InvoiceBody({
    required this.invoice,
    required this.business,
    required this.headerColor,
    required this.accentColor,
    this.textColor = AppColors.textPrimary,
    this.bgColor = Colors.white,
    this.tableHeaderColor = AppColors.primary,
    this.tableHeaderText = Colors.white,
    this.darkHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(),
                  const SizedBox(height: 12),
                  _buildItemsTable(),
                  const SizedBox(height: 12),
                  _buildTotals(),
                  if (invoice.paymentMethod != null) ...[
                    const SizedBox(height: 10),
                    _buildPaymentMethod(),
                  ],
                  if (invoice.terms != null) ...[
                    const SizedBox(height: 8),
                    _buildTerms(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: headerColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                business.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: darkHeader ? Colors.white : textColor,
                ),
              ),
              if (business.email != null)
                Text(business.email!,
                    style: TextStyle(
                        fontSize: 9,
                        color: darkHeader
                            ? Colors.white70
                            : textColor.withValues(alpha: 0.7))),
              if (business.phone != null)
                Text(business.phone!,
                    style: TextStyle(
                        fontSize: 9,
                        color: darkHeader
                            ? Colors.white70
                            : textColor.withValues(alpha: 0.7))),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'INVOICE',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: darkHeader ? Colors.white : accentColor,
                  letterSpacing: 2,
                ),
              ),
              Text(
                invoice.invoiceNumber,
                style: TextStyle(
                  fontSize: 10,
                  color: darkHeader ? Colors.white70 : textColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('BILL TO'),
              Text(invoice.clientName,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textColor)),
              if (invoice.clientCompany != null)
                Text(invoice.clientCompany!,
                    style: TextStyle(
                        fontSize: 9,
                        color: textColor.withValues(alpha: 0.6))),
              if (invoice.clientEmail.isNotEmpty)
                Text(invoice.clientEmail,
                    style: TextStyle(
                        fontSize: 9,
                        color: textColor.withValues(alpha: 0.6))),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _infoKV('Issue Date', DateFormatter.formatFull(invoice.issueDate)),
            _infoKV('Due Date', DateFormatter.formatFull(invoice.dueDate)),
            if (invoice.poNumber != null)
              _infoKV('P.O. #', invoice.poNumber!),
          ],
        ),
      ],
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Text(t,
        style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: accentColor,
            letterSpacing: 1)),
  );

  Widget _infoKV(String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$k: ',
            style: TextStyle(fontSize: 8, color: textColor.withValues(alpha: 0.6))),
        Text(v,
            style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: textColor)),
      ],
    ),
  );

  Widget _buildItemsTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade200, width: 0.5),
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: tableHeaderColor),
          children: [
            _th('DESCRIPTION'),
            _th('QTY'),
            _th('PRICE'),
            _th('AMOUNT'),
          ],
        ),
        ...invoice.items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final rowBg = i.isEven
              ? (bgColor == Colors.white ? const Color(0xFFF8FBFB) : bgColor)
              : bgColor;
          return TableRow(
            decoration: BoxDecoration(color: rowBg),
            children: [
              _td(item.description),
              _td('${item.quantity}', align: TextAlign.center),
              _td(CurrencyFormatter.format(item.price, symbol: invoice.currencySymbol),
                  align: TextAlign.right),
              _td(CurrencyFormatter.format(item.amount, symbol: invoice.currencySymbol),
                  align: TextAlign.right, bold: true),
            ],
          );
        }),
      ],
    );
  }

  Widget _th(String t) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    child: Text(t,
        style: TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.w700,
            color: tableHeaderText)),
  );

  Widget _td(String t, {TextAlign align = TextAlign.left, bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: Text(t,
            textAlign: align,
            style: TextStyle(
                fontSize: 8,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                color: textColor)),
      );

  Widget _buildTotals() {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 160,
        child: Column(
          children: [
            _totRow('Subtotal',
                CurrencyFormatter.format(invoice.subtotal, symbol: invoice.currencySymbol)),
            if (invoice.discountAmount > 0)
              _totRow('Discount',
                  '-${CurrencyFormatter.format(invoice.discountAmount, symbol: invoice.currencySymbol)}',
                  color: Colors.red.shade700),
            if (invoice.taxAmount > 0)
              _totRow('Tax',
                  '+${CurrencyFormatter.format(invoice.taxAmount, symbol: invoice.currencySymbol)}',
                  color: Colors.blue.shade700),
            Divider(color: accentColor, thickness: 1),
            _totRow(
              'TOTAL',
              CurrencyFormatter.format(invoice.total, symbol: invoice.currencySymbol),
              large: true,
              color: accentColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _totRow(String k, String v, {bool large = false, Color? color}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k,
                style: TextStyle(
                    fontSize: large ? 10 : 8,
                    fontWeight: large ? FontWeight.w800 : FontWeight.w400,
                    color: color ?? textColor.withValues(alpha: 0.7))),
            Text(v,
                style: TextStyle(
                    fontSize: large ? 12 : 9,
                    fontWeight: FontWeight.w700,
                    color: color ?? textColor)),
          ],
        ),
      );

  Widget _buildPaymentMethod() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PAYMENT METHOD',
              style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                  letterSpacing: 1)),
          const SizedBox(height: 2),
          Text(invoice.paymentMethod!,
              style: TextStyle(fontSize: 8, color: textColor.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  Widget _buildTerms() {
    return Text(
      'Terms: ${invoice.terms}',
      style: TextStyle(
          fontSize: 7,
          color: textColor.withValues(alpha: 0.5),
          fontStyle: FontStyle.italic),
    );
  }
}

// ─── Template 1: Classic White ─────────────────────────────────────────────
class _ClassicTemplate extends StatelessWidget {
  final InvoiceModel invoice;
  final BusinessModel business;
  const _ClassicTemplate({required this.invoice, required this.business});

  @override
  Widget build(BuildContext context) => _InvoiceBody(
        invoice: invoice,
        business: business,
        headerColor: const Color(0xFFF5F7FA),
        accentColor: const Color(0xFF1A365D),
        tableHeaderColor: const Color(0xFF1A365D),
      );
}

// ─── Template 2: Modern Teal (default) ─────────────────────────────────────
class _ModernTemplate extends StatelessWidget {
  final InvoiceModel invoice;
  final BusinessModel business;
  const _ModernTemplate({required this.invoice, required this.business});

  @override
  Widget build(BuildContext context) => _InvoiceBody(
        invoice: invoice,
        business: business,
        headerColor: AppColors.primary,
        accentColor: AppColors.primary,
        tableHeaderColor: AppColors.primary,
        darkHeader: true,
      );
}

// ─── Template 3: Bold Dark ──────────────────────────────────────────────────
class _BoldDarkTemplate extends StatelessWidget {
  final InvoiceModel invoice;
  final BusinessModel business;
  const _BoldDarkTemplate({required this.invoice, required this.business});

  @override
  Widget build(BuildContext context) => _InvoiceBody(
        invoice: invoice,
        business: business,
        headerColor: const Color(0xFF1A2535),
        accentColor: const Color(0xFF1DE9B6),
        tableHeaderColor: const Color(0xFF243040),
        tableHeaderText: const Color(0xFF1DE9B6),
        darkHeader: true,
        bgColor: const Color(0xFFF8FAFB),
      );
}

// ─── Template 4: Marble ─────────────────────────────────────────────────────
class _MarbleTemplate extends StatelessWidget {
  final InvoiceModel invoice;
  final BusinessModel business;
  const _MarbleTemplate({required this.invoice, required this.business});

  @override
  Widget build(BuildContext context) => _InvoiceBody(
        invoice: invoice,
        business: business,
        headerColor: const Color(0xFFF0EBE3),
        accentColor: const Color(0xFF8B6914),
        tableHeaderColor: const Color(0xFF8B6914),
        bgColor: const Color(0xFFFAF8F5),
      );
}

// ─── Template 5: Minimalist ─────────────────────────────────────────────────
class _MinimalistTemplate extends StatelessWidget {
  final InvoiceModel invoice;
  final BusinessModel business;
  const _MinimalistTemplate({required this.invoice, required this.business});

  @override
  Widget build(BuildContext context) => _InvoiceBody(
        invoice: invoice,
        business: business,
        headerColor: Colors.white,
        accentColor: const Color(0xFF718096),
        tableHeaderColor: const Color(0xFFF5F7FA),
        tableHeaderText: const Color(0xFF4A5568),
      );
}

// ─── Template 6: Corporate Blue ─────────────────────────────────────────────
class _CorporateTemplate extends StatelessWidget {
  final InvoiceModel invoice;
  final BusinessModel business;
  const _CorporateTemplate({required this.invoice, required this.business});

  @override
  Widget build(BuildContext context) => _InvoiceBody(
        invoice: invoice,
        business: business,
        headerColor: const Color(0xFF1565C0),
        accentColor: const Color(0xFF1565C0),
        tableHeaderColor: const Color(0xFF1565C0),
        darkHeader: true,
      );
}

// ─── Template 7: Colorful ───────────────────────────────────────────────────
class _ColorfulTemplate extends StatelessWidget {
  final InvoiceModel invoice;
  final BusinessModel business;
  const _ColorfulTemplate({required this.invoice, required this.business});

  @override
  Widget build(BuildContext context) => _InvoiceBody(
        invoice: invoice,
        business: business,
        headerColor: const Color(0xFF6A1B9A),
        accentColor: const Color(0xFF6A1B9A),
        tableHeaderColor: const Color(0xFF6A1B9A),
        darkHeader: true,
      );
}

// ─── Template 8: Nature Green ───────────────────────────────────────────────
class _NatureTemplate extends StatelessWidget {
  final InvoiceModel invoice;
  final BusinessModel business;
  const _NatureTemplate({required this.invoice, required this.business});

  @override
  Widget build(BuildContext context) => _InvoiceBody(
        invoice: invoice,
        business: business,
        headerColor: const Color(0xFF2E7D32),
        accentColor: const Color(0xFF2E7D32),
        tableHeaderColor: const Color(0xFF388E3C),
        bgColor: const Color(0xFFF1F8E9),
        darkHeader: true,
      );
}

// ─── Template 9: Royal Purple ───────────────────────────────────────────────
class _RoyalTemplate extends StatelessWidget {
  final InvoiceModel invoice;
  final BusinessModel business;
  const _RoyalTemplate({required this.invoice, required this.business});

  @override
  Widget build(BuildContext context) => _InvoiceBody(
        invoice: invoice,
        business: business,
        headerColor: const Color(0xFF4A148C),
        accentColor: const Color(0xFFFFD700),
        tableHeaderColor: const Color(0xFF4A148C),
        tableHeaderText: const Color(0xFFFFD700),
        darkHeader: true,
      );
}

// ─── Template 10: Sunset Orange ─────────────────────────────────────────────
class _SunsetTemplate extends StatelessWidget {
  final InvoiceModel invoice;
  final BusinessModel business;
  const _SunsetTemplate({required this.invoice, required this.business});

  @override
  Widget build(BuildContext context) => _InvoiceBody(
        invoice: invoice,
        business: business,
        headerColor: const Color(0xFFE65100),
        accentColor: const Color(0xFFE65100),
        tableHeaderColor: const Color(0xFFBF360C),
        darkHeader: true,
      );
}

// ─── Template 11: Ocean Blue ────────────────────────────────────────────────
class _OceanTemplate extends StatelessWidget {
  final InvoiceModel invoice;
  final BusinessModel business;
  const _OceanTemplate({required this.invoice, required this.business});

  @override
  Widget build(BuildContext context) => _InvoiceBody(
        invoice: invoice,
        business: business,
        headerColor: const Color(0xFF006064),
        accentColor: const Color(0xFF00838F),
        tableHeaderColor: const Color(0xFF006064),
        bgColor: const Color(0xFFE0F7FA),
        darkHeader: true,
      );
}

// ─── Template 12: Tech Dark ─────────────────────────────────────────────────
class _TechDarkTemplate extends StatelessWidget {
  final InvoiceModel invoice;
  final BusinessModel business;
  const _TechDarkTemplate({required this.invoice, required this.business});

  @override
  Widget build(BuildContext context) => _InvoiceBody(
        invoice: invoice,
        business: business,
        headerColor: const Color(0xFF0D1117),
        accentColor: const Color(0xFF1DE9B6),
        tableHeaderColor: const Color(0xFF161B22),
        tableHeaderText: const Color(0xFF1DE9B6),
        bgColor: const Color(0xFF0D1117),
        textColor: const Color(0xFFE6EDF3),
        darkHeader: true,
      );
}

// ─── Template 13: Pastel Pink ───────────────────────────────────────────────
class _PastelTemplate extends StatelessWidget {
  final InvoiceModel invoice;
  final BusinessModel business;
  const _PastelTemplate({required this.invoice, required this.business});

  @override
  Widget build(BuildContext context) => _InvoiceBody(
        invoice: invoice,
        business: business,
        headerColor: const Color(0xFFF8BBD9),
        accentColor: const Color(0xFFAD1457),
        tableHeaderColor: const Color(0xFFF48FB1),
        tableHeaderText: const Color(0xFF880E4F),
        bgColor: const Color(0xFFFCE4EC),
      );
}

// ─── Template 14: Gold Premium ──────────────────────────────────────────────
class _GoldTemplate extends StatelessWidget {
  final InvoiceModel invoice;
  final BusinessModel business;
  const _GoldTemplate({required this.invoice, required this.business});

  @override
  Widget build(BuildContext context) => _InvoiceBody(
        invoice: invoice,
        business: business,
        headerColor: const Color(0xFFFFF8E1),
        accentColor: const Color(0xFFF9A825),
        tableHeaderColor: const Color(0xFFF9A825),
        tableHeaderText: Colors.white,
        bgColor: const Color(0xFFFFFDE7),
      );
}

// ─── Template 15: Watercolor Blue ───────────────────────────────────────────
class _WatercolorTemplate extends StatelessWidget {
  final InvoiceModel invoice;
  final BusinessModel business;
  const _WatercolorTemplate({required this.invoice, required this.business});

  @override
  Widget build(BuildContext context) => _InvoiceBody(
        invoice: invoice,
        business: business,
        headerColor: const Color(0xFFE3F2FD),
        accentColor: const Color(0xFF1565C0),
        tableHeaderColor: const Color(0xFF1976D2),
        bgColor: const Color(0xFFF3F8FE),
      );
}
