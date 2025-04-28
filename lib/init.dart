import 'dart:async';

import 'package:social_restrict/android/apps_controller.dart';
import 'package:social_restrict/android/method_channel_controller.dart';
import 'package:social_restrict/android/permission_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> lazyPutInitialize() async {
  final prefs = await SharedPreferences.getInstance();
  Get.lazyPut(() => prefs);
  Get.lazyPut(() => AppsController(prefs: Get.find()));
  Get.lazyPut(() => MethodChannelController());
  Get.lazyPut(() => PermissionController());
}