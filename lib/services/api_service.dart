import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.16:8080';

  // Telefonda tokenları güvenli şekilde saklayacağımız alan.
  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Uygulama açıkken hızlı erişmek için RAM'de de tutuyoruz.
  static String? accessToken;
  static String? refreshToken;

  // ---------------------------------------------------------------------------
  // TEST ENDPOINT
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // LOGIN
  // ---------------------------------------------------------------------------

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

    Map<String, dynamic> body = {};

    if (response.body.isNotEmpty) {
      body = jsonDecode(response.body)
      as Map<String, dynamic>;
    }

    if (response.statusCode == 200) {
      accessToken = body['token'] as String?;
      refreshToken =
      body['refreshToken'] as String?;

      if (accessToken == null ||
          refreshToken == null) {
        throw Exception(
          'Sunucudan token alınamadı.',
        );
      }

      // TOKENLARI TELEFONA GÜVENLİ ŞEKİLDE KAYDET
      await _storage.write(
        key: _accessTokenKey,
        value: accessToken,
      );

      await _storage.write(
        key: _refreshTokenKey,
        value: refreshToken,
      );

      final user =
      body['user'] as Map<String, dynamic>;

      return user['fullName'] as String;
    }

    if (response.statusCode == 401) {
      throw Exception(
        body['message'] ??
            'Email veya şifre hatalı',
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

  // ---------------------------------------------------------------------------
  // TELEFONDA KAYITLI TOKENLARI YÜKLE
  // ---------------------------------------------------------------------------

  static Future<void> loadTokens() async {
    accessToken = await _storage.read(
      key: _accessTokenKey,
    );

    refreshToken = await _storage.read(
      key: _refreshTokenKey,
    );
  }

  // ---------------------------------------------------------------------------
  // KULLANICI GİRİŞ YAPMIŞ MI?
  // ---------------------------------------------------------------------------

  static Future<bool> isLoggedIn() async {
    await loadTokens();

    return accessToken != null &&
        accessToken!.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // AUTHORIZATION HEADER
  // ---------------------------------------------------------------------------

  static Future<Map<String, String>>
  authHeaders() async {
    if (accessToken == null) {
      await loadTokens();
    }

    if (accessToken == null) {
      throw Exception(
        'Oturum bulunamadı.',
      );
    }

    return {
      'Content-Type': 'application/json',
      'Authorization':
      'Bearer $accessToken',
    };
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------

  static Future<void> logout() async {
    accessToken = null;
    refreshToken = null;

    await _storage.delete(
      key: _accessTokenKey,
    );

    await _storage.delete(
      key: _refreshTokenKey,
    );
  }
}