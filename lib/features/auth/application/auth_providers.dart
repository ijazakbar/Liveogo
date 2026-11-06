import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/dio_provider.dart';
import '../data/auth_repository.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(dioProvider)),
);

final accessTokenProvider = FutureProvider<String?>(
  (ref) => ref.watch(secureStorageProvider).read(key: 'liveogo_access_token'),
);

Future<void> persistAuthSession(
  WidgetRef ref, {
  required AuthSession session,
}) async {
  final storage = ref.read(secureStorageProvider);
  await storage.write(key: 'liveogo_access_token', value: session.accessToken);
  await storage.write(key: 'liveogo_refresh_token', value: session.refreshToken);
  ref.invalidate(accessTokenProvider);
}

Future<void> clearAuthSession(WidgetRef ref) async {
  final storage = ref.read(secureStorageProvider);
  await storage.delete(key: 'liveogo_access_token');
  await storage.delete(key: 'liveogo_refresh_token');
  ref.invalidate(accessTokenProvider);
}
