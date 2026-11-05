import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) context.go('/onboarding');
    });
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 76, height: 76, decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.purple, AppTheme.blue]),
        borderRadius: BorderRadius.circular(24)),
        child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 38)),
      const SizedBox(height: 18),
      Text('LiveOgo', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      const Text('Your business. Live to everyone.')
    ])),
  );
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Spacer(),
        Container(height: 220, width: double.infinity, decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF21134B), Color(0xFF1766A5)]),
          borderRadius: BorderRadius.circular(28)),
          child: const Icon(Icons.live_tv_rounded, color: Colors.white, size: 90)),
        const SizedBox(height: 32),
        Text('Commerce comes alive.', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Text('Discover businesses, watch live product demos, connect with sellers and shop in one seamless experience.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).hintColor, height: 1.5)),
        const Spacer(),
        SizedBox(width: double.infinity, child: FilledButton(
          onPressed: () => context.go('/login'),
          child: const Padding(padding: EdgeInsets.all(14), child: Text('Get started')))),
        const SizedBox(height: 12),
      ]))),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final phone = TextEditingController();
  @override
  void dispose() { phone.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Welcome to LiveOgo', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text('Enter your mobile number to continue. OTP delivery is enabled after Firebase credentials are configured.'),
        const SizedBox(height: 28),
        TextField(controller: phone, keyboardType: TextInputType.phone,
          decoration: const InputDecoration(prefixText: '+92 ', labelText: 'Phone number', hintText: '3XX XXXXXXX')),
        const Spacer(),
        SizedBox(width: double.infinity, child: FilledButton(
          onPressed: () {
            if (phone.text.trim().length < 9) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid phone number.')));
              return;
            }
            context.go('/role');
          },
          child: const Padding(padding: EdgeInsets.all(14), child: Text('Continue')))),
      ]))),
  );
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Choose your experience')),
    body: Padding(padding: const EdgeInsets.all(24), child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 18),
        Text('How will you use LiveOgo?', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('You can switch between Buyer and Seller modes later.'),
        const SizedBox(height: 28),
        _RoleCard(icon: Icons.shopping_bag_outlined, title: 'I want to Shop', subtitle: 'Discover products, watch live sellers and order.', onTap: () => context.go('/buyer')),
        const SizedBox(height: 16),
        _RoleCard(icon: Icons.storefront_outlined, title: 'I want to Sell', subtitle: 'Manage your business, inventory and live sales.', onTap: () => context.go('/seller')),
      ])),
  );
}
class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(child: InkWell(
    borderRadius: BorderRadius.circular(20), onTap: onTap,
    child: Padding(padding: const EdgeInsets.all(22), child: Row(children: [
      CircleAvatar(radius: 26, backgroundColor: AppTheme.purple.withValues(alpha: .12),
        child: Icon(icon, color: AppTheme.purple)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        const SizedBox(height: 5), Text(subtitle, style: TextStyle(color: Theme.of(context).hintColor)),
      ])),
      const Icon(Icons.arrow_forward_ios_rounded, size: 16),
    ]))));
}
