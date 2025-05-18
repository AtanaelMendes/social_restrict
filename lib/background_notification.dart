import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screentime/android/method_channel_controller.dart';
import 'package:flutter_screentime/android/permission_controller.dart';
import 'package:flutter_screentime/block_unblock_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class NotificationHandler {
  NotificationHandler._();
  static Future<void> onNotification(RemoteMessage message) async {
    var blockApps = jsonDecode(message.data["block"]);
    var unBlockApps = jsonDecode(message.data["unblock"]);
    print('Block apps: $blockApps');
    print('Unblock apps: $unBlockApps');

    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    Get.lazyPut(() => prefs);
    //Get.lazyPut(() => AppsController());
    Get.lazyPut(() => MethodChannelController());
    Get.lazyPut(() => PermissionController());

    await BlockUnblockManager.blockApps(blockApps);
    await BlockUnblockManager.unblockApps(unBlockApps);
  }

  static void initialize() {
    FirebaseMessaging.onMessageOpenedApp.forEach((RemoteMessage message) =>
        {NotificationHandler.onNotification(message)});
    FirebaseMessaging.onBackgroundMessage(NotificationHandler.onNotification);
    FirebaseMessaging.onMessage.forEach((RemoteMessage message) =>
        {NotificationHandler.onNotification(message)});
  }
}
