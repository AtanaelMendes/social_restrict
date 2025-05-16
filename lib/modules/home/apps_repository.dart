import 'package:flutter_screentime/models/location_model.dart';
import 'package:flutter_screentime/provider/api.dart';
import 'package:dio/dio.dart';

class AppsRepository {
  final Api api;

  AppsRepository(this.api);

  Future<bool> postLocation(LocationModel locationModel) async {
    Response? response = await api.postLocation(locationModel.toMap());

    if (response != null && response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
