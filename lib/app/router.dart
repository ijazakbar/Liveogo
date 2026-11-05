import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/auth_screens.dart';
import '../features/buyer/presentation/buyer_shell.dart';
import '../features/seller/presentation/seller_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/role', builder: (context, state) => const RoleSelectionScreen()),
      GoRoute(path: '/buyer', builder: (context, state) => const BuyerShell()),
      GoRoute(path: '/seller', builder: (context, state) => const SellerShell()),
    ],
  );
});
