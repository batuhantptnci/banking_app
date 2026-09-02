import 'dart:convert';

import 'package:banking_app/models/recipient_model.dart';
import 'package:banking_app/models/account_model.dart';
import 'package:banking_app/models/transaction_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class RegisterResult {
  final String fullName;
  final String customerNumber;

  const RegisterResult({required this.fullName, required this.customerNumber});
}

class ApiService {
  static const String baseUrl = 'http://192.168.1.16:8080';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _fullNameKey = 'user_full_name';

  static String? accessToken;
  static String? refreshToken;

  // ===========================================================================
  // TEST
  // ===========================================================================

  static Future<String> getHello() async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/hello'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return response.body;
    }

    throw Exception('Backend hatası: ${response.statusCode}');
  }

  // ===========================================================================
  // LOGIN
  // ===========================================================================

  static Future<String> login({
    required String identifier,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'identifier': identifier.trim(),
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final body = _decodeBody(response);

    if (response.statusCode == 200) {
      await _saveAuthResponse(body);

      final user = body['user'] as Map<String, dynamic>;

      return user['fullName'] as String? ?? 'IBT Bank Müşterisi';
    }

    throw Exception(
      _extractError(
        body,
        fallback: 'Müşteri no / T.C. kimlik no veya şifre hatalı',
      ),
    );
  }

  // ===========================================================================
  // REGISTER
  // ===========================================================================

  static Future<RegisterResult> register({
    required String fullName,
    required String nationalId,
    required String phone,
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'fullName': fullName.trim(),
            'nationalId': nationalId.trim(),
            'phone': phone.trim(),
            'email': email.trim(),
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final body = _decodeBody(response);

    if (response.statusCode == 201) {
      await _saveAuthResponse(body);

      final user = body['user'] as Map<String, dynamic>;

      final customerNumber = user['customerNumber']?.toString();

      if (customerNumber == null || customerNumber.isEmpty) {
        throw Exception('Müşteri numarası alınamadı.');
      }

      return RegisterResult(
        fullName: user['fullName']?.toString() ?? fullName.trim(),
        customerNumber: customerNumber,
      );
    }

    throw Exception(
      _extractError(
        body,
        fallback: 'Hesap oluşturulamadı (${response.statusCode})',
      ),
    );
  }

  // ===========================================================================
  // REFRESH TOKEN
  // ===========================================================================

  static Future<bool> refreshSession() async {
    if (refreshToken == null) {
      await loadTokens();
    }

    if (refreshToken == null || refreshToken!.isEmpty) {
      await logout();
      return false;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = _decodeBody(response);

        await _saveAuthResponse(body);

        return true;
      }

      if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403) {
        await logout();
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  // ===========================================================================
  // ACCOUNTS
  // ===========================================================================

  static Future<List<AccountModel>> getMyAccounts() async {
    final response = await authenticatedGet('/api/accounts/me');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Geçersiz hesap verisi.');
      }

      return decoded
          .map((item) => AccountModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Hesaplar alınamadı (${response.statusCode})');
  }

  static Future<TransactionModel> deposit({
    required int accountId,
    required double amount,
  }) async {
    final response = await authenticatedPost(
      '/api/accounts/$accountId/deposit',
      {'amount': amount},
    );

    if (response.statusCode != 200) {
      final body = _decodeBody(response);

      throw Exception(
        _extractError(
          body,
          fallback: 'Para yatırma işlemi başarısız (${response.statusCode})',
        ),
      );
    }

    return _getLatestTransaction(
      accountId: accountId,
      type: 'DEPOSIT',
      amount: amount,
    );
  }

  static Future<TransactionModel> withdraw({
    required int accountId,
    required double amount,
  }) async {
    final response = await authenticatedPost(
      '/api/accounts/$accountId/withdraw',
      {'amount': amount},
    );

    if (response.statusCode != 200) {
      final body = _decodeBody(response);

      throw Exception(
        _extractError(
          body,
          fallback: 'Para çekme işlemi başarısız (${response.statusCode})',
        ),
      );
    }

    return _getLatestTransaction(
      accountId: accountId,
      type: 'WITHDRAW',
      amount: amount,
    );
  }

  static Future<TransactionModel> transfer({
    required int fromAccountId,
    required String toAccountNumber,
    required double amount,
  }) async {
    final response = await authenticatedPost('/api/accounts/transfer', {
      'fromAccountId': fromAccountId,
      'toAccountNumber': toAccountNumber.trim().toUpperCase(),
      'amount': amount,
    });

    if (response.statusCode != 200) {
      final body = _decodeBody(response);

      throw Exception(
        _extractError(
          body,
          fallback: 'Transfer işlemi başarısız (${response.statusCode})',
        ),
      );
    }

    return _getLatestTransaction(
      accountId: fromAccountId,
      type: 'TRANSFER',
      amount: amount,
    );
  }

  static Future<RecipientModel> lookupRecipient(String accountNumber) async {
    final normalized = accountNumber.trim().toUpperCase();

    final encoded = Uri.encodeQueryComponent(normalized);

    final response = await authenticatedGet(
      '/api/accounts/recipient?accountNumber=$encoded',
    );

    final body = _decodeBody(response);

    if (response.statusCode == 200) {
      return RecipientModel.fromJson(body);
    }

    throw Exception(_extractError(body, fallback: 'Alıcı hesap bulunamadı.'));
  }

  // ===========================================================================
  // TRANSACTIONS
  // ===========================================================================

  static Future<List<TransactionModel>> getAccountTransactions(
    int accountId,
  ) async {
    final response = await authenticatedGet(
      '/api/transactions/account/$accountId',
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Geçersiz işlem verisi.');
      }

      return decoded
          .map(
            (item) => TransactionModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    throw Exception('İşlemler alınamadı (${response.statusCode})');
  }

  // ===========================================================================
  // AUTHENTICATED GET
  // ===========================================================================

  static Future<http.Response> authenticatedGet(String path) async {
    await _ensureTokensLoaded();

    var response = await http
        .get(Uri.parse('$baseUrl$path'), headers: await authHeaders())
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 401) {
      final refreshed = await refreshSession();

      if (!refreshed) {
        throw Exception('Oturum süresi doldu. Tekrar giriş yap.');
      }

      response = await http
          .get(Uri.parse('$baseUrl$path'), headers: await authHeaders())
          .timeout(const Duration(seconds: 10));
    }

    return response;
  }

  // ===========================================================================
  // AUTHENTICATED POST
  // ===========================================================================

  static Future<http.Response> authenticatedPost(
    String path,
    Map<String, dynamic> body,
  ) async {
    await _ensureTokensLoaded();

    var response = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: await authHeaders(),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 401) {
      final refreshed = await refreshSession();

      if (!refreshed) {
        throw Exception('Oturum süresi doldu. Tekrar giriş yap.');
      }

      response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: await authHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
    }

    return response;
  }

  // ===========================================================================
  // HEADERS
  // ===========================================================================

  static Future<Map<String, String>> authHeaders() async {
    await _ensureTokensLoaded();

    if (accessToken == null || accessToken!.isEmpty) {
      throw Exception('Oturum bulunamadı.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  // ===========================================================================
  // STORAGE
  // ===========================================================================

  static Future<void> loadTokens() async {
    accessToken = await _storage.read(key: _accessTokenKey);

    refreshToken = await _storage.read(key: _refreshTokenKey);
  }

  static Future<bool> isLoggedIn() async {
    await loadTokens();

    return refreshToken != null && refreshToken!.isNotEmpty;
  }

  static Future<void> logout() async {
    accessToken = null;
    refreshToken = null;

    await _storage.delete(key: _accessTokenKey);

    await _storage.delete(key: _refreshTokenKey);

    await _storage.delete(key: _fullNameKey);
  }

  static Future<String?> getUserFullName() async {
    return _storage.read(key: _fullNameKey);
  }

  // ===========================================================================
  // PRIVATE
  // ===========================================================================

  static Future<TransactionModel> _getLatestTransaction({
    required int accountId,
    required String type,
    required double amount,
  }) async {
    final transactions = await getAccountTransactions(accountId);

    for (final transaction in transactions) {
      final sameAmount = (transaction.amount - amount).abs() < 0.01;

      if (transaction.type == type && sameAmount) {
        return transaction;
      }
    }

    throw Exception('İşlem tamamlandı ancak dekont bilgisi alınamadı.');
  }

  static Future<void> _ensureTokensLoaded() async {
    if (accessToken == null || refreshToken == null) {
      await loadTokens();
    }
  }

  static Future<void> _saveAuthResponse(Map<String, dynamic> body) async {
    final newAccessToken = body['token'] as String?;

    final newRefreshToken = body['refreshToken'] as String?;

    if (newAccessToken == null ||
        newRefreshToken == null ||
        newAccessToken.isEmpty ||
        newRefreshToken.isEmpty) {
      throw Exception('Sunucudan oturum bilgisi alınamadı.');
    }

    accessToken = newAccessToken;
    refreshToken = newRefreshToken;

    await _storage.write(key: _accessTokenKey, value: accessToken);

    await _storage.write(key: _refreshTokenKey, value: refreshToken);

    final user = body['user'];

    if (user is Map<String, dynamic>) {
      final fullName = user['fullName']?.toString().trim();

      if (fullName != null && fullName.isNotEmpty) {
        await _storage.write(key: _fullNameKey, value: fullName);
      }
    }
  }

  static Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {};
    } catch (_) {
      return {};
    }
  }

  static String _extractError(
    Map<String, dynamic> body, {
    required String fallback,
  }) {
    final message = body['message'];

    if (message != null && message.toString().isNotEmpty) {
      return message.toString();
    }

    for (final value in body.values) {
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }
}
