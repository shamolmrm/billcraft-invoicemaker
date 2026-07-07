import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/business_provider.dart';
import '../../widgets/inputs/custom_text_field.dart';
import '../../widgets/buttons/gradient_button.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});
  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _taxNumberCtrl = TextEditingController();
  final _bankDetailsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final b = context.read<BusinessProvider>().business;
    _nameCtrl.text = b.name;
    _addressCtrl.text = b.address ?? '';
    _phoneCtrl.text = b.phone ?? '';
    _emailCtrl.text = b.email ?? '';
    _websiteCtrl.text = b.website ?? '';
    _taxNumberCtrl.text = b.taxNumber ?? '';
    _bankDetailsCtrl.text = b.bankDetails ?? '';
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _addressCtrl, _phoneCtrl, _emailCtrl,
        _websiteCtrl, _taxNumberCtrl, _bankDetailsCtrl]) c.dispose();
    super.dispose();
  }

  void _save() {
    final provider = context.read<BusinessProvider>();
    provider.updateBusiness(provider.business.copyWith(
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.isEmpty ? null : _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.isEmpty ? null : _phoneCtrl.text.trim(),
      email: _emailCtrl.text.isEmpty ? null : _emailCtrl.text.trim(),
      website: _websiteCtrl.text.isEmpty ? null : _websiteCtrl.text.trim(),
      taxNumber: _taxNumberCtrl.text.isEmpty ? null : _taxNumberCtrl.text.trim(),
      bankDetails: _bankDetailsCtrl.text.isEmpty ? null : _bankDetailsCtrl.text.trim(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Business profile updated!'), backgroundColor: AppColors.paid),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryContainer,
                  child: const Text('B', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 30, height: 30,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _card(isDark, 'Basic Info', [
            CustomTextField(controller: _nameCtrl, label: 'Business / Owner Name *', prefixIcon: Icons.business_outlined, textCapitalization: TextCapitalization.words),
            const SizedBox(height: 12),
            CustomTextField(controller: _emailCtrl, label: 'Email', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            CustomTextField(controller: _phoneCtrl, label: 'Phone', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            CustomTextField(controller: _websiteCtrl, label: 'Website', prefixIcon: Icons.language_outlined, keyboardType: TextInputType.url),
          ]),
          const SizedBox(height: 16),
          _card(isDark, 'Address', [
            CustomTextField(controller: _addressCtrl, label: 'Full Address', prefixIcon: Icons.location_on_outlined, maxLines: 3),
          ]),
          const SizedBox(height: 16),
          _card(isDark, 'Tax & Banking', [
            CustomTextField(controller: _taxNumberCtrl, label: 'Tax Number / GST / VAT', prefixIcon: Icons.numbers),
            const SizedBox(height: 12),
            CustomTextField(controller: _bankDetailsCtrl, label: 'Bank / Payment Details', prefixIcon: Icons.account_balance_outlined, maxLines: 3, hint: 'Bank: XYZ\nAccount: 12345\nRouting: 67890'),
          ]),
          const SizedBox(height: 24),
          GradientButton(label: 'Save Profile', onPressed: _save),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _card(bool isDark, String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}
