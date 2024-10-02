import 'package:bidhood/providers/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bidhood/main.dart';



final goRouterProvider = Provider<GoRouter>((ref) {
  return router;
});

class DioInterceptor extends Interceptor {
  final Ref ref;

  DioInterceptor(this.ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final authState = ref.read(authProvider);
    final token = authState.accessToken;
    // debugPrint(authState.userData.toString());

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      ref.read(goRouterProvider).go('/login');
    }
    super.onError(err, handler);
  }
}

final dioProvider = Provider((ref) {
  final dio = Dio();
  dio.interceptors.add(DioInterceptor(ref));
  return dio;
});