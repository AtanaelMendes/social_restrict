import 'package:flutter_screentime/models/block_app_model.dart';
import 'package:flutter_screentime/models/location_model.dart';
import 'package:flutter_screentime/provider/api.dart';
import 'package:dio/dio.dart';

class AppsRepository {
  final Api api;

  AppsRepository(this.api);
  List<AppInfo> apps = [];
  List<AppInfo> appBlock = [];
  List<AppInfo> appUnBlock = [];

  Future<List<AppInfo>> apiGetOrders(customerId, companyId) async {
    Response? response = await api.getAllOrders(customerId, companyId);
    if (response != null && response.statusCode == 200) {
      apps.clear();
      appBlock.clear();
      appUnBlock.clear();
      var body = response.data as Map<String, dynamic>;
      if (body.containsKey('block')) {
        for (var item in body['block']) {
          appBlock.add(AppInfo.fromMap(item));
        }
      }
      if (body.containsKey('unBlock')) {
        for (var item in body['unBlock']) {
          appUnBlock.add(AppInfo.fromMap(item));
        }
      }
      if (body.containsKey('apps')) {
        for (var item in body['apps']) {
          apps.add(AppInfo.fromMap(item));
        }
      }
    }
    return apps;
  }

  Future<bool> postLocation(LocationModel locationModel) async {
    Response? response = await api.postLocation(locationModel.toMap());

    if (response != null && response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
