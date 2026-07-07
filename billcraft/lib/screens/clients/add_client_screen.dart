import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/client_model.dart';
import '../../providers/client_provider.dart';
import '../../widgets/inputs/custom_text_field.dart';
import '../../widgets/buttons/gradient_button.dart';

class AddClientScreen extends StatefulWidget {
  final String? clientId;
  const AddClientScreen({super.key, this.clientId});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'United States');
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.clientId != null) {
      final client = context.read<ClientProvider>().getById(widget.clientId!);
      if (client != null) _loadClient(client);
    }
  }

  void _loadClient(ClientModel c) {
    _nameCtrl.text = c.name;
    _companyCtrl.text = c.company ?? '';
    _emailCtrl.text = c.email;
    _phoneCtrl.text = c.phone ?? '';
    _addressCtrl.text = c.address ?? '';
    _cityCtrl.text = c.city ?? '';
    _stateCtrl.text = c.state ?? '';
    _zipCtrl.text = c.zip ?? '';
    _countryCtrl.text = c.country ?? 'United States';
    _notesCtrl.text = c.notes ?? '';
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl,_companyCtrl,_emailCtrl,_phoneCtrl,_addressCtrl,
        _cityCtrl,_stateCtrl,_zipCtrl,_countryCtrl,_notesCtrl]) { c.dispose(); }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ClientProvider>();
    final client = ClientModel(
      id: widget.clientId,
      name: _nameCtrl.text.trim(),
      company: _companyCtrl.text.isEmpty ? null : _companyCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.isEmpty ? null : _phoneCtrl.text.trim(),
      address: _addressCtrl.text.isEmpty ? null : _addressCtrl.text.trim(),
      city: _cityCtrl.text.isEmpty ? null : _cityCtrl.text.trim(),
      state: _stateCtrl.text.isEmpty ? null : _stateCtrl.text.trim(),
      zip: _zipCtrl.text.isEmpty ? null : _zipCtrl.text.trim(),
      country: _countryCtrl.text.isEmpty ? null : _countryCtrl.text.trim(),
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text.trim(),
    );
    if (widget.clientId != null) {
      provider.updateClient(client);
    } else {
      provider.addClient(client);
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clientId != null ? 'Edit Client' : 'Add Client',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _section('Basic Info', [
              CustomTextField(controller: _nameCtrl, label: 'Full Name *',
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              CustomTextField(controller: _companyCtrl, label: 'Company Name',
                  prefixIcon: Icons.business_outlined,
                  textCapitalization: TextCapitalization.words),
              const SizedBox(height: 12),
              CustomTextField(controller: _emailCtrl, label: 'Email *',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null),
              const SizedBox(height: 12),
              CustomTextField(controller: _phoneCtrl, label: 'Phone',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
            ]),
            const SizedBox(height: 16),
            _section('Address', [
              CustomTextField(controller: _addressCtrl, label: 'Street Address',
                  prefixIcon: Icons.location_on_outlined, maxLines: 2),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: CustomTextField(controller: _cityCtrl, label: 'City')),
                const SizedBox(width: 12),
                Expanded(child: CustomTextField(controller: _stateCtrl, label: 'State')),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: CustomTextField(controller: _zipCtrl, label: 'ZIP', keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: CustomTextField(controller: _countryCtrl, label: 'Country')),
              ]),
            ]),
            const SizedBox(height: 16),
            _section('Notes', [
              CustomTextField(controller: _notesCtrl, label: 'Notes', maxLines: 3,
                  hint: 'Any additional notes about this client...'),
            ]),
            const SizedBox(height: 24),
            GradientButton(
              label: widget.clientId != null ? 'Update Client' : 'Save Client',
              onPressed: _save,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
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
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
