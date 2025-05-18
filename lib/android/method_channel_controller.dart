import 'dart:developer';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screentime/data/modules/home/apps_controller.dart';
import 'package:flutter_screentime/android/constant.dart';
import 'package:flutter_screentime/navigation_service.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usage_stats/usage_stats.dart';

import 'permission_controller.dart';

const platform = const MethodChannel('samples.flutter.dev/native');

class MethodChannelController extends GetxController implements GetxService {
  static const platform = MethodChannel('flutter.native/helper');

  MethodChannelController() {
    WidgetsFlutterBinding.ensureInitialized();
    checkBackgroundFetchStatus(); // Chama a verificação do status do BackgroundFetch ao inicializar
  }

  bool isOverlayPermissionGiven = false;
  bool isUsageStatPermissionGiven = false;
  bool isNotificationPermissionGiven = false;
  bool isBackgroundLocationPermissionGiven = false;
  bool isBackgroundFetchAvailable = false;

  Future<bool> checkOverlayPermission() async {
    try {
      return await platform
          .invokeMethod('checkOverlayPermission')
          .then((value) {
        log("$value", name: "checkOverlayPermission");
        isOverlayPermissionGiven = value as bool;
        update();
        return isOverlayPermissionGiven;
      });
    } on PlatformException catch (e) {
      log("Failed to Invoke: '${e.message}'.");
      isOverlayPermissionGiven = false;
      update();
      return isOverlayPermissionGiven;
    }
  }

  Future<bool> checkNotificationPermission() async {
    return isNotificationPermissionGiven =
        await Permission.notification.isGranted;
  }

  Future<bool> checkUsageStatePermission() async {
    isUsageStatPermissionGiven =
        (await UsageStats.checkUsagePermission() ?? false);
    update();
    return isUsageStatPermissionGiven;
  }

  Future<bool> checkBackgroundLocationPermission() async {
    isBackgroundLocationPermissionGiven =
        await Permission.locationAlways.isGranted;
    update();
    return isBackgroundLocationPermissionGiven;
  }

  Future<void> checkBackgroundFetchStatus() async {
    int status = await BackgroundFetch.status;
    switch (status) {
      case BackgroundFetch.STATUS_RESTRICTED:
        log("BackgroundFetch status: RESTRICTED");
        isBackgroundFetchAvailable = false;
        break;
      case BackgroundFetch.STATUS_DENIED:
        log("BackgroundFetch status: DENIED");
        isBackgroundFetchAvailable = false;
        break;
      case BackgroundFetch.STATUS_AVAILABLE:
        log("BackgroundFetch status: AVAILABLE");
        isBackgroundFetchAvailable = true;
        break;
    }
    update();
  }

  addToLockedAppsMethod() async {
    try {
      Map<String, dynamic> data = {
        "app_list": Get.find<AppsController>().lockList.map((e) {
          return {
            "app_name": e.application!.appName,
            "package_name": e.application!.packageName,
            "file_path": e.application!.apkFilePath,
          };
        }).toList()
      };
      print('Os valores que estao no data: $data');
      await setPassword();
      await platform.invokeMethod('addToLockedApps', data).then((value) {
        log("$value", name: "addToLockedApps CALLED");
      });
    } on PlatformException catch (e) {
      log("Failed to Invoke: '${e.message}'.");
    }
  }

  Future setPassword() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      String data = prefs.getString(AppConstants.setPassCode) ?? "";
      log(data, name: "PASSWORD--");
      if (data != "") {
        await platform.invokeMethod('setPasswordInNative', data).then((value) {
          log("$value", name: "setPasswordInNative CALLED");
        });
      }
    } on PlatformException catch (e) {
      log("Failed to Invoke: '${e.message}'.");
    }
  }

  Future stopForeground() async {
    try {
      await platform.invokeMethod('stopForeground', "").then((value) {
        log("$value", name: "stopForeground CALLED");
      });
    } on PlatformException catch (e) {
      log("Failed to Invoke: '${e.message}'.");
    }
  }

  Future startForeground() async {
    try {
      await platform.invokeMethod('startForeground', "").then((value) {
        log("$value", name: "startForeground CALLED");
      });
    } on PlatformException catch (e) {
      log("Failed to Invoke: '${e.message}'.");
    }
  }

  Future<bool> askNotificationPermission() async {
    await Get.find<PermissionController>()
        .getPermissions([Permission.notification]);
    isNotificationPermissionGiven = await Permission.notification.isGranted;
    update();
    return isNotificationPermissionGiven;
  }

  Future<bool> askOverlayPermission() async {
    try {
      return await platform.invokeMethod('askOverlayPermission').then((value) {
        log("$value", name: "askOverlayPermission");
        isOverlayPermissionGiven = (value as bool);
        update();
        return isOverlayPermissionGiven;
      });
    } on PlatformException catch (e) {
      log("Failed to Invoke: '${e.message}'.");
      return false;
    }
  }

  Future<bool> askUsageStatsPermission() async {
    try {
      return await platform
          .invokeMethod('askUsageStatsPermission')
          .then((value) {
        log("$value", name: "askUsageStatsPermission");
        return (value as bool);
      });
    } on PlatformException catch (e) {
      log("Failed to Invoke: '${e.message}'.");
      return false;
    }
  }

  Future<bool> askBackgroundLocationPermission() async {
    await Get.find<PermissionController>()
        .getPermissions([Permission.locationAlways]);
    isBackgroundLocationPermissionGiven =
        await Permission.locationAlways.isGranted;
    update();
    return isBackgroundLocationPermissionGiven;
  }

  void sendValuesToNative() async {
    try {
      final int? id = NavigationService.prefs?.getInt("id");
      final int? companyId = NavigationService.prefs?.getInt("companyId");
      final String? tokenId = NavigationService.prefs?.getString("token");

      final Map<String, dynamic> values = {
        'id': id,
        'companyId': companyId,
        'tokenId': tokenId,
      };

      final String result = await platform.invokeMethod('sendValues', values);
      print('Received: $result');
    } on PlatformException catch (e) {
      print("Failed to send values: '${e.message}'.");
    }
  }
}
