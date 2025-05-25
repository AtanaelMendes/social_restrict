import 'dart:io';
import 'package:device_apps/device_apps.dart';
import 'package:flutter_screentime/modules/home/apps_controller.dart';
import 'package:flutter_screentime/modules/home/apps_repository.dart';
import 'package:flutter_screentime/provider/api.dart';
import 'package:flutter_screentime/navigation_service.dart';
import 'package:get/instance_manager.dart';

class BlockUnblockManager {
  BlockUnblockManager._();

  static Future<void> blockApps(List<dynamic> apps) async {
    if (Platform.isIOS) {
      NavigationService.methodChannel.invokeMethod('blockApps', {'apps': apps});
    }

    apps.forEach((bundleApp) async {
      Get.lazyPut(() => AppsController(Get.find(), AppsRepository(Api())));
      if (Platform.isAndroid) {
        var app = await DeviceApps.getApp(bundleApp, true);
        if (app != null) {
          await Get.find<AppsController>().addToLockedApps(app);
        }
      }
    });
  }

  static Future<void> unblockApps(List<dynamic> apps) async {
    if (Platform.isIOS) {
      NavigationService.methodChannel.invokeMethod('unlockApps', {'apps': apps});
    }
    if (Platform.isAndroid) {
      apps.forEach((bundleApp) async {
        var app = await DeviceApps.getApp(bundleApp, true);
        if (app != null) {
          await Get.find<AppsController>().addToLockedApps(app);
        }
      });
    }
  }
}
