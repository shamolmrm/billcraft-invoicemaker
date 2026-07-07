import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/business_provider.dart';
import '../../models/invoice_model.dart';
import '../../widgets/common/status_badge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvoiceProvider>();
    final business = context.watch<BusinessProvider>().business;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final today = DateTime.now();
    final todayInvoices = provider.invoices.where((i) =>
        i.issueDate.year == today.year &&
        i.issueDate.month == today.month &&
        i.issueDate.day == today.day).toList();
    final todayIncome = todayInvoices.fold(0.0, (s, i) => s + i.amountPaid);
    final todayTotal = todayInvoices.fold(0.0, (s, i) => s + i.total);

    final recent = [...provider.invoices]
      ..sort((a, b) => b.issueDate.compareTo(a.issueDate));
    final recentList = recent.take(10).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F7FA),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
        slivers: [
          // Top header
          SliverToBoxAdapter(child: _buildHeader(context, business.name, isDark)),
          // Balance card
          SliverToBoxAdapter(child: _buildBalanceCard(context, provider, isDark)),
          // Today stats
          SliverToBoxAdapter(child: _buildTodayStats(context, todayIncome, todayTotal, isDark)),
          // Quick actions
          SliverToBoxAdapter(child: _buildQuickActions(context)),
          // Recent transactions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Transactions',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: () => context.go(RouteNames.invoiceList),
                    child: const Text('See All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
          if (recentList.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No transactions yet', style: TextStyle(color: AppColors.textTertiary)),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _TransactionTile(invoice: recentList[i]),
                childCount: recentList.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String businessName, bool isDark) {
    final greeting = DateFormatter.greetingTime();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: const TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                Text(businessName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push(RouteNames.businessProfile),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.business_outlined, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, InvoiceProvider p, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              const Text('Total Outstanding', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${p.invoices.length} invoices',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(p.totalOutstanding),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _BalanceStat('Total Sales', p.totalSales),
              _divider(),
              _BalanceStat('Collected', p.totalPaid),
              _divider(),
              _BalanceStat('Overdue', p.totalOverdue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.2), margin: const EdgeInsets.symmetric(horizontal: 12));

  Widget _buildTodayStats(BuildContext context, double income, double total, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _TodayCard("Today's Income", income, Icons.trending_up_rounded, AppColors.paid, isDark)),
          const SizedBox(width: 12),
          Expanded(child: _TodayCard("Today's Total", total, Icons.receipt_long_outlined, AppColors.primary, isDark)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _QuickAction(Icons.add_circle_outline, 'New Invoice', AppColors.primary,
              () => context.push(RouteNames.createInvoice)),
          _QuickAction(Icons.description_outlined, 'Estimate', const Color(0xFF6A1B9A),
              () => context.push(RouteNames.createEstimate)),
          _QuickAction(Icons.people_outline, 'Client', const Color(0xFF00838F),
              () => context.push(RouteNames.addClient)),
          _QuickAction(Icons.bar_chart_outlined, 'Reports', const Color(0xFFE65100),
              () => context.push(RouteNames.reports)),
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final double value;
  const _BalanceStat(this.label, this.value);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(CurrencyFormatter.formatCompact(value),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70), textAlign: TextAlign.center),
      ],
    ),
  );
}

class _TodayCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final bool isDark;
  const _TodayCard(this.title, this.value, this.icon, this.color, this.isDark);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkSurface : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
    ),
    child: Row(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(CurrencyFormatter.formatCompact(value),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
              Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final InvoiceModel invoice;
  const _TransactionTile({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push('${RouteNames.invoiceDetail}/${invoice.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  invoice.clientName.isNotEmpty ? invoice.clientName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(invoice.clientName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(invoice.invoiceNumber,
                          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                      const SizedBox(width: 6),
                      Text('• ${DateFormatter.formatMedium(invoice.issueDate)}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                    ],
                  ),
                ],
              ),
            ),
            // Amount + status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(invoice.total),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                StatusBadge(status: invoice.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
