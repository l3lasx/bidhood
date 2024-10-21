import 'package:bidhood/environments/app_config.dart';
import 'package:bidhood/providers/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RiderService {
  final Dio dio;

  RiderService(this.dio, ref);

  Future<Map<String, dynamic>> checkCurrentWork() async {
    try {
      final api = config['endpoint'] + '/riders/check_work';
      var response = await dio.get(
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

  Future<Map<String, dynamic>> acceptWork(String oid) async {
    try {
      final api = config['endpoint'] + '/riders/accept_work/$oid';
      var response = await dio.post(
        api,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return {
        "statusCode": response.statusCode,
        "data": response.data,
      };
    } catch (e) {
      debugPrint("$e");
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

  Future<Map<String, dynamic>> updateWork(
      String oid, Map<String, dynamic> data) async {
    try {
      final api = config['endpoint'] + '/riders/update_work/$oid';
      debugPrint('$api');
      var response = await dio.post(
        api,
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return {
        "statusCode": response.statusCode,
        "data": response.data,
      };
    } catch (e) {
      debugPrint("$e");
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

final riderService = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return RiderService(dio, ref);
});
