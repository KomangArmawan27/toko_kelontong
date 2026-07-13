import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_user.dart';
import 'api_data.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const String baseUrl = 'https://be-toko-kelontong-production.up.railway.app/';

  String? _token;
  AppUser? _currentUser;

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  AppUser? get currentUser => _currentUser;

  String? get currentRole => _currentUser?.role;

  bool get isShopOwner => _currentUser?.isShopOwner ?? false;

  bool get isShopKeeper => _currentUser?.isShopKeeper ?? false;

  bool get isCustomer => _currentUser?.isCustomer ?? false;

  bool get canManageItems => isShopOwner;

  bool get canManageCashTransactions => isShopOwner || isShopKeeper;

  bool get canManageStockMovements => isShopOwner || isShopKeeper;

  bool get canViewReports => isShopOwner;

  bool get canPurchaseItems => isShopOwner || isCustomer;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await post('api/auth/login', {
      'email': email,
      'password': password,
    });
    _saveSession(data);
    return data;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await post('api/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });
    _saveSession(data);
    return data;
  }

  Future<void> logout() async {
    if (isAuthenticated) {
      try {
        await post('api/auth/logout', {});
      } catch (_) {
        // Local logout should still succeed if the token is already invalid.
      }
    }
    _token = null;
    _currentUser = null;
  }

  Future<Map<String, dynamic>> me() async {
    final data = await get('api/auth/me');
    _saveUser(data);
    return data;
  }

  Future<List<AppUser>> listUsers() async {
    final response = await get('api/users');
    return dataList(response).map(AppUser.fromJson).toList();
  }

  Future<Map<String, dynamic>> updateUserRole(int userId, String role) {
    return patch('api/users/$userId/role', {
      'role': role,
    });
  }

  Future<Map<String, dynamic>> purchaseItem(
    int itemId, {
    required double quantity,
    String? notes,
    DateTime? transactionDate,
  }) {
    return post('api/items/$itemId/purchase', {
      'quantity': quantity,
      if (transactionDate != null)
        'transaction_date': transactionDate.toIso8601String().split('T').first,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    });
  }

  Future<Map<String, dynamic>> get(String path) => _send('GET', path);

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) {
    return _send('POST', path, body: body);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) {
    return _send('PUT', path, body: body);
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) {
    return _send('PATCH', path, body: body);
  }

  Future<Map<String, dynamic>> delete(String path) => _send('DELETE', path);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse(baseUrl).resolve(path);
    final request = http.Request(method, uri)
      ..headers.addAll(_headers);

    if (body != null) {
      request.body = jsonEncode(body);
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final decoded = _decode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_messageFrom(decoded), response.statusCode);
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {'data': decoded};
  }

  Object? _decode(String body) {
    if (body.trim().isEmpty) return {};
    try {
      return jsonDecode(body);
    } catch (_) {
      return {'message': body};
    }
  }

  String _messageFrom(Object? decoded) {
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'];
      if (message is String) return message;

      final errors = decoded['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        return first.toString();
      }
    }
    return 'Request failed. Please try again.';
  }

  void _saveToken(Map<String, dynamic> data) {
    final token = data['token'] ??
        data['access_token'] ??
        (data['data'] is Map<String, dynamic>
            ? (data['data'] as Map<String, dynamic>)['token'] ??
                (data['data'] as Map<String, dynamic>)['access_token']
            : null);

    if (token != null) {
      _token = token.toString();
    }
  }

  void _saveUser(Map<String, dynamic> data) {
    final user = _extractUser(data);
    if (user != null) {
      _currentUser = user;
    }
  }

  void _saveSession(Map<String, dynamic> data) {
    _saveToken(data);
    _saveUser(data);
  }

  AppUser? _extractUser(Map<String, dynamic> data) {
    final directUser = data['user'];
    if (directUser is Map<String, dynamic>) {
      return AppUser.fromJson(directUser);
    }

    final nestedData = data['data'];
    if (nestedData is Map<String, dynamic>) {
      final nestedUser = nestedData['user'];
      if (nestedUser is Map<String, dynamic>) {
        return AppUser.fromJson(nestedUser);
      }
    }

    return null;
  }
}
