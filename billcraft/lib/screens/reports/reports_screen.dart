import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/invoice_provider.dart';
import '../../models/invoice_model.dart';
import '../../widgets/cards/stats_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _periodIndex = 1;

  DateTimeRange _getRange() {
    final now = DateTime.now();
    switch (_periodIndex) {
      case 0: // Week
        return DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );
      case 1: // Month
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
      case 2: // Quarter
        return DateTimeRange(
          start: now.subtract(const Duration(days: 90)),
          end: now,
        );
      case 3: // Year
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: now,
        );
      default:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
    }
  }

  List<InvoiceModel> _filtered(List<InvoiceModel> all) {
    final r = _getRange();
    return all.where((i) =>
        !i.issueDate.isBefore(r.start) && !i.issueDate.isAfter(r.end)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvoiceProvider>();
    final filtered = _filtered(provider.allInvoices);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PeriodSelector(current: _periodIndex, onChanged: (i) => setState(() => _periodIndex = i)),
            const SizedBox(height: 16),
            _buildSummaryCards(filtered),
            const SizedBox(height: 20),
            _buildSalesChart(filtered),
            const SizedBox(height: 20),
            _buildStatusBreakdown(filtered),
            const SizedBox(height: 20),
            _buildTopClients(filtered),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(List<InvoiceModel> invoices) {
    final totalSales = invoices.fold(0.0, (s, i) => s + i.total);
    final totalPaid = invoices.fold(0.0, (s, i) => s + i.amountPaid);
    final totalOutstanding = invoices.fold(0.0, (s, i) => s + i.balanceDue);
    final totalOverdue = invoices
        .where((i) => i.status == InvoiceStatus.overdue)
        .fold(0.0, (s, i) => s + i.balanceDue);

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: StatsCard(
              title: 'Total Sales', amount: totalSales,
              gradient: const [Color(0xFF00897B), Color(0xFF26A69A)],
              icon: Icons.trending_up,
            )),
            const SizedBox(width: 12),
            Expanded(child: StatsCard(
              title: 'Total Paid', amount: totalPaid,
              gradient: const [Color(0xFF2E7D32), Color(0xFF43A047)],
              icon: Icons.check_circle_outline,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: StatsCard(
              title: 'Outstanding', amount: totalOutstanding,
              gradient: const [Color(0xFFE65100), Color(0xFFFF6D00)],
              icon: Icons.hourglass_empty_outlined,
            )),
            const SizedBox(width: 12),
            Expanded(child: StatsCard(
              title: 'Overdue', amount: totalOverdue,
              gradient: const [Color(0xFFC62828), Color(0xFFE53935)],
              icon: Icons.warning_amber_outlined,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildSalesChart(List<InvoiceModel> invoices) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    List<FlSpot> spots;
    List<String> labels;

    if (_periodIndex == 0) {
      // Week: last 7 days
      labels = List.generate(7, (i) {
        final d = now.subtract(Duration(days: 6 - i));
        const days = ['Mo','Tu','We','Th','Fr','Sa','Su'];
        return days[d.weekday - 1];
      });
      spots = List.generate(7, (i) {
        final d = now.subtract(Duration(days: 6 - i));
        final total = invoices
            .where((inv) => inv.issueDate.year == d.year &&
                inv.issueDate.month == d.month &&
                inv.issueDate.day == d.day)
            .fold(0.0, (s, inv) => s + inv.total);
        return FlSpot(i.toDouble(), total / 1000);
      });
    } else if (_periodIndex == 1) {
      // Month: days 1-31
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      labels = List.generate(daysInMonth, (i) => '${i + 1}');
      spots = List.generate(daysInMonth, (i) {
        final total = invoices
            .where((inv) => inv.issueDate.day == i + 1)
            .fold(0.0, (s, inv) => s + inv.total);
        return FlSpot(i.toDouble(), total / 1000);
      });
    } else if (_periodIndex == 2) {
      // Quarter: last 3 months
      labels = List.generate(3, (i) {
        final m = DateTime(now.year, now.month - 2 + i);
        const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        return months[m.month - 1];
      });
      spots = List.generate(3, (i) {
        final m = DateTime(now.year, now.month - 2 + i);
        final total = invoices
            .where((inv) => inv.issueDate.month == m.month && inv.issueDate.year == m.year)
            .fold(0.0, (s, inv) => s + inv.total);
        return FlSpot(i.toDouble(), total / 1000);
      });
    } else {
      // Year: 12 months
      const months = ['J','F','M','A','M','J','J','A','S','O','N','D'];
      labels = months;
      spots = List.generate(12, (i) {
        final total = invoices
            .where((inv) => inv.issueDate.month == i + 1 && inv.issueDate.year == now.year)
            .fold(0.0, (s, inv) => s + inv.total);
        return FlSpot(i.toDouble(), total / 1000);
      });
    }

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
          Text(
            _periodIndex == 0 ? 'Daily Sales (This Week)'
              : _periodIndex == 1 ? 'Daily Sales (This Month)'
              : _periodIndex == 2 ? 'Monthly Sales (Quarter)'
              : 'Monthly Sales (This Year)',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text('(in thousands)', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 0.5),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text('\$${v.toStringAsFixed(0)}k',
                          style: const TextStyle(fontSize: 9, color: AppColors.textTertiary)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _periodIndex == 1 ? 5 : 1,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= labels.length) return const SizedBox();
                        return Text(labels[i], style: const TextStyle(fontSize: 9, color: AppColors.textTertiary));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown(List<InvoiceModel> invoices) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final counts = {
      InvoiceStatus.paid: invoices.where((i) => i.status == InvoiceStatus.paid).length,
      InvoiceStatus.unpaid: invoices.where((i) => i.status == InvoiceStatus.unpaid).length,
      InvoiceStatus.partiallyPaid: invoices.where((i) => i.status == InvoiceStatus.partiallyPaid).length,
      InvoiceStatus.overdue: invoices.where((i) => i.status == InvoiceStatus.overdue).length,
    };
    final total = invoices.length;

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
          const Text('Invoice Status Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          if (invoices.isNotEmpty && total > 0)
            SizedBox(
              height: 160,
              child: PieChart(PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  if (counts[InvoiceStatus.paid]! > 0)
                    PieChartSectionData(value: counts[InvoiceStatus.paid]!.toDouble(), color: AppColors.paid, title: '${counts[InvoiceStatus.paid]}', radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                  if (counts[InvoiceStatus.unpaid]! > 0)
                    PieChartSectionData(value: counts[InvoiceStatus.unpaid]!.toDouble(), color: AppColors.unpaid, title: '${counts[InvoiceStatus.unpaid]}', radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                  if (counts[InvoiceStatus.partiallyPaid]! > 0)
                    PieChartSectionData(value: counts[InvoiceStatus.partiallyPaid]!.toDouble(), color: AppColors.partiallyPaid, title: '${counts[InvoiceStatus.partiallyPaid]}', radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                  if (counts[InvoiceStatus.overdue]! > 0)
                    PieChartSectionData(value: counts[InvoiceStatus.overdue]!.toDouble(), color: AppColors.overdue, title: '${counts[InvoiceStatus.overdue]}', radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              )),
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No invoices in this period', style: TextStyle(color: AppColors.textTertiary)),
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _Legend('Paid (${counts[InvoiceStatus.paid]})', AppColors.paid),
              _Legend('Unpaid (${counts[InvoiceStatus.unpaid]})', AppColors.unpaid),
              _Legend('Partial (${counts[InvoiceStatus.partiallyPaid]})', AppColors.partiallyPaid),
              _Legend('Overdue (${counts[InvoiceStatus.overdue]})', AppColors.overdue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopClients(List<InvoiceModel> invoices) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clientMap = <String, double>{};
    for (final inv in invoices) {
      clientMap[inv.clientName] = (clientMap[inv.clientName] ?? 0) + inv.total;
    }
    final sorted = clientMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();
    final maxVal = top5.isNotEmpty ? top5.first.value : 1;

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
          const Text('Top Clients by Revenue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          if (top5.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No data for this period', style: TextStyle(color: AppColors.textTertiary)),
              ),
            )
          else
            ...top5.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(e.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                      Text(CurrencyFormatter.format(e.value),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: e.value / maxVal,
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final Color color;
  const _Legend(this.label, this.color);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11)),
    ],
  );
}

class _PeriodSelector extends StatelessWidget {
  final int current;
  final void Function(int) onChanged;
  const _PeriodSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const periods = ['Week', 'Month', 'Quarter', 'Year'];
    return Row(
      children: periods.asMap().entries.map((e) {
        final isActive = e.key == current;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: e.key < periods.length - 1 ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isActive ? AppColors.primary : AppColors.border),
              ),
              child: Text(e.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppColors.textSecondary)),
            ),
          ),
        );
      }).toList(),
    );
  }
}
