import 'package:bidhood/environments/app_config.dart';
import 'package:bidhood/models/user/user_body_for_create.dart';
import 'package:bidhood/models/user/user_body_for_login.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  AuthNotifier() : super(AuthState());

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
      state = state.copyWith(
          isLoggedIn: true,
          accessToken: result['access_token'],
          refreshToken: result['refresh_token'],
          userData: userData);
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

  void logout() {
    state = state.copyWith(
        isLoggedIn: false,
        accessToken: null,
        refreshToken: null,
        userData: null);
  }

  Future<void> updateUser(dynamic userData) async {
    state = state.copyWith(userData: userData);
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
}
