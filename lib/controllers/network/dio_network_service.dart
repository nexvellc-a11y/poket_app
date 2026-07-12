import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioNetworkService {
  static late Dio dio;
  static late Dio refreshDio;

  static bool _isRefreshing = false;

  // ✅ Queue for failed requests
  static final List<_PendingRequest> _retryQueue = [];

  // ✅ Store token in memory (performance fix)
  static String? accessToken;
  static String? refreshToken;

  // ================= INITIALIZE =================
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken');
    refreshToken = prefs.getString('refreshToken');

    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.poketstor.com',
        connectTimeout: null,
        receiveTimeout: null,
        responseType: ResponseType.json,
      ),
    );

    refreshDio = Dio(
      BaseOptions(
        baseUrl: 'https://api.poketstor.com',
        connectTimeout: null,
        receiveTimeout: null,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        // ================= REQUEST =================
        onRequest: (options, handler) async {
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          log('➡️ ${options.method} ${options.uri}');
          handler.next(options);
        },

        // ================= ERROR =================
        onError: (error, handler) async {
          log('❌ ERROR: ${error.response?.statusCode} ${error.message}');

          // Ignore network errors
         if (error.type == DioExceptionType.connectionError ||
    error.type == DioExceptionType.connectionTimeout ||
    error.type == DioExceptionType.receiveTimeout ||
    error.type == DioExceptionType.sendTimeout) {
  return handler.next(error);
}

          // Only handle 401
          if (error.response?.statusCode != 401) {
            return handler.next(error);
          }

          // No refresh token → logout
          if (refreshToken == null) {
            await _forceLogout();
            return handler.next(error);
          }

          // ================= QUEUE REQUEST =================
          final completer = Completer<Response>();
          _retryQueue.add(_PendingRequest(error.requestOptions, completer));

          // ================= IF ALREADY REFRESHING =================
          if (_isRefreshing) {
            return completer.future.then(
              (value) => handler.resolve(value),
              onError: (e) => handler.next(error),
            );
          }

          _isRefreshing = true;

          try {
            log('🔄 Refreshing token...');

            final response = await refreshDio.post(
              '/auth/user/refresh',
              options: Options(
                headers: {'Authorization': 'Bearer $refreshToken'},
              ),
            );

            final newAccessToken = response.data['accessToken'];
            if (newAccessToken == null) throw Exception('No access token');

            // ✅ Save new token
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('accessToken', newAccessToken);

            accessToken = newAccessToken;

            log('✅ Token refreshed');

            // ================= RETRY ALL QUEUED REQUESTS =================
            for (var pending in _retryQueue) {
              try {
                pending.request.headers['Authorization'] =
                    'Bearer $newAccessToken';

                final res = await dio.fetch(pending.request);
                pending.completer.complete(res);
              } catch (e) {
                pending.completer.completeError(e);
              }
            }

            _retryQueue.clear();
            _isRefreshing = false;

            // Resolve current request
            return completer.future.then(
              (value) => handler.resolve(value),
              onError: (e) => handler.next(error),
            );
          } catch (e) {
            log('🚨 Refresh failed');

            _retryQueue.clear();
            _isRefreshing = false;

            await _forceLogout();
            return handler.next(error);
          }
        },
      ),
    );
  }

  // ================= LOGOUT =================
  static Future<void> _forceLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    accessToken = null;
    refreshToken = null;

    log('🚪 Forced logout');
  }
}

// ================= HELPER CLASS =================
class _PendingRequest {
  final RequestOptions request;
  final Completer<Response> completer;

  _PendingRequest(this.request, this.completer);
}
