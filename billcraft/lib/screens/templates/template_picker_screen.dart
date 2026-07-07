import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/business_provider.dart';
import '../../widgets/invoice_templates/invoice_template_widget.dart';

class TemplatePickerScreen extends StatefulWidget {
  final String currentTemplate;
  final void Function(String)? onTemplateSelected;
  const TemplatePickerScreen({super.key, this.currentTemplate = 'modern', this.onTemplateSelected});

  @override
  State<TemplatePickerScreen> createState() => _TemplatePickerScreenState();
}

class _TemplatePickerScreenState extends State<TemplatePickerScreen> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentTemplate;
  }

  @override
  Widget build(BuildContext context) {
    final invoices = context.read<InvoiceProvider>().invoices;
    final business = context.read<BusinessProvider>().business;
    final previewInvoice = invoices.isNotEmpty ? invoices.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Template', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () {
              if (widget.onTemplateSelected != null) widget.onTemplateSelected!(_selected);
              context.pop(_selected);
            },
            child: const Text('Apply', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ],
      ),
      body: Column(
        children: [
          if (previewInvoice != null)
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: InvoiceTemplateWidget(
                    invoice: previewInvoice,
                    business: business,
                    templateId: _selected,
                  ),
                ),
              ),
            ),
          Expanded(
            flex: 2,
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: AppConstants.templateIds.length,
              itemBuilder: (ctx, i) {
                final id = AppConstants.templateIds[i];
                final name = AppConstants.templateNames[i];
                final isSelected = _selected == id;
                return GestureDetector(
                  onTap: () => setState(() => _selected = id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: previewInvoice != null
                              ? InvoiceTemplateWidget(
                                  invoice: previewInvoice,
                                  business: business,
                                  templateId: id,
                                )
                              : Container(color: Colors.grey.shade200),
                        ),
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.black.withValues(alpha: 0.5),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                            ),
                            child: Text(name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 6, right: 6,
                            child: Container(
                              width: 20, height: 20,
                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              child: const Icon(Icons.check, color: Colors.white, size: 13),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
