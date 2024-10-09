import 'package:bidhood/environments/app_config.dart';
import 'package:bidhood/providers/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class UploadService {
  final Dio dio;

  UploadService(this.dio);
  Future<Map<String, dynamic>> uploadImage(XFile imageFile) async {
    try {
      final api = config['endpoint'] + '/utils/upload/image';

      // Create FormData
      String fileName = imageFile.name;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      var response = await dio.post(
        api,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      debugPrint('${response.data}');
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

  Future<Map<String, dynamic>> deleteImage(String url) async {
    try {
      final api = config['endpoint'] + '/utils/upload/image';
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
}

final uploadService = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return UploadService(dio);
});
