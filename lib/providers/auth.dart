import 'package:bidhood/environments/app_config.dart';
import 'package:bidhood/main.dart';
import 'package:bidhood/models/user/user_body_for_create.dart';
import 'package:bidhood/models/user/user_body_for_login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Dio _dio = Dio();

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isLoggedIn;
  final String? accessToken;
  final String? refreshToken;
  final dynamic userData;

  AuthState(
      {this.isLoggedIn = false,
      this.accessToken,
      this.refreshToken,
      this.userData});

  AuthState copyWith(
      {bool? isLoggedIn,
      String? accessToken,
      String? refreshToken,
      dynamic userData}) {
    return AuthState(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        userData: userData ?? this.userData);
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _loadAuthState();
  }

  // Load the authentication state from local storage
  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');
    state = state.copyWith(
      isLoggedIn: isLoggedIn,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    if (!isLoggedIn || accessToken == null) {
      _navigateToLogin();
      return;
    }
    try {
      await _fetchUserDetails(accessToken);
    } catch (e) {
      _handleAuthError(e);
    }
  }

  void _handleAuthError(e) {
    if (e is DioException && e.response?.statusCode != 200) {
      debugPrint("Authentication error: ${e.message}");
    } else {
      debugPrint("Unexpected error: $e");
    }
    _navigateToLogin();
  }

  Future<void> _fetchUserDetails(String accessToken) async {
    final api = config['endpoint'] + '/auth/me';
    final response = await _dio.post(
      api,
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      }),
    );
    var res = response.data['data'];
    if (res['role'] == null) {
      _navigateToLogin();
      return;
    }
    _navigateBasedOnRole(res['role']);
  }

  void _navigateBasedOnRole(String role) {
    if (role == 'User') {
      router.go('/parcel');
    } else if (role == 'Rider') {
      router.go('/profile');
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    router.go('/login');
  }

  Future<void> refresh() async {
    try {
      final api = config['endpoint'] + '/auth/refresh';
      var response = await _dio.post(
        api,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${state.accessToken}',
          'Refresh-Token': '${state.refreshToken}'
        }),
      );
      var result = response.data;
      await _updateLoginState(
          true, result['access_token'], result['refresh_token']);
      state = state.copyWith(
          isLoggedIn: true,
          accessToken: result['access_token'],
          refreshToken: result['refresh_token']);
      debugPrint("Refresh Token.....");
    } catch (e) {
      if (e is DioException) {
        debugPrint('$e');
      }
    }
  }

  Future<Map<String, dynamic>> login(UserBodyForLogin userBody) async {
    try {
      final api = config['endpoint'] + '/auth/login';
      var response = await _dio.post(
        api,
        data: userBody.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      var result = response.data['data'];
      var userData = response.data['data']['user'];
      await _updateLoginState(
          true, result['access_token'], result['refresh_token']);
      state = state.copyWith(
          isLoggedIn: true,
          accessToken: result['access_token'],
          refreshToken: result['refresh_token'],
          userData: userData);
      await _fetchUserDetails(result['access_token']);
      return {
        "statusCode": response.statusCode,
        "data": response.data,
      };
    } catch (e) {
      if (e is DioException) {
        return {
          "statusCode": e.response?.statusCode,
          "data": e.response?.data,
          "error": e.message,
        };
      }
      return {
        "statusCode": 500,
        "error": "An unexpected error occurred",
      };
    }
  }

  Future<Map<String, dynamic>> register(UserBodyForCreate userBody) async {
    try {
      final api = config['endpoint'] + '/auth/register';
      var response = await _dio.post(
        api,
        data: userBody.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return {
        "statusCode": response.statusCode,
        "data": response.data,
      };
    } catch (e) {
      if (e is DioException) {
        return {
          "statusCode": e.response?.statusCode,
          "data": e.response?.data,
          "error": e.message,
        };
      }
      return {
        "statusCode": 500,
        "error": "An unexpected error occurred",
      };
    }
  }

  Future<void> updateUser(dynamic userData) async {
    state = state.copyWith(userData: userData);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'userData', userData.toString()); // Serialize if necessary
  }

  Future<void> _updateLoginState(
      bool isLoggedIn, String? accessToken, String? refreshToken) async {
    state = state.copyWith(
      isLoggedIn: isLoggedIn,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    await prefs.setString('accessToken', accessToken ?? '');
    await prefs.setString('refreshToken', refreshToken ?? '');
  }

  void logout() async {
    debugPrint("ออกจากระบบแล้ว");
    await _updateLoginState(false, '', '');
    state = state.copyWith(
        isLoggedIn: false,
        accessToken: null,
        refreshToken: null,
        userData: null);
  }
}
