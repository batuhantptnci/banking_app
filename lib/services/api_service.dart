import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.16:8080';

  static String? accessToken;
  static String? refreshToken;

  static Future<String> getHello() async {
    final response = await http
        .get(
      Uri.parse('$baseUrl/api/hello'),
    )
        .timeout(
      const Duration(seconds: 5),
    );

    if (response.statusCode == 200) {
      return response.body;
    }

    throw Exception(
      'Backend hatası: ${response.statusCode}',
    );
  }

  static Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    )
        .timeout(
      const Duration(seconds: 10),
    );

    final Map<String, dynamic> body =
    jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      accessToken = body['token'] as String?;
      refreshToken = body['refreshToken'] as String?;

      final user = body['user'] as Map<String, dynamic>;

      return user['fullName'] as String;
    }

    if (response.statusCode == 401) {
      throw Exception(
        body['message'] ?? 'Email veya şifre hatalı',
      );
    }

    if (response.statusCode == 400) {
      throw Exception(
        body.values.isNotEmpty
            ? body.values.first.toString()
            : 'Bilgileri kontrol et',
      );
    }

    throw Exception(
      'Giriş yapılamadı (${response.statusCode})',
    );
  }
}