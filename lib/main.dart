import 'dart:io';

import 'package:app_usage/app_usage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screentime/android/apps_controller.dart';
import 'package:flutter_screentime/android/method_channel_controller.dart';
import 'package:flutter_screentime/android/permission_controller.dart';
import 'package:flutter_screentime/android/widgets/ask_permission_dialog.dart';
import 'package:flutter_screentime/background_notification.dart';
import 'package:flutter_screentime/background_main.dart';
import 'package:flutter_screentime/block_unblock_manager.dart';
import 'package:flutter_screentime/init.dart';
import 'package:flutter_screentime/navigation_service.dart';
import 'package:get/instance_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }

  print('[BackgroundFetch] Headless event received.');
  // Do your work here...
  BackgroundFetch.finish(taskId);
}

const methodChannel = MethodChannel('flutter_screentime');

// void main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   await initialize();

//   runApp(const MyApp());
// }

Future<void> initState() async {
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

void initializeNotifications() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  NotificationHandler.initialize();

  print("TOKEN: " + fcmToken!);

  _firebaseMessaging.getToken().then((String? token) {
    assert(token != null);

    print('Firebase Messaging Token: $token');
  });
}

void getAndroidUsageStats() async {
  try {
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(days: 1));
    List<AppUsageInfo> infoList =
        await AppUsage().getAppUsage(startDate, endDate);

    for (var info in infoList) {
      print(info.toString());
    }
  } on AppUsageException catch (exception) {
    print(exception);
  }
}

setAndroidPasscode() async {
  Get.find<AppsController>().savePasscode("927594");
  await Get.find<MethodChannelController>().setPassword();
}

getAndroidPermissions() async {
  if (!(await Get.find<MethodChannelController>()
          .checkNotificationPermission()) ||
      !(await Get.find<MethodChannelController>().checkOverlayPermission()) ||
      !(await Get.find<MethodChannelController>()
          .checkUsageStatePermission())) {
    Get.find<MethodChannelController>().update();
  }

  await setAndroidPasscode();
  await Get.find<MethodChannelController>().startForeground();
}

final FlutterLocalNotificationsPlugin flutterLocalPlugin =
    FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel notificationChannel =
    AndroidNotificationChannel(
        "coding is life foreground", "coding is life foreground service",
        description: "This is channel des....", importance: Importance.high);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  lazyPutInitialize();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Get.put(prefs);
  await initservice();
  runApp(const BackgroundMain());

}

Future<void> initservice() async {
  BlockUnblockManager.unblockApps(['ph.telegra.Telegraph', 'com.copel.mbf']);

  //initState();
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: NavigationService.navigatorKey,
//       title: 'App Control',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'App Control'),
//     );
//   }
// }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      Get.put(AppsController(prefs: Get.find()));
      _initializeAndroidServices();
    }

    _initializeNotifications();
  }

  Future<void> _initializeAndroidServices() async {
    final appsController = Get.find<AppsController>();
    final methodController = Get.find<MethodChannelController>();
    final permissionController = Get.find<PermissionController>();

    await appsController.getAppsData();
    await appsController.getLockedApps();
    await methodController.addToLockedAppsMethod();
    await permissionController.getPermission(Permission.ignoreBatteryOptimizations);

    askPermissionBottomSheet(NavigationService.navigatorKey.currentContext);
    await _checkAndRequestAndroidPermissions();
    await _getAndroidUsageStats();
  }

  Future<void> _checkAndRequestAndroidPermissions() async {
    final methodController = Get.find<MethodChannelController>();

    if (!(await methodController.checkNotificationPermission()) ||
        !(await methodController.checkOverlayPermission()) ||
        !(await methodController.checkUsageStatePermission())) {
      methodController.update();
      askPermissionBottomSheet(context);
    }

    await _setAndroidPasscode();
    await methodController.startForeground();
  }

  Future<void> _setAndroidPasscode() async {
    final appsController = Get.find<AppsController>();
    await appsController.savePasscode("927594");
    await Get.find<MethodChannelController>().setPassword();
  }

  Future<void> _getAndroidUsageStats() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(days: 1));
      List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startDate, endDate);

      for (var info in infoList) {
        print(info.toString());
      }
    } on AppUsageException catch (e) {
      print("Erro ao obter uso de apps: $e");
    }
  }

  Future<void> _initializeNotifications() async {
    await FirebaseMessaging.instance.requestPermission();
    final token = await FirebaseMessaging.instance.getToken();

    NotificationHandler.initialize();
    print("TOKEN FCM: $token");
  }

  @override
  Widget build(BuildContext context) {
    return const BackgroundMainPage(title: "RHBrasil");
  }
}
