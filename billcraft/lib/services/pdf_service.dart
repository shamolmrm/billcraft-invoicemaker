import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/invoice_model.dart';
import '../models/business_model.dart';

class PdfService {
  static Future<Uint8List> generateInvoicePdf({
    required InvoiceModel invoice,
    required BusinessModel business,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => _buildTemplate(invoice, business),
      ),
    );
    return pdf.save();
  }

  static pw.Widget _buildTemplate(InvoiceModel invoice, BusinessModel business) {
    final teal = PdfColor.fromHex('#00897B');
    final dark = PdfColor.fromHex('#1A202C');
    final grey = PdfColor.fromHex('#718096');
    final lightGrey = PdfColor.fromHex('#F5F7FA');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(24),
          decoration: pw.BoxDecoration(
            color: teal,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(business.name,
                      style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white)),
                  if (business.email != null)
                    pw.Text(business.email!,
                        style: pw.TextStyle(color: PdfColor(1, 1, 1, 0.7), fontSize: 10)),
                  if (business.phone != null)
                    pw.Text(business.phone!,
                        style: pw.TextStyle(color: PdfColor(1, 1, 1, 0.7), fontSize: 10)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('INVOICE',
                      style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white)),
                  pw.Text(invoice.invoiceNumber,
                      style: pw.TextStyle(color: PdfColor(1, 1, 1, 0.7), fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 24),
        // Info Row
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('BILL TO', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: grey)),
                pw.SizedBox(height: 4),
                pw.Text(invoice.clientName, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: dark)),
                if (invoice.clientCompany != null)
                  pw.Text(invoice.clientCompany!, style: pw.TextStyle(fontSize: 10, color: grey)),
                if (invoice.clientEmail.isNotEmpty)
                  pw.Text(invoice.clientEmail, style: pw.TextStyle(fontSize: 10, color: grey)),
                if (invoice.clientAddress.isNotEmpty)
                  pw.Container(
                    width: 180,
                    child: pw.Text(invoice.clientAddress, style: pw.TextStyle(fontSize: 9, color: grey)),
                  ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _infoRow('Issue Date', _fmtDate(invoice.issueDate)),
                _infoRow('Due Date', _fmtDate(invoice.dueDate)),
                if (invoice.poNumber != null) _infoRow('P.O. #', invoice.poNumber!),
                _infoRow('Currency', invoice.currency),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 24),
        // Items Table
        pw.Table(
          border: pw.TableBorder.all(color: PdfColor.fromHex('#E2E8F0'), width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(4),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(1),
            5: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: teal),
              children: [
                _tableHeader('Description'),
                _tableHeader('Qty'),
                _tableHeader('Price'),
                _tableHeader('Disc%'),
                _tableHeader('Tax%'),
                _tableHeader('Amount'),
              ],
            ),
            ...invoice.items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final bg = i.isEven ? lightGrey : PdfColors.white;
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: bg),
                children: [
                  _tableCell(item.description),
                  _tableCell('${item.quantity}'),
                  _tableCell('${invoice.currencySymbol}${item.price.toStringAsFixed(2)}'),
                  _tableCell(item.discountPercent != null ? '${item.discountPercent}%' : '-'),
                  _tableCell(item.taxPercent != null ? '${item.taxPercent}%' : '-'),
                  _tableCell('${invoice.currencySymbol}${item.amount.toStringAsFixed(2)}', bold: true),
                ],
              );
            }),
          ],
        ),
        pw.SizedBox(height: 20),
        // Totals
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Container(
            width: 220,
            child: pw.Column(
              children: [
                _totalRow('Subtotal', '${invoice.currencySymbol}${invoice.subtotal.toStringAsFixed(2)}'),
                if (invoice.discountAmount > 0)
                  _totalRow('Discount (${invoice.discountPercent}%)',
                      '-${invoice.currencySymbol}${invoice.discountAmount.toStringAsFixed(2)}'),
                if (invoice.taxAmount > 0)
                  _totalRow('Tax (${invoice.taxPercent.toStringAsFixed(1)}%)',
                      '+${invoice.currencySymbol}${invoice.taxAmount.toStringAsFixed(2)}'),
                pw.Divider(color: teal),
                _totalRow('TOTAL', '${invoice.currencySymbol}${invoice.total.toStringAsFixed(2)}',
                    bold: true, highlight: teal),
              ],
            ),
          ),
        ),
        if (invoice.paymentMethod != null && invoice.paymentMethod!.isNotEmpty) ...[
          pw.SizedBox(height: 20),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: lightGrey,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('PAYMENT METHOD', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: grey)),
                pw.SizedBox(height: 4),
                pw.Text(invoice.paymentMethod!, style: pw.TextStyle(fontSize: 10, color: dark)),
              ],
            ),
          ),
        ],
        if (invoice.terms != null && invoice.terms!.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text('Terms & Conditions', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: grey)),
          pw.Text(invoice.terms!, style: pw.TextStyle(fontSize: 9, color: grey)),
        ],
      ],
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text('$label: ', style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#718096'))),
          pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _tableHeader(String text) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: pw.Text(text,
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
  );

  static pw.Widget _tableCell(String text, {bool bold = false}) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: pw.Text(text,
        style: pw.TextStyle(fontSize: 9, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
  );

  static pw.Widget _totalRow(String label, String value, {bool bold = false, PdfColor? highlight}) {
    return pw.Container(
      color: highlight,
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: bold ? 11 : 9,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: highlight != null ? PdfColors.white : null)),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: bold ? 12 : 9,
                  fontWeight: pw.FontWeight.bold,
                  color: highlight != null ? PdfColors.white : null)),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static Future<String> savePdfToDevice(Uint8List bytes, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.pdf');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  static Future<void> sharePdf(Uint8List bytes, String fileName) async {
    await Printing.sharePdf(bytes: bytes, filename: '$fileName.pdf');
  }

  static Future<void> printPdf(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (_) => bytes);
  }
}
