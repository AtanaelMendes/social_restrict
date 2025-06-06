import 'dart:io';
import 'dart:developer';
import 'package:device_apps/device_apps.dart';
import 'package:flutter_screentime/models/block_app_model.dart';
import 'package:flutter_screentime/modules/home/apps_controller.dart';
import 'package:flutter_screentime/modules/home/apps_repository.dart';
import 'package:flutter_screentime/provider/api.dart';
import 'package:flutter_screentime/navigation_service.dart';
import 'package:get/instance_manager.dart';

class BlockUnblockManager {
  BlockUnblockManager._();

  static Future<void> blockApps(List<AppInfo> apps) async {
    log("[BlockUnblockManager] blockApps chamado com apps: ${apps.map((app) => app.toJson())} linha ${_line()}");

    if (Platform.isIOS) {
      log("[BlockUnblockManager] Enviando blockApps para iOS via methodChannel linha ${_line()}");
      await NavigationService.methodChannel.invokeMethod(
        'blockApps',
        {
          'apps': apps.map((app) => app.toJson()).toList(),
        },
      );
    }

    // Ensure AppsController is registered only once
    if (!Get.isRegistered<AppsController>()) {
      Get.lazyPut(() => AppsController(Get.find(), AppsRepository(Api())));
    }
    for (var bundleApp in apps) {
      if (Platform.isAndroid) {
        var app = await DeviceApps.getApp(bundleApp.bundle.toString(), true);
        if (app != null) {
          await Get.find<AppsController>().addToLockedApps(app);
        }
      }
    }
  }

  static Future<void> unblockApps(List<AppInfo> apps) async {
    log("[BlockUnblockManager] unblockApps chamado com apps: ${apps.map((app) => app.toJson())} linha ${_line()}");
 
    if (Platform.isIOS) {
      await NavigationService.methodChannel.invokeMethod(
        'unlockApps',
        {
          'apps': apps.map((app) => app.toJson()).toList(),
        },
      );
    }

    if (Platform.isAndroid) {
      for (var bundleApp in apps) {
        var app = await DeviceApps.getApp(bundleApp.bundle.toString(), true);
        if (app != null) {
          await Get.find<AppsController>().addToLockedApps(app);
        }
      }
    }
  }

  static int _line() => StackTrace.current.toString().split('\n')[1].contains(":") 
    ? int.tryParse(RegExp(r":(\d+):\d+\)$").firstMatch(StackTrace.current.toString().split('\n')[1])?.group(1) ?? '') ?? 0 
    : 0;
}
