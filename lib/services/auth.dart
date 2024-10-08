import 'package:bidhood/environments/app_config.dart';
import 'package:bidhood/providers/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthorizeService {
  final Dio dio;

  AuthorizeService(this.dio);
  Future<Map<String, dynamic>> me() async {
    try {
      final api = config['endpoint'] + '/auth/me';
      var response = await dio.post(
        api,
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
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final api = config['endpoint'] + '/auth/register';
            var response = await dio.post(
        api,
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

final userService = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return AuthorizeService(dio);
});
