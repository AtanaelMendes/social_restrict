import 'package:flutter_screentime/data/models/block_app_model.dart';
import 'package:flutter_screentime/data/models/location_model.dart';
import 'package:flutter_screentime/data/provider/api.dart';
import 'package:dio/dio.dart';

class AppsRepository {
  final Api api;

  AppsRepository(this.api);

  // Future<List<AppInfo>> getAllAppsBlock() async {
  //   List<BlockAppModel> apps = [];
  //   List<AppInfo> appBlock = [];
  //   Response? response = await api.getAllOrdes();
  //   if (response != null && response.isOk) {
  //     var body = response.body as Map<String, dynamic>;
  //     if (body.containsKey('block')) {
  //       for (var item in body['block']) {
  //         appBlock.add(AppInfo.fromMap(item));
  //       }
  //     }
  //     return appBlock;
  //   } else {
  //     return appBlock;
  //   }
  // }

  // Future<List<AppInfo>> getAllAppsUnBlock() async {
  //   List<BlockAppModel> apps = [];
  //   List<AppInfo> appUnBlock = [];
  //   Response? response = await api.getAllOrdes();
  //   if (response != null && response.isOk) {
  //     var body = response.body as Map<String, dynamic>;

  //     if (body.containsKey('unBlock')) {
  //       for (var item in body['unBlock']) {
  //         appUnBlock.add(AppInfo.fromMap(item));
  //       }
  //     }
  //     return appUnBlock;
  //   } else {
  //     return appUnBlock;
  //   }
  // }

  Future<bool> postLocation(LocationModel locationModel) async {
    Response? response = await api.postLocation(locationModel.toMap());

    if (response != null && response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
