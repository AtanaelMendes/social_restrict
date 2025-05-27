import 'dart:io';
import 'dart:developer';
import 'package:device_apps/device_apps.dart';
import 'package:flutter_screentime/modules/home/apps_controller.dart';
import 'package:flutter_screentime/modules/home/apps_repository.dart';
import 'package:flutter_screentime/provider/api.dart';
import 'package:flutter_screentime/navigation_service.dart';
import 'package:get/instance_manager.dart';

class BlockUnblockManager {
  BlockUnblockManager._();

  static Future<void> blockApps(List<dynamic> apps) async {
    log("[BlockUnblockManager] blockApps chamado com apps: $apps linha ${_line()}");

    if (Platform.isIOS) {
      log("[BlockUnblockManager] Enviando blockApps para iOS via methodChannel linha ${_line()}");
      await NavigationService.methodChannel.invokeMethod('blockApps', {'apps': apps});
    }

    for (var bundleApp in apps) {
      log("[BlockUnblockManager] bundleApp atual: $bundleApp linha ${_line()}");
      Get.lazyPut(() => AppsController(Get.find(), AppsRepository(Api())));
      if (Platform.isAndroid) {
        var app = await DeviceApps.getApp(bundleApp, true);
        if (app != null) {
          log("[BlockUnblockManager] App encontrado: ${app.appName} | bloqueando... linha ${_line()}");
          await Get.find<AppsController>().addToLockedApps(app);
        } else {
          log("[BlockUnblockManager] App não encontrado para $bundleApp linha ${_line()}");
        }
      }
    }
  }

  static Future<void> unblockApps(List<dynamic> apps) async {
    log("[BlockUnblockManager] unblockApps chamado com apps: $apps linha ${_line()}");

    if (Platform.isIOS) {
      log("[BlockUnblockManager] Enviando unlockApps para iOS via methodChannel linha ${_line()}");
      await NavigationService.methodChannel.invokeMethod('unlockApps', {'apps': apps});
    }

    if (Platform.isAndroid) {
      for (var bundleApp in apps) {
        log("[BlockUnblockManager] bundleApp atual: $bundleApp linha ${_line()}");
        var app = await DeviceApps.getApp(bundleApp, true);
        if (app != null) {
          log("[BlockUnblockManager] App encontrado: ${app.appName} | desbloqueando... linha ${_line()}");
          await Get.find<AppsController>().addToLockedApps(app);
        } else {
          log("[BlockUnblockManager] App não encontrado para $bundleApp linha ${_line()}");
        }
      }
    }
  }

  static int _line() => StackTrace.current.toString().split('\n')[1].contains(":") 
    ? int.tryParse(RegExp(r":(\d+):\d+\)$").firstMatch(StackTrace.current.toString().split('\n')[1])?.group(1) ?? '') ?? 0 
    : 0;
}
