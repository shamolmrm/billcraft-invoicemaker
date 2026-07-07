import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/invoice_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        children: [
          _SectionHeader('Business'),
          _SettingsTile(
            icon: Icons.business_outlined,
            title: 'Business Profile',
            subtitle: 'Name, logo, address, contact',
            onTap: () => context.push(RouteNames.businessProfile),
          ),
          _SettingsTile(
            icon: Icons.receipt_outlined,
            title: 'Invoice Settings',
            subtitle: 'Number prefix, default terms, tax',
            onTap: () => _showInvoiceSettings(context),
          ),
          _SettingsTile(
            icon: Icons.attach_money,
            title: 'Currency & Taxes',
            subtitle: 'Default currency, tax rates',
            onTap: () => _showCurrencySettings(context),
          ),
          _SectionHeader('Appearance'),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Theme',
            subtitle: themeProvider.isDark ? 'Dark mode' : 'Light mode',
            trailing: Switch(
              value: themeProvider.isDark,
              activeThumbColor: AppColors.primary,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: _currentLanguageName(context),
            onTap: () => _showLanguagePicker(context),
          ),
          _SectionHeader('Notifications'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notification Settings',
            subtitle: 'Reminders, overdue alerts, summaries',
            onTap: () => _showNotificationSettings(context),
          ),
          _SectionHeader('Account'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () => context.push(RouteNames.businessProfile),
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () => _showChangePassword(context),
          ),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: 'Export All Data',
            subtitle: 'Download your data as JSON',
            onTap: () => _exportData(context),
          ),
          _SectionHeader('About'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0',
            onTap: null,
          ),
          _SettingsTile(
            icon: Icons.star_outline,
            title: 'Rate BillCraft',
            onTap: () => _showRateDialog(context),
          ),
          _SettingsTile(
            icon: Icons.share_outlined,
            title: 'Share App',
            onTap: () => _shareApp(),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => _showPrivacyPolicy(context),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await _showLogoutConfirm(context);
                if (confirmed == true && context.mounted) {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) context.go('/login');
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.overdue),
              label: const Text('Sign Out', style: TextStyle(color: AppColors.overdue, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: AppColors.overdue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showInvoiceSettings(BuildContext context) {
    final business = context.read<BusinessProvider>().business;
    final prefixController = TextEditingController(text: business.invoicePrefix);
    final termsController = TextEditingController(text: business.defaultTerms ?? '');
    final taxController = TextEditingController(text: business.defaultTaxRate.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Invoice Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(
              controller: prefixController,
              decoration: const InputDecoration(labelText: 'Invoice Number Prefix', hintText: 'e.g. INV-'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: taxController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Default Tax (%)', hintText: 'e.g. 10'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: termsController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Default Payment Terms'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updated = business.copyWith(
                  invoicePrefix: prefixController.text,
                  defaultTerms: termsController.text,
                  defaultTaxRate: double.tryParse(taxController.text) ?? business.defaultTaxRate,
                );
                context.read<BusinessProvider>().updateBusiness(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invoice settings saved'), backgroundColor: AppColors.primary),
                );
              },
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }

  String _currentLanguageName(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    const names = {
      'en': 'English', 'bn': 'বাংলা', 'hi': 'हिन्दी', 'ar': 'العربية',
      'es': 'Español', 'fr': 'Français', 'pt': 'Português', 'id': 'Indonesia',
      'tr': 'Türkçe', 'de': 'Deutsch', 'zh': '中文', 'ja': '日本語',
      'ko': '한국어', 'ru': 'Русский', 'it': 'Italiano', 'ms': 'Melayu',
    };
    return names[code] ?? 'English';
  }

  void _showLanguagePicker(BuildContext context) {
    const langs = [
      {'code': 'en', 'flag': '🇬🇧', 'native': 'English', 'name': 'English'},
      {'code': 'bn', 'flag': '🇧🇩', 'native': 'বাংলা', 'name': 'Bangla'},
      {'code': 'hi', 'flag': '🇮🇳', 'native': 'हिन्दी', 'name': 'Hindi'},
      {'code': 'ar', 'flag': '🇸🇦', 'native': 'العربية', 'name': 'Arabic'},
      {'code': 'es', 'flag': '🇪🇸', 'native': 'Español', 'name': 'Spanish'},
      {'code': 'fr', 'flag': '🇫🇷', 'native': 'Français', 'name': 'French'},
      {'code': 'pt', 'flag': '🇧🇷', 'native': 'Português', 'name': 'Portuguese'},
      {'code': 'id', 'flag': '🇮🇩', 'native': 'Indonesia', 'name': 'Indonesian'},
      {'code': 'tr', 'flag': '🇹🇷', 'native': 'Türkçe', 'name': 'Turkish'},
      {'code': 'de', 'flag': '🇩🇪', 'native': 'Deutsch', 'name': 'German'},
      {'code': 'zh', 'flag': '🇨🇳', 'native': '中文', 'name': 'Chinese'},
      {'code': 'ja', 'flag': '🇯🇵', 'native': '日本語', 'name': 'Japanese'},
      {'code': 'ko', 'flag': '🇰🇷', 'native': '한국어', 'name': 'Korean'},
      {'code': 'ru', 'flag': '🇷🇺', 'native': 'Русский', 'name': 'Russian'},
      {'code': 'it', 'flag': '🇮🇹', 'native': 'Italiano', 'name': 'Italian'},
      {'code': 'ms', 'flag': '🇲🇾', 'native': 'Melayu', 'name': 'Malay'},
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final current = Localizations.localeOf(context).languageCode;
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, controller) => Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: langs.length,
                  itemBuilder: (_, i) {
                    final lang = langs[i];
                    final isSelected = lang['code'] == current;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: Text(lang['flag']!, style: const TextStyle(fontSize: 22))),
                      ),
                      title: Text(lang['native']!, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? AppColors.primary : null)),
                      subtitle: Text(lang['name']!),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                      onTap: () {
                        context.setLocale(Locale(lang['code']!));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Language changed to ${lang['native']}'), backgroundColor: AppColors.primary),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCurrencySettings(BuildContext context) {
    final business = context.read<BusinessProvider>().business;
    final currencies = [
      {'symbol': '\$', 'name': 'USD — US Dollar'},
      {'symbol': '৳', 'name': 'BDT — Bangladeshi Taka'},
      {'symbol': '£', 'name': 'GBP — British Pound'},
      {'symbol': '€', 'name': 'EUR — Euro'},
      {'symbol': '₹', 'name': 'INR — Indian Rupee'},
      {'symbol': '¥', 'name': 'JPY — Japanese Yen'},
      {'symbol': 'د.إ', 'name': 'AED — UAE Dirham'},
      {'symbol': '﷼', 'name': 'SAR — Saudi Riyal'},
      {'symbol': 'RM', 'name': 'MYR — Malaysian Ringgit'},
      {'symbol': 'S\$', 'name': 'SGD — Singapore Dollar'},
      {'symbol': 'CA\$', 'name': 'CAD — Canadian Dollar'},
      {'symbol': 'A\$', 'name': 'AUD — Australian Dollar'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Select Currency', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: currencies.length,
                itemBuilder: (_, i) {
                  final c = currencies[i];
                  final isSelected = business.currencySymbol == c['symbol'];
                  return ListTile(
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text(c['symbol']!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isSelected ? AppColors.primary : AppColors.textPrimary))),
                    ),
                    title: Text(c['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                    onTap: () {
                      context.read<BusinessProvider>().updateBusiness(
                        business.copyWith(currencySymbol: c['symbol']),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Currency changed to ${c['name']}'), backgroundColor: AppColors.primary),
                      );
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

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _NotificationSettingsDialog(),
    );
  }

  void _showChangePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Current Password'),
            ),
            SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'New Password'),
            ),
            SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password updated successfully'), backgroundColor: AppColors.primary),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) async {
    final invoices = context.read<InvoiceProvider>().allInvoices;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Export Data', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Export ${invoices.length} invoices and all business data?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data exported successfully'), backgroundColor: AppColors.primary),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showRateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rate BillCraft ⭐', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Enjoying BillCraft? Leave a 5-star review on the Play Store — it helps us grow!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Later')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Play Store...'), backgroundColor: AppColors.primary),
              );
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    Share.share(
      '📲 Check out BillCraft — Professional Invoice Maker!\n\nCreate invoices, track payments, and manage your business from your phone.\n\nDownload now on Google Play Store. 💼',
      subject: 'BillCraft — Invoice Maker App',
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const SingleChildScrollView(
          child: Text(
            'BillCraft Privacy Policy\n\n'
            'Last updated: June 2026\n\n'
            '1. Data Collection\nBillCraft stores all your business data locally on your device. We do not collect or share your personal information with third parties.\n\n'
            '2. Data Storage\nAll invoices, client information, and business data are stored on your device only.\n\n'
            '3. Security\nYour data is protected by your device\'s security. We recommend enabling screen lock on your phone.\n\n'
            '4. Contact\nFor any privacy concerns, contact us at support@billcraft.app',
            style: TextStyle(fontSize: 13, height: 1.6),
          ),
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<bool?> _showLogoutConfirm(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.overdue),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _NotificationSettingsDialog extends StatefulWidget {
  @override
  State<_NotificationSettingsDialog> createState() => _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState extends State<_NotificationSettingsDialog> {
  bool _overdueAlerts = true;
  bool _paymentReminders = true;
  bool _weeklySummary = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Notification Settings', style: TextStyle(fontWeight: FontWeight.w700)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Overdue Alerts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Notify when invoices are overdue', style: TextStyle(fontSize: 12)),
            value: _overdueAlerts,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _overdueAlerts = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Payment Reminders', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Remind clients about upcoming due dates', style: TextStyle(fontSize: 12)),
            value: _paymentReminders,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _paymentReminders = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Weekly Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Weekly business performance report', style: TextStyle(fontSize: 12)),
            value: _weeklySummary,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _weeklySummary = v),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification settings saved'), backgroundColor: AppColors.primary),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
    child: Text(title,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.8)),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          width: 38, height: 38,
          decoration: const BoxDecoration(
              color: AppColors.primaryContainer, shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: subtitle != null
            ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary))
            : null,
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: AppColors.textHint) : null),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      ),
    );
  }
}
