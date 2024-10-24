import 'package:bidhood/environments/app_config.dart';
import 'package:bidhood/main.dart';
import 'package:bidhood/models/user/user_body_for_create.dart';
import 'package:bidhood/models/user/user_body_for_login.dart';
import 'package:bidhood/providers/dio.dart';
import 'package:bidhood/services/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
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
  final bool isLoading;
  AuthState(
      {this.isLoggedIn = false,
      this.accessToken,
      this.refreshToken,
      this.isLoading = false,
      this.userData});

  AuthState copyWith(
      {bool? isLoggedIn,
      String? accessToken,
      String? refreshToken,
      bool? isLoading,
      dynamic userData}) {
    return AuthState(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        isLoading: isLoading ?? this.isLoading,
        userData: userData ?? this.userData);
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  AuthState getState() {
    return state;
  }

  // Load the authentication state from local storage
  Future<void> loadAuthState(ref) async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');

    // debugPrint('$isLoggedIn $accessToken $refreshToken ');
    if (!isLoggedIn) {
      ref.watch(goRouterProvider).go('/login');
      debugPrint("Account not Logged In !");
      return;
    }
    // save token to local
    await _updateLoginState(
        true, accessToken.toString(), refreshToken.toString());
    // debugPrint('accessToken: $accessToken');
    // debugPrint('refrshToken: $refreshToken');
    // refresh token section
    try {
      final api = config['endpoint'] + '/auth/refresh';
      var response = await _dio.post(
        api,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${accessToken.toString()}',
          'Refresh-Token': '$refreshToken'
        }),
      );
      debugPrint('TokenDebug ${response.data['access_token']}');
      state = state.copyWith(
          isLoggedIn: true,
          accessToken: response.data['access_token'],
          refreshToken: response.data['refresh_token']);
      await _updateLoginState(
          true, response.data['access_token'], response.data['refresh_token']);
      await _fetchUserDetails(ref, response.data['access_token']);
      debugPrint("Refresh Token.....");
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode != 200) {
          _navigateToLogin();
        }
      }
    }
  }

  Future<void> _fetchUserDetails(ref, String accessToken) async {
    state = state.copyWith(isLoading: true);
    try {
      final api = config['endpoint'] + '/auth/me';
      final response = await _dio.post(
        api,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        }),
      );
      var res = response.data['data'];
      state = state.copyWith(userData: res, isLoading: false);
      if (res['role'] == null) {
        _navigateToLogin();
        return;
      }
      return _navigateBasedOnRole(ref, res['role']);
    } catch (err) {
      state = state.copyWith(isLoading: false);
      _navigateToLogin();
    }
  }

  void _navigateBasedOnRole(WidgetRef ref, String role) async {
    // update current location
    try {
      if (role == "Rider") {
        await updateLocation(ref);
      }
      if (role == 'User') {
        ref.watch(goRouterProvider).go('/parcel');
      } else if (role == 'Rider') {
        ref.watch(goRouterProvider).go('/tasklist');
      } else {
        ref.watch(goRouterProvider).go('/login');
      }
      debugPrint('UserDebug Role: $role');
    } catch (err) {
      ref.watch(goRouterProvider).go('/login');
    }
  }

  Future<void> updateLocation(WidgetRef ref) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      Map<String, dynamic> payload = {
        "location": {"lat": position.latitude, "long": position.longitude}
      };

      var updateProfile = await ref.watch(userService).update(payload);
      if (updateProfile['statusCode'] == 200) {
        ref
            .read(authProvider.notifier)
            .updateUser(updateProfile['data']['data']);
      }
      debugPrint(
          "Update current user position: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      debugPrint("Error updating rider location: $e");
    }
  }

  void _navigateToLogin() {
    router.go('/login');
  }

  Future<Map<String, dynamic>> login(ref, UserBodyForLogin userBody) async {
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
      await _fetchUserDetails(ref, result['access_token']);
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

  Future<void> _updateLoginState(
      bool isLoggedIn, String? accessToken, String? refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    await prefs.setString('accessToken', accessToken ?? '');
    await prefs.setString('refreshToken', refreshToken ?? '');
    debugPrint('Save Key');
  }

  Future<void> updateUser(dynamic user) async {
    state = state.copyWith(userData: user, isLoading: false);
  }

  Future<void> update() async {
    state = state.copyWith();
  }

  void logout() async {
    debugPrint("ออกจากระบบแล้ว");
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    state = AuthState();
    router.go('/login');
  }
}
