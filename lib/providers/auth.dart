import 'package:bidhood/environments/app_config.dart';
import 'package:bidhood/models/user/user_body_for_create.dart';
import 'package:bidhood/models/user/user_body_for_login.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

final Dio _dio = Dio();

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<Map<String, dynamic>> login(UserBodyForLogin userBody) async {
    try {
      final api = config['endpoint'] + '/auth/login';
      var response = await _dio.post(
        api,
        data: userBody.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      _isLoggedIn = true;
      notifyListeners();
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
    _isLoggedIn = false;
    notifyListeners();
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
