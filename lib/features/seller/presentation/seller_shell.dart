import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import 'seller_inventory_screen.dart';

final sellerTabProvider = StateProvider<int>((ref) => 0);

class SellerShell extends ConsumerWidget {
  const SellerShell({super.key});

  static const tabs = [
    NavigationDestination(
      icon: Icon(Icons.space_dashboard_outlined),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.inventory_2_outlined),
      label: 'Inventory',
    ),
    NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      label: 'Orders',
    ),
    NavigationDestination(
      icon: Icon(Icons.videocam_outlined),
      label: 'Live Studio',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(sellerTabProvider);
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        body: IndexedStack(
          index: index,
          children: const [
            SellerDashboard(),
            SellerInventoryScreen(),
            _SellerPlaceholder(
              title: 'Orders',
              icon: Icons.receipt_long_outlined,
            ),
            _SellerPlaceholder(
              title: 'Live Studio',
              icon: Icons.videocam_outlined,
            ),
            _SellerPlaceholder(
              title: 'Settings',
              icon: Icons.settings_outlined,
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) =>
              ref.read(sellerTabProvider.notifier).state = value,
          destinations: tabs,
        ),
      ),
    );
  }
}

class SellerDashboard extends StatelessWidget {
  const SellerDashboard({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Seller Studio',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              onPressed: () => context.go('/role'),
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Switch mode',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Good morning',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black54),
            ),
            Text(
              'Your business overview',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: "Today's revenue",
                    value: '—',
                    icon: Icons.payments_outlined,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Total orders',
                    value: '—',
                    icon: Icons.shopping_bag_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales overview',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    SizedBox(height: 8),
                    Text('Connect your store data to view the last 7 days.'),
                    SizedBox(height: 40),
                    Center(
                      child: Icon(
                        Icons.show_chart,
                        size: 54,
                        color: AppTheme.purple,
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Live broadcasting will be enabled after streaming credentials are configured.',
                    ),
                  ),
                ),
                icon: const Icon(Icons.wifi_tethering),
                label: const Text('Go Live'),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: ListTile(
                leading: Icon(Icons.verified_user_outlined),
                title: Text('Complete seller verification'),
                subtitle: Text(
                  'Submit your business details to unlock selling features.',
                ),
              ),
            ),
          ],
        ),
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.purple),
              const SizedBox(height: 16),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      );
}

class _SellerPlaceholder extends StatelessWidget {
  const _SellerPlaceholder({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52, color: AppTheme.purple),
              const SizedBox(height: 12),
              Text(
                '$title workspace',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text('Feature module scaffolded for implementation.'),
              TextButton(
                onPressed: () => context.go('/role'),
                child: const Text('Switch mode'),
              ),
            ],
          ),
        ),
      );
}
