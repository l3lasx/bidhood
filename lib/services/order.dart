import 'package:bidhood/environments/app_config.dart';
import 'package:bidhood/providers/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderService {
  final Dio dio;

  OrderService(this.dio, ref);
  
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    try {
      final api = config['endpoint'] + '/orders';
      debugPrint(api);
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

final orderService = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return OrderService(dio, ref);
});
