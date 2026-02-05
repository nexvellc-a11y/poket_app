import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioNetworkService {
  static late Dio dio;
  static late Dio refreshDio;

  static bool _isRefreshing = false;
  static final List<RequestOptions> _retryQueue = [];

  // ================= INITIALIZE (CALL ONCE) =================
  static void initialize() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.poketstor.com',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
      ),
    );

    refreshDio = Dio(
      BaseOptions(
        baseUrl: 'https://api.poketstor.com',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        // ================= REQUEST =================
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('accessToken');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          log('➡️ ${options.method} ${options.uri}');
          handler.next(options);
        },

        // ================= ERROR =================
        onError: (error, handler) async {
          // 🔴 NETWORK / DNS ERROR
          if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.unknown) {
            log('🔴 Network error – NO RESET, NO CLOSE');
            return handler.next(error);
          }

          // 🔁 Only handle 401
          if (error.response?.statusCode != 401) {
            return handler.next(error);
          }

          final prefs = await SharedPreferences.getInstance();
          final refreshToken = prefs.getString('refreshToken');

          if (refreshToken == null) {
            await _forceLogout();
            return handler.next(error);
          }

          if (_isRefreshing) {
            _retryQueue.add(error.requestOptions);
            return;
          }

          _isRefreshing = true;

          try {
            final refreshResponse = await refreshDio.post(
              '/auth/user/refresh',
              options: Options(
                headers: {'Authorization': 'Bearer $refreshToken'},
              ),
            );

            final newAccessToken = refreshResponse.data['accessToken'];
            if (newAccessToken == null) throw Exception('No access token');

            await prefs.setString('accessToken', newAccessToken);

            for (final req in _retryQueue) {
              req.headers['Authorization'] = 'Bearer $newAccessToken';
              dio.fetch(req);
            }
            _retryQueue.clear();

            _isRefreshing = false;

            error.requestOptions.headers['Authorization'] =
                'Bearer $newAccessToken';

            final response = await dio.fetch(error.requestOptions);
            return handler.resolve(response);
          } catch (e) {
            _isRefreshing = false;
            _retryQueue.clear();
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
    log('🚪 Forced logout');
  }
}
