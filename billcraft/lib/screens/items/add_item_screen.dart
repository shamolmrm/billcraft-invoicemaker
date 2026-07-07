import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/item_model.dart';
import '../../providers/item_provider.dart';
import '../../widgets/inputs/custom_text_field.dart';
import '../../widgets/buttons/gradient_button.dart';

class AddItemScreen extends StatefulWidget {
  final String? itemId;
  const AddItemScreen({super.key, this.itemId});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();
  String _unit = 'pcs';
  String? _category;

  @override
  void initState() {
    super.initState();
    if (widget.itemId != null) {
      final item = context.read<ItemProvider>().getById(widget.itemId!);
      if (item != null) {
        _nameCtrl.text = item.name;
        _descCtrl.text = item.description ?? '';
        _priceCtrl.text = item.price.toStringAsFixed(2);
        _taxCtrl.text = item.taxRate?.toString() ?? '';
        _unit = item.unit;
        _category = item.category;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose();
    _priceCtrl.dispose(); _taxCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ItemProvider>();
    final item = ItemModel(
      id: widget.itemId,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.isEmpty ? null : _descCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text) ?? 0,
      unit: _unit,
      taxRate: _taxCtrl.text.isEmpty ? null : double.tryParse(_taxCtrl.text),
      category: _category,
    );
    if (widget.itemId != null) {
      provider.updateItem(item);
    } else {
      provider.addItem(item);
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemId != null ? 'Edit Item' : 'Add Item',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Item Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _nameCtrl, label: 'Item Name *',
                    prefixIcon: Icons.label_outline,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _descCtrl, label: 'Description',
                    prefixIcon: Icons.description_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          controller: _priceCtrl, label: 'Price *',
                          prefixIcon: Icons.attach_money,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _unit,
                          decoration: const InputDecoration(labelText: 'Unit'),
                          items: AppConstants.unitOptions
                              .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                              .toList(),
                          onChanged: (v) => setState(() => _unit = v ?? 'pcs'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _taxCtrl, label: 'Tax Rate %',
                          prefixIcon: Icons.percent,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          hint: '0',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          value: _category,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('None')),
                            ...AppConstants.categoryOptions.map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            ),
                          ],
                          onChanged: (v) => setState(() => _category = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: widget.itemId != null ? 'Update Item' : 'Save Item',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
