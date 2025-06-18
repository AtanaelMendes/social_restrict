import 'dart:developer';
import 'dart:convert';

import 'package:dio/dio.dart';
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
    log("Chamando ${dio.options.baseUrl}/customers/status");
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
      log(e.toString());
      return null;
    }
  }

  Future<Response?> postLocation(Map body) async {
    final url = '${dio.options.baseUrl}/customers/loc';
    log("Chamando $url");

    if (_token.isEmpty) {
      log('Token não está definido!');
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
      log('Resposta statusCode: ${response.statusCode}');
      log('Resposta data: ${response.data}');
      return response;
    } catch (e, stacktrace) {
      log('Erro ao chamar postLocation: $e\n$stacktrace');
      return null;
    }
  }

  Future<Response?> getAllOrders(customerId, companyId) async {
    final url = '${dio.options.baseUrl}/orders';
    log("Chamando $url");

    if (_token.isEmpty) {
      log('Token não está definido!');
      return null;
    }

    if (customerId == null || companyId == null) {
      log('customerId ou companyId não podem ser nulos!');
      return null;
    }

    try {
      var response = await dio.get(
        url,
        queryParameters: {
          'customerId': customerId.toString(),
          'companyId': companyId.toString(),
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        ),
      );
      log('Resposta statusCode: ${response.statusCode}');
      log('Resposta data: ${response.data}');
      return response;
    } catch (e, stacktrace) {
      log('Erro ao chamar getAllOrders: $e\n$stacktrace');
      return null;
    }
  }

  Future<Map<String, dynamic>?> login(String usuario, String senha) async {
    try {
      final response = await dio.post(
        'https://www.rhbrasil.com.br/model/API/socialrestrict/login.php',
        data: {
          'usuario': usuario,
          'senha': senha,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      if (response.statusCode == 200) {
        return response.data is Map<String, dynamic>
            ? response.data
            : jsonDecode(response.data);
      }
      return null;
    } catch (e) {
      log('Erro ao fazer login: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCustomers(String token) async {
    try {
      final response = await dio.get(
        'https://app-api.rhbrasil.com.br/api/customers?search=&limit=10&offset=0',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200) {
        return response.data is Map<String, dynamic>
            ? response.data
            : jsonDecode(response.data);
      }
      return null;
    } catch (e) {
      log('Erro ao buscar clientes: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getQrcode(String token, int userId) async {
    try {
      final response = await dio.get(
        'https://app-api.rhbrasil.com.br/api/customers/$userId/qrcode',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200) {
        return response.data is Map<String, dynamic>
            ? response.data
            : jsonDecode(response.data);
      }
      return null;
    } catch (e) {
      log('Erro ao buscar QRCode: $e');
      return null;
    }
  }

  Future<bool> painelAction(String token, String action, List<int> customers) async {
    try {
      final url = action == 'unblock'
          ? 'https://app-api.rhbrasil.com.br/api/orders/unblock'
          : 'https://app-api.rhbrasil.com.br/api/orders/block';
      final response = await dio.post(
        url,
        data: jsonEncode({'customers': customers}),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      log('Erro ao aplicar ação: $e');
      return false;
    }
  }
}
