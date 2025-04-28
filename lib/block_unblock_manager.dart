import 'dart:io';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/services.dart';
import 'package:social_restrict/android/apps_controller.dart';
import 'package:social_restrict/android/method_channel_controller.dart';
import 'package:social_restrict/navigation_service.dart';
import 'package:get/instance_manager.dart';

class BlockUnblockManager {
  BlockUnblockManager._();

  static Future<void> blockApps(List<dynamic> apps) async {
    if (Platform.isIOS) {
      NavigationService.methodChannel.invokeMethod('blockApps', {'apps': apps});
    }

    apps.forEach((bundleApp) async {
      Get.lazyPut(() => AppsController(prefs: Get.find()));
      if (Platform.isAndroid) {
        var app = await DeviceApps.getApp(bundleApp, true);
        if (app != null) {
          await Get.find<AppsController>().addToLockedApps(app);
        }
        //await Get.find<AppsController>().addToLockedApps(app!);
      }
    });
  }

  static Future<void> unblockApps(List<dynamic> apps) async {
    if (Platform.isIOS) {
      NavigationService.methodChannel
          .invokeMethod('unlockApps', {'apps': apps});
    }
    if (Platform.isAndroid) {
      //Get.find<MethodChannelController>().update();
      apps.forEach((bundleApp) async {
        var app = await DeviceApps.getApp(bundleApp, true);
        if (app != null) {
          await Get.find<AppsController>().addToLockedApps(app);
        }
      });
    }
  }
}
