import 'package:flutter_screentime/models/block_app_model.dart';
import 'package:flutter_screentime/models/location_model.dart';
import 'package:flutter_screentime/provider/api.dart';
import 'package:dio/dio.dart';

class AppsRepository {
  final Api api;

  AppsRepository(this.api);

  Future<List<dynamic>> getAllAppsBlock(customerId, companyId) async {
    List<dynamic> apps = [];
    List<AppInfo> appBlock = [];
    Response? response = await api.getAllOrders(customerId, companyId);
    if (response != null && response.statusCode == 200) {
      var body = response.data as Map<String, dynamic>;
      if (body.containsKey('block')) {
        for (var item in body['block']) {
          apps.add(item);
        }
      }
      return apps;
    } else {
      return apps;
    }
  }

  Future<List<dynamic>> getAllAppsUnBlock(customerId, companyId) async {
    List<dynamic> apps = [];
    List<AppInfo> appUnBlock = [];
    Response? response = await api.getAllOrders(customerId, companyId);
    if (response != null && response.statusCode == 200) {
      var body = response.data as Map<String, dynamic>;

      if (body.containsKey('unBlock')) {
        for (var item in body['unBlock']) {
          apps.add(item);
        }
      }
      return apps;
    } else {
      return apps;
    }
  }

  Future<bool> postLocation(LocationModel locationModel) async {
    Response? response = await api.postLocation(locationModel.toMap());

    if (response != null && response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
