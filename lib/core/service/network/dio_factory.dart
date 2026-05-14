// REUSABLE SERVICE: Dio HTTP client factory with auth interceptor.
// REQUIRES: dio, dio/io, pretty_dio_logger packages in pubspec.yaml
// CHANGE: Update PrefKeys.accessToken to your project's token key.
// CHANGE: Update the 401/400 error handling (AppLogout) to your project's logout logic.
// ignore_for_file: lines_longer_than_80_chars

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:chat_material3/core/service/shared_pref/pref_keys.dart';
import 'package:chat_material3/core/service/shared_pref/shared_pref.dart';
import 'package:chat_material3/core/utils/app_logout.dart';

class DioFactory {
  DioFactory._();

  static Dio? dio;

  static Dio getDio() {
    const timeOut = Duration(seconds: 30);
    // (dio!.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
    //     (client) {
    //       client.badCertificateCallback = (cert, host, port) => true;
    //       return null; // Trust all certificates
    //     };
    if (dio == null) {
      dio = Dio();
      (dio!.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback = (cert, host, port) => true;
        return null; // Trust all certificates
      };
      dio!
        ..options.connectTimeout = timeOut
        ..options.receiveTimeout = timeOut;

      debugPrint(
        "[USER Token] ====> ${SharedPref().getString(PrefKeys.currentUser) ?? 'NULL TOKEN'}",
      );
      debugPrint(
        "[USER role] ====> ${SharedPref().getString(PrefKeys.currentUser) ?? 'NULL ROLE'}",
      );

      addDioInterceptor();
      return dio!;
    } else {
      return dio!;
    }
  }

  static void addDioInterceptor() {
    dio?.interceptors.add(PrettyDioLogger(request: false, compact: false));

    dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] =
              'Bearer ${SharedPref().getString(PrefKeys.accessToken)}';

          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 ||
              error.response?.statusCode == 400) {
            await AppLogout().logout();
          }
        },
      ),
    );
  }
}
