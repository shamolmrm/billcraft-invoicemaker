import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/item_model.dart';
import '../../providers/item_provider.dart';
import '../../widgets/common/empty_state.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});
  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  bool _searching = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();
    final items = provider.items;
    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Search items...', border: InputBorder.none, filled: false),
                onChanged: provider.setSearch,
              )
            : const Text('Items', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _searching = !_searching);
              if (!_searching) { _searchCtrl.clear(); provider.setSearch(''); }
            },
          ),
        ],
      ),
      body: items.isEmpty
          ? EmptyState(
              emoji: '📦',
              title: 'No items yet',
              subtitle: 'Add products or services to your library for quick invoice creation',
              buttonLabel: '+ Add Item',
              onButtonTap: () => context.push(RouteNames.addItem),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: items.length,
              itemBuilder: (ctx, i) => _ItemCard(
                item: items[i],
                onTap: () => context.push(RouteNames.addItem, extra: {'itemId': items[i].id}),
                onDelete: () => provider.deleteItem(items[i].id),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.addItem),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  const _ItemCard({required this.item, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.card,
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  if (item.description != null)
                    Text(item.description!, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(item.unit, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ),
                      if (item.category != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(item.category!, style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                        ),
                      ],
                      if (item.taxRate != null && item.taxRate! > 0) ...[
                        const SizedBox(width: 6),
                        Text('${item.taxRate}% tax', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(CurrencyFormatter.format(item.price),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                const Text('per unit', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
