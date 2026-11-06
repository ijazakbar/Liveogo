import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );
  const storage = FlutterSecureStorage();
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // OTP endpoints remain public; authenticated APIs receive only the
      // short-lived access token stored by the verified sign-in flow.
      if (!options.path.startsWith('/auth/')) {
        final token = await storage.read(key: 'liveogo_access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
      handler.next(options);
    },
  ));
  ref.onDispose(dio.close);
  return dio;
});
