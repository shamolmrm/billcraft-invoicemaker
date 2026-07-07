import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/invoice_model.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<InvoiceProvider>();
    final business = context.watch<BusinessProvider>().business;

    return Scaffold(
      appBar: AppBar(
        title: const Text('More', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      (auth.userName ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(auth.userName ?? 'User',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text(business.name,
                            style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85))),
                        if (auth.userEmail != null)
                          Text(auth.userEmail!,
                              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: () => context.push(RouteNames.businessProfile),
                  ),
                ],
              ),
            ),

            // Quick stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _QuickStat('Total Sales', CurrencyFormatter.formatCompact(provider.totalSales), AppColors.primary, onTap: () => _showStatsDetail(context, 'sales', provider)),
                  const SizedBox(width: 8),
                  _QuickStat('Paid', CurrencyFormatter.formatCompact(provider.totalPaid), AppColors.paid, onTap: () => _showStatsDetail(context, 'paid', provider)),
                  const SizedBox(width: 8),
                  _QuickStat('Outstanding', CurrencyFormatter.formatCompact(provider.totalOutstanding), AppColors.overdue, onTap: () => _showStatsDetail(context, 'outstanding', provider)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _SectionHeader('Analytics'),
            _MenuTile(icon: Icons.bar_chart_outlined, color: AppColors.primary,
                title: 'Reports & Analytics', subtitle: 'Sales trends, top clients',
                onTap: () => context.push(RouteNames.reports)),

            _SectionHeader('Tools'),
            _MenuTile(icon: Icons.receipt_long_outlined, color: const Color(0xFF1565C0),
                title: 'Invoices', subtitle: 'Manage all invoices',
                onTap: () => context.go(RouteNames.invoiceList)),
            _MenuTile(icon: Icons.article_outlined, color: const Color(0xFF6A1B9A),
                title: 'Estimates', subtitle: 'Quotes and proposals',
                onTap: () => context.go(RouteNames.estimateList)),
            _MenuTile(icon: Icons.people_outline, color: const Color(0xFF00838F),
                title: 'Clients', subtitle: 'Client management',
                onTap: () => context.go(RouteNames.clientList)),
            _MenuTile(icon: Icons.inventory_2_outlined, color: const Color(0xFFE65100),
                title: 'Item Library', subtitle: 'Products & services',
                onTap: () => context.go(RouteNames.itemList)),

            _SectionHeader('Settings'),
            _MenuTile(icon: Icons.settings_outlined, color: AppColors.textSecondary,
                title: 'Settings', subtitle: 'App preferences',
                onTap: () => context.push(RouteNames.settings)),
            _MenuTile(icon: Icons.business_outlined, color: AppColors.primary,
                title: 'Business Profile', subtitle: 'Name, logo, address',
                onTap: () => context.push(RouteNames.businessProfile)),

            _SectionHeader('Support'),
            _MenuTile(icon: Icons.help_outline, color: const Color(0xFF2E7D32),
                title: 'Help Center', subtitle: 'FAQs and guides',
                onTap: () => _showHelp(context)),
            _MenuTile(icon: Icons.email_outlined, color: const Color(0xFF1565C0),
                title: 'Contact Support', subtitle: 'Get in touch',
                onTap: () => _showContact(context)),
            _MenuTile(icon: Icons.star_outline, color: const Color(0xFFF9A825),
                title: 'Rate BillCraft', subtitle: 'Leave a review',
                onTap: () => _showRate(context)),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
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
            const SizedBox(height: 16),
            const Text('BillCraft v1.0.0', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showStatsDetail(BuildContext context, String type, InvoiceProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    List<InvoiceModel> invoices;
    String title;
    Color color;

    switch (type) {
      case 'paid':
        invoices = provider.allInvoices.where((i) => i.amountPaid > 0).toList();
        title = 'Paid Invoices';
        color = AppColors.paid;
        break;
      case 'outstanding':
        invoices = provider.allInvoices.where((i) => i.balanceDue > 0).toList();
        title = 'Outstanding Invoices';
        color = AppColors.overdue;
        break;
      default:
        invoices = provider.allInvoices;
        title = 'Total Sales';
        color = AppColors.primary;
    }

    invoices = [...invoices]..sort((a, b) => b.issueDate.compareTo(a.issueDate));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                    child: Text('${invoices.length} invoices', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Text(
                    type == 'paid'
                      ? CurrencyFormatter.format(invoices.fold(0.0, (s, i) => s + i.amountPaid))
                      : type == 'outstanding'
                      ? CurrencyFormatter.format(invoices.fold(0.0, (s, i) => s + i.balanceDue))
                      : CurrencyFormatter.format(invoices.fold(0.0, (s, i) => s + i.total)),
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: invoices.isEmpty
                ? const Center(child: Text('No invoices found', style: TextStyle(color: AppColors.textTertiary)))
                : ListView.builder(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: invoices.length,
                    itemBuilder: (_, i) {
                      final inv = invoices[i];
                      final amount = type == 'paid' ? inv.amountPaid
                          : type == 'outstanding' ? inv.balanceDue
                          : inv.total;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                              child: Center(
                                child: Text(
                                  inv.clientName.isNotEmpty ? inv.clientName[0].toUpperCase() : '?',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(inv.clientName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                                  Text('${inv.invoiceNumber} · ${inv.issueDate.day}/${inv.issueDate.month}/${inv.issueDate.year}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                ],
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(amount),
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            const Center(child: Text('Help Center', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
            const SizedBox(height: 16),
            _HelpItem('How do I create an invoice?', 'Go to Invoices tab → tap the + button → fill in client details and items → tap Create.'),
            _HelpItem('How do I export a PDF?', 'Open any invoice → tap the Share/Export button → choose PDF or Image.'),
            _HelpItem('How do I add a client?', 'Go to Clients tab → tap + → fill in the client details → Save.'),
            _HelpItem('How do I track payments?', 'Open an invoice → tap "Record Payment" → enter the amount paid.'),
            _HelpItem('How do I change my currency?', 'Go to Settings → Currency & Taxes → select your currency.'),
            _HelpItem('How do I add my business logo?', 'Go to Settings → Business Profile → tap the logo area to upload.'),
            _HelpItem('Can I use multiple tax rates?', 'Yes — you can set per-item tax rates when creating an invoice.'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showContact(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Contact Support', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Having an issue? We\'re here to help!', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            _ContactRow(Icons.email_outlined, 'Email', 'support@billcraft.app'),
            const SizedBox(height: 8),
            _ContactRow(Icons.language_outlined, 'Website', 'www.billcraft.app'),
            const SizedBox(height: 8),
            _ContactRow(Icons.access_time_outlined, 'Response Time', 'Within 24 hours'),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showRate(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rate BillCraft ⭐', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Enjoying BillCraft? A 5-star review helps us grow and improve the app for everyone!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Later')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Play Store...'), backgroundColor: AppColors.primary),
              );
            },
            child: const Text('Rate Now ⭐'),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  const _QuickStat(this.label, this.value, this.color, {this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
          ),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textTertiary), textAlign: TextAlign.center),
              if (onTap != null) ...[
                const SizedBox(height: 2),
                Icon(Icons.arrow_forward_ios, size: 8, color: AppColors.textHint),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(title.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 0.8)),
  );
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuTile({required this.icon, required this.color, required this.title, this.subtitle, required this.onTap});

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
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: subtitle != null
            ? Text(subtitle!, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary))
            : null,
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final String question;
  final String answer;
  const _HelpItem(this.question, this.answer);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(child: Text(question, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 6),
          Text(answer, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ContactRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    ],
  );
}
