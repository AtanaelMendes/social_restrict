import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screentime/config/env_variables.dart';
import 'package:logger/logger.dart';

class Api {
  final Dio dio = Dio();
  final String _token = token ?? '';

  Api() {
    // (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () =>
    // HttpClient()
    //   ..badCertificateCallback =
    //       (X509Certificate cert, String host, int port) => true;

    dio.options.baseUrl = '$apiUrl/$apiPath';
    dio.options.connectTimeout = const Duration(seconds: 20);
    dio.options.receiveTimeout = const Duration(seconds: 20);
  }

  var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  Future<Response?> postTokenId(Map body) async {
    debugPrint("Chamando ${dio.options.baseUrl}/customers/status");
    try {
      var response = await dio.put(
        '/customers/status',
        data: body,
        options: Options(
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        ),
      );
      return response;
    } catch (e) {
      logger.e(e.toString());
      return null;
    }
  }

  Future<Response?> postLocation(Map body) async {
    final url = '${dio.options.baseUrl}/customers/loc';
    debugPrint("Chamando $url");

    if (_token == null || _token.isEmpty) {
      debugPrint('Token não está definido!');
      return null;
    }

    try {
      var response = await dio.put(
        '/customers/loc',
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        ),
      );
      debugPrint('Resposta statusCode: ${response.statusCode}');
      debugPrint('Resposta data: ${response.data}');
      return response;
    } catch (e, stacktrace) {
      logger.e('Erro ao chamar postLocation: $e\n$stacktrace');
      return null;
    }
  }

}
