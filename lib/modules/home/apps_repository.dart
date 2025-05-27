import 'package:flutter_screentime/models/block_app_model.dart';
import 'package:flutter_screentime/models/location_model.dart';
import 'package:flutter_screentime/provider/api.dart';
import 'package:dio/dio.dart';

class AppsRepository {
  final Api api;

  AppsRepository(this.api);

  Future<List<AppInfo>> getAllAppsBlock(customerId, companyId) async {
    List<BlockAppModel> apps = [];
    List<AppInfo> appBlock = [];
    Response? response = await api.getAllOrders(customerId, companyId);
    if (response != null && response.statusCode == 200) {
      var body = response.data as List<dynamic>;
      for (var item in body) {
        if (item is Map<String, dynamic> && item.containsKey('block')) {
          for (var blockItem in item['block']) {
            appBlock.add(AppInfo.fromMap(blockItem));
          }
        }
      }
      return appBlock;
    } else {
      return appBlock;
    }
  }

  Future<List<AppInfo>> getAllAppsUnBlock(customerId, companyId) async {
    List<BlockAppModel> apps = [];
    List<AppInfo> appUnBlock = [];
    Response? response = await api.getAllOrders(customerId, companyId);
    if (response != null && response.statusCode == 200) {
      var body = response.data as List<dynamic>;

      for (var item in body) {
        if (item is Map<String, dynamic> && item.containsKey('unBlock')) {
          for (var unBlockItem in item['unBlock']) {
            appUnBlock.add(AppInfo.fromMap(unBlockItem));
          }
        }
      }
      return appUnBlock;
    } else {
      return appUnBlock;
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
