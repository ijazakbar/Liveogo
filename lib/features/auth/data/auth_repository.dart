import 'package:dio/dio.dart';

class OtpRequestResult {
  const OtpRequestResult({required this.challengeId, required this.expiresInSeconds});
  final String challengeId;
  final int expiresInSeconds;

  factory OtpRequestResult.fromJson(Map<String, dynamic> json) {
    final id = json['challenge_id'];
    final expiry = json['expires_in'];
    if (id is! String || id.trim().isEmpty || expiry is! num || expiry <= 0) {
      throw const FormatException('OTP service returned an invalid challenge.');
    }
    return OtpRequestResult(challengeId: id, expiresInSeconds: expiry.toInt());
  }
}

class AuthSession {
  const AuthSession({required this.accessToken, required this.refreshToken});
  final String accessToken;
  final String refreshToken;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final access = json['access_token'];
    final refresh = json['refresh_token'];
    if (access is! String || access.isEmpty || refresh is! String || refresh.isEmpty) {
      throw const FormatException('Authentication service returned an invalid session.');
    }
    return AuthSession(accessToken: access, refreshToken: refresh);
  }
}

/// Backend-driven phone OTP. The client never treats an OTP request as a login.
class AuthRepository {
  const AuthRepository(this._dio);
  final Dio _dio;

  Future<OtpRequestResult> requestOtp(String phoneE164) async {
    final response = await _dio.post<dynamic>('/auth/phone/otp/request',
      data: {'phone_number': phoneE164});
    if (response.data is! Map<String, dynamic>) {
      throw const FormatException('Invalid OTP request response.');
    }
    return OtpRequestResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthSession> verifyOtp({
    required String phoneE164,
    required String challengeId,
    required String code,
  }) async {
    final response = await _dio.post<dynamic>('/auth/phone/otp/verify',
      data: {'phone_number': phoneE164, 'challenge_id': challengeId, 'code': code});
    if (response.data is! Map<String, dynamic>) {
      throw const FormatException('Invalid OTP verification response.');
    }
    return AuthSession.fromJson(response.data as Map<String, dynamic>);
  }
}
