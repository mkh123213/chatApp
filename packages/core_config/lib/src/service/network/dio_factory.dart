// REUSABLE SERVICE: Dio HTTP client factory with auth interceptor.
// REQUIRES: dio, dio/io, pretty_dio_logger packages in pubspec.yaml
// CHANGE: Pass your token getter and unauthorized handler when calling getDio().
// ignore_for_file: lines_longer_than_80_chars

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioFactory {
  DioFactory._();

  static Dio? dio;

  // CHANGE: Call this with your project's token getter and logout callback
  static Dio getDio({
    String Function()? tokenGetter,
    Future<void> Function()? onUnauthorized,
  }) {
    const timeOut = Duration(seconds: 30);

    if (dio == null) {
      dio = Dio();
      (dio!.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback = (cert, host, port) => true;
        return null;
      };
      dio!
        ..options.connectTimeout = timeOut
        ..options.receiveTimeout = timeOut;

      _addInterceptors(
        tokenGetter: tokenGetter,
        onUnauthorized: onUnauthorized,
      );
      return dio!;
    } else {
      return dio!;
    }
  }

  static void _addInterceptors({
    String Function()? tokenGetter,
    Future<void> Function()? onUnauthorized,
  }) {
    dio?.interceptors.add(PrettyDioLogger(request: false, compact: false));

    dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = tokenGetter?.call();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 ||
              error.response?.statusCode == 400) {
            await onUnauthorized?.call();
          }
          return handler.next(error);
        },
      ),
    );
  }
}
