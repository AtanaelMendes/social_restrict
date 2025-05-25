import 'dart:io';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screentime/modules/home/apps_controller.dart';
import 'package:flutter_screentime/android/constant.dart';
import 'package:flutter_screentime/navigation_service.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usage_stats/usage_stats.dart';
import 'permission_controller.dart';

class MethodChannelController extends GetxController implements GetxService {
  static const platform = MethodChannel('flutter.native/helper');

  MethodChannelController() {
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  void onInit() {
    super.onInit();
    checkBackgroundFetchStatus();
  }

  bool isOverlayPermissionGiven = false;
  bool isUsageStatPermissionGiven = false;
  bool isNotificationPermissionGiven = false;
  bool isBackgroundLocationPermissionGiven = false;
  bool isBackgroundFetchAvailable = false;

  Future<void> checkBackgroundFetchStatus() async {
    int status = await BackgroundFetch.status;
    switch (status) {
      case BackgroundFetch.STATUS_RESTRICTED:
        log("AQUI NO BackgroundFetchStatus: RESTRICTED");
        isBackgroundFetchAvailable = false;
        break;
      case BackgroundFetch.STATUS_DENIED:
        log("AQUI NO BackgroundFetchStatus: DENIED");
        isBackgroundFetchAvailable = false;
        break;
      case BackgroundFetch.STATUS_AVAILABLE:
        log("AQUI NO BackgroundFetchStatus: AVAILABLE");
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
        log("$value", name: "addToLockedApps CHAMADO");
      });
    } on PlatformException catch (e) {
      log("Failed to Invoke: '${e.message}'.");
    }
  }

  Future setPassword() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      String data = prefs.getString(AppConstants.setPassCode) ?? "";
      log(data, name: "Definindo PASSWORD-----------");
      if (data != "") {
        await platform.invokeMethod('setPasswordInNative', data).then((value) {
          log("$value", name: "setPasswordInNative CHAMADO");
        });
      }
    } on PlatformException catch (e) {
      log("Failed to Invoke: '${e.message}'.");
    }
  }

  Future stopForeground() async {
    try {
      await platform.invokeMethod('stopForeground', "").then((value) {
        log("$value", name: "stopForeground CHAMADO");
      });
    } on PlatformException catch (e) {
      log("Falha ao parar stopForeground: '${e.message}'.");
    }
  }

  Future startForeground() async {
    try {
      // Captura stack trace para saber quem chamou a função
      final stack = StackTrace.current;

      await platform.invokeMethod('startForeground', "").then((value) {
        log(
          "Chamando startForeground:  $value\nCaller:\n$stack",
          name: "ForegroundService",
        );
      });
    } on PlatformException catch (e) {
      log("Falha ao pedir permissao startForeground: '${e.message}'.");
    }
  }

  Future<bool> checkNotificationPermission() async {
    log("chamando checkNotificationPermission");
    // if (Platform.isAndroid) {
    //   final status = await Permission.notification.status;
    //   if (status.isGranted) {
    //     isNotificationPermissionGiven = true;
    //   } else {
    //     isNotificationPermissionGiven = false;
    //   }
    // }
    // if (Platform.isIOS) {
    // }
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      isNotificationPermissionGiven = true;
    } else {
      isNotificationPermissionGiven = false;
    }
    update();
    return isNotificationPermissionGiven;
  }

  Future<bool> askNotificationPermission() async {
    log("🔔 Verificando permissão de notificação...");

    // if (Platform.isAndroid) {
    //   // Verifica se já está concedida no Android
    //   final status = await Permission.notification.status;
    //   if (status.isGranted) {
    //     isNotificationPermissionGiven = true;
    //   } else {
    //     final result = await Permission.notification.request();
    //     isNotificationPermissionGiven = result.isGranted;
    //   }
    // }
    // if (Platform.isIOS) {
      // Verifica status atual no iOS via Firebase Messaging
    // }
    await Firebase.initializeApp();
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      isNotificationPermissionGiven = true;
    } else {
      final requested = await FirebaseMessaging.instance.requestPermission();
      isNotificationPermissionGiven = requested.authorizationStatus == AuthorizationStatus.authorized;
    }

    if (isNotificationPermissionGiven) {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint("FCM Token: $fcmToken");
      log("FCM Token: $fcmToken");

      NavigationService.prefs = await SharedPreferences.getInstance();
      NavigationService.prefs?.setString("token", fcmToken ?? "");
      log("Permissão de notificação concedida.");
    } else {
      log("Permissão de notificação não concedida.");
    }

    update();
    return isNotificationPermissionGiven;
  }

  Future<bool> checkOverlayPermission() async {
    log("CHECANDO permissao checkOverlayPermission");
    try {
      return await platform.invokeMethod('checkOverlayPermission').then((value) {
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

  Future<bool> askOverlayPermission() async {
    log("PEDIDNDO permissao askOverlayPermission");
    try {
      return await platform.invokeMethod('askOverlayPermission').then((value) {
        log("$value", name: "askOverlayPermission");
        isOverlayPermissionGiven = (value as bool);
        update();
        return isOverlayPermissionGiven;
      });
    } on PlatformException catch (e) {
      log("Falha ao pedir permissao askOverlayPermission: '${e.message}'.");
      return false;
    }
  }

  Future<bool> checkUsageStatePermission() async {
    log("CHECANDO permissao checkUsageStatePermission");
    isUsageStatPermissionGiven = (await UsageStats.checkUsagePermission() ?? false);
    update();
    return isUsageStatPermissionGiven;
  }

  Future<bool> askUsageStatsPermission() async {
    log("PEDINDO permissao askUsageStatsPermission");
    try {
      return await platform.invokeMethod('askUsageStatsPermission').then((value) {
        log("$value", name: "askUsageStatsPermission");
        isUsageStatPermissionGiven = (value as bool);
        update();
        return isUsageStatPermissionGiven;
      });
    } on PlatformException catch (e) {
      log("Falha ao pedir permissao askUsageStatsPermission: '${e.message}'.");
      return false;
    }
  }

  Future<bool> checkBackgroundLocationPermission() async {
    log("CHECANDO permissao checkBackgroundLocationPermission");
    isBackgroundLocationPermissionGiven = await Permission.locationAlways.isGranted;
    update();
    return isBackgroundLocationPermissionGiven;
  }

  Future<bool> askBackgroundLocationPermission() async {
    log("PEDINDO permissao askBackgroundLocationPermission");
    await Get.find<PermissionController>().getPermissions([Permission.locationAlways]);
    isBackgroundLocationPermissionGiven = await Permission.locationAlways.isGranted;
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
      print('RECEBIDO: $result');
    } on PlatformException catch (e) {
      print("Falaha ao enviar valores para o native: '${e.message}'.");
    }
  }
}
