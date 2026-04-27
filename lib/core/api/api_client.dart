import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../storage/local_storage.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  late Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = LocalStorage.getToken();
          if (token != null && !options.path.contains('/login')) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('/login')) {
            
            // محاولة جلب توكن جديد
            final refreshToken = LocalStorage.getRefreshToken();
            if (refreshToken != null) {
              try {
                final retryDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
                final res = await retryDio.post(
                  '/admin/refresh-token',
                  data: {'refresh_token': refreshToken},
                );

                if (res.statusCode == 200 && res.data['token'] != null) {
                  final newToken = res.data['token'];
                  await LocalStorage.saveToken(newToken);
                  if (res.data['refreshToken'] != null) {
                    await LocalStorage.saveRefreshToken(res.data['refreshToken']);
                  }
                  
                  error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                  
                  final retryRes = await retryDio.fetch(error.requestOptions);
                  return handler.resolve(retryRes);
                }
              } catch (e) {
                debugPrint('Refresh token failed: $e');
                await LocalStorage.clearAll();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    final res = await dio.get(path, queryParameters: queryParameters);
    return res.data;
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    final res = await dio.post(path, data: data);
    return res.data;
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    final res = await dio.put(path, data: data);
    return res.data;
  }

  Future<dynamic> patch(String path, {dynamic data}) async {
    final res = await dio.patch(path, data: data);
    return res.data;
  }

  Future<dynamic> delete(String path) async {
    final res = await dio.delete(path);
    return res.data;
  }
}
