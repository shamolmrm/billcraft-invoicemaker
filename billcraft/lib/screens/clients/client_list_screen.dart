import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/client_model.dart';
import '../../providers/client_provider.dart';
import '../../widgets/common/empty_state.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});
  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  bool _searching = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientProvider>();
    final clients = provider.clients;
    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Search clients...', border: InputBorder.none, filled: false),
                onChanged: provider.setSearch,
              )
            : const Text('Clients', style: TextStyle(fontWeight: FontWeight.w700)),
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
      body: clients.isEmpty
          ? EmptyState(
              emoji: '👥',
              title: 'No clients yet',
              subtitle: 'Add your first client to start creating invoices',
              buttonLabel: '+ Add Client',
              onButtonTap: () => context.push(RouteNames.addClient),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: clients.length,
              itemBuilder: (ctx, i) => _ClientCard(
                client: clients[i],
                onTap: () => context.push('${RouteNames.clientDetail}/${clients[i].id}'),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.addClient),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add_outlined, color: Colors.white),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final ClientModel client;
  final VoidCallback? onTap;
  const _ClientCard({required this.client, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.card,
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryContainer,
              child: Text(client.initials,
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(client.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  if (client.company != null)
                    Text(client.company!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text(client.email, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(CurrencyFormatter.format(client.totalInvoiced),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Text('Total invoiced', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                if (client.outstanding > 0) ...[
                  const SizedBox(height: 2),
                  Text(CurrencyFormatter.format(client.outstanding),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.overdue)),
                  const Text('Outstanding', style: TextStyle(fontSize: 10, color: AppColors.overdue)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
