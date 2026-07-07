import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/business_provider.dart';
import '../../services/pdf_service.dart';
import '../../widgets/invoice_templates/invoice_template_widget.dart';

class InvoicePreviewScreen extends StatefulWidget {
  final String invoiceId;
  const InvoicePreviewScreen({super.key, required this.invoiceId});

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  String _templateId = 'modern';

  @override
  void initState() {
    super.initState();
    final invoice = context.read<InvoiceProvider>().getById(widget.invoiceId);
    if (invoice != null) _templateId = invoice.templateId;
  }

  @override
  Widget build(BuildContext context) {
    final invoice = context.watch<InvoiceProvider>().getById(widget.invoiceId);
    final business = context.read<BusinessProvider>().business;

    if (invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Preview')),
        body: const Center(child: Text('Invoice not found')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: Text(invoice.invoiceNumber),
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () async {
              final bytes = await PdfService.generateInvoicePdf(
                  invoice: invoice, business: business);
              await PdfService.sharePdf(bytes, invoice.invoiceNumber);
            },
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () async {
              final bytes = await PdfService.generateInvoicePdf(
                  invoice: invoice, business: business);
              await PdfService.printPdf(bytes);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: AspectRatio(
                    aspectRatio: 1 / 1.414, // A4
                    child: InvoiceTemplateWidget(
                      invoice: invoice,
                      business: business,
                      templateId: _templateId,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _TemplateBar(
            currentTemplate: _templateId,
            onSelect: (t) => setState(() => _templateId = t),
          ),
        ],
      ),
    );
  }
}

class _TemplateBar extends StatelessWidget {
  final String currentTemplate;
  final void Function(String) onSelect;

  const _TemplateBar({required this.currentTemplate, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      color: Colors.grey.shade900,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: AppConstants.templateIds.length,
        itemBuilder: (ctx, i) {
          final id = AppConstants.templateIds[i];
          final name = AppConstants.templateNames[i];
          final isSelected = currentTemplate == id;
          return GestureDetector(
            onTap: () => onSelect(id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              width: 64,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : Colors.grey.shade800,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.description_outlined,
                    color: isSelected ? AppColors.primary : Colors.grey.shade400,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 8,
                      color: isSelected ? AppColors.primary : Colors.grey.shade400,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
