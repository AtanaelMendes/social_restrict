// ignore_for_file: prefer_final_fields

import 'package:dio/dio.dart';
import 'package:flutter_screentime/config/env_variables.dart';
import 'package:logger/logger.dart';

class Api {
  final Dio dio = Dio();
  final String _token = token ?? '';

  Api() {
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
    try {
      var response = await dio.put(
        '/customers/status',
        //'https://957d-177-124-114-100.ngrok-free.app/api/customers/status',
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
    try {
      var response = await dio.put(
        '/customers/loc',
        //'https://957d-177-124-114-100.ngrok-free.app/api/customers/loc',
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

  // Future<Response?> getAllOrdes() async {
  //   _customerId = NavigationService.prefs?.getInt("id");
  //   try {
  //     var response = await dio.get(
  //         '${RHBrasilApi.HOST}/${RHBrasilApi.MAIN_PATH}/orders',
  //          options: Options(headers: {'Content-Type': 'application/json','Authorization': 'Bearer $_token'},));
  //         query: {
  //           'customerId': [_customerId.toString()]
  //         });
  //     return response;
  //   } catch (e) {
  //     Get.log(e.toString(), isError: true);
  //     return null;
  //   }
  // }
}
