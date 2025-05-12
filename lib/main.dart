import 'dart:io';

import 'package:app_usage/app_usage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screentime/android/permission_controller.dart';
import 'package:flutter_screentime/config/env.dart';
import 'package:flutter_screentime/modules/home/apps_controller.dart';
import 'package:flutter_screentime/android/method_channel_controller.dart';
import 'package:flutter_screentime/background_notification.dart';
import 'package:flutter_screentime/background_main.dart';
// import 'package:flutter_screentime/modules/home/apps_repository.dart';
// import 'package:flutter_screentime/provider/api.dart';
// import 'package:flutter_screentime/home_page.dart';
import 'package:flutter_screentime/init.dart';
import 'package:flutter_screentime/navigation_service.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screentime/block_unblock_manager.dart';
import 'package:flutter_screentime/android/widgets/ask_permission_dialog.dart';

import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

int companyId = NavigationService.prefs?.getInt("companyId") ?? 0;
int customerId = NavigationService.prefs?.getInt("id") ?? 0;

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    debugPrint("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  debugPrint('[BackgroundFetch] Headless event received.');
  // Do your work here...
  BackgroundFetch.finish(taskId);
}

const methodChannel = MethodChannel('flutter_screentime');

Future<void> initState() async {
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

Future<void> _requestPermissions() async {
  // Solicita permissões de localização em primeiro plano
  var statusFine = await Permission.location.request();
  var statusCoarse = await Permission.locationAlways.request();

  if (statusFine.isGranted && statusCoarse.isGranted) {
    // Permissões concedidas
    debugPrint("Permissões de localização concedidas");
  } else {
    // Permissões não concedidas
    debugPrint("Permissões de localização não concedidas");
  }
}

void initializeNotifications() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Permission.notification.request(); // <- Android 13+
  await FirebaseMessaging.instance.requestPermission();
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  NavigationService.prefs = await SharedPreferences.getInstance();
  NavigationService.prefs?.setString("token", fcmToken!);
  String tokenPrefereces = NavigationService.prefs?.getString("token") ?? "";

  NotificationHandler.initialize();
  debugPrint("TOKENPREFERE: $tokenPrefereces");

  _firebaseMessaging.getToken().then((String? token) {
    assert(token != null);
    debugPrint('Firebase Messaging Token: $token');
  });
}

void getAndroidUsageStats() async {
  try {
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(days: 1));
    List<AppUsageInfo> infoList =
        await AppUsage().getAppUsage(startDate, endDate);

    for (var info in infoList) {
      debugPrint(
          'Funcao do FLUTTER tempo uso ${info.packageName} ${info.usage.inMinutes}');
    }
  } on AppUsageException catch (exception) {
    debugPrint(exception.toString());
  }
}

setAndroidPasscode() async {
  Get.find<AppsController>().savePasscode("927594");
  await Get.find<MethodChannelController>().setPassword();
}

getAndroidPermissions() async {
  if (!(await Get.find<MethodChannelController>().checkNotificationPermission()) ||
      !(await Get.find<MethodChannelController>().checkOverlayPermission()) ||
      !(await Get.find<MethodChannelController>().checkUsageStatePermission())) {
    Get.find<MethodChannelController>().update();
  }

  await setAndroidPasscode();
  await Get.find<MethodChannelController>().startForeground();
}

final FlutterLocalNotificationsPlugin flutterLocalPlugin = FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel notificationChannel = AndroidNotificationChannel(
  "coding is life foreground", "coding is life foreground service",
  description: "This is channel des....", importance: Importance.high
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  lazyPutInitialize();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Get.put(prefs);
  // initializeNotifications();
  // await _requestPermissions();
  // companyId = NavigationService.prefs?.getInt("companyId") ?? 0;
  // customerId = NavigationService.prefs?.getInt("id") ?? 0;
  // await dotenv.load(fileName: '.env');
  // await Env.instance.load();
  await initservice();
  runApp(const BackgroundMain());
}

Future<void> initservice() async {
  BlockUnblockManager.unblockApps(['ph.telegra.Telegraph', 'com.copel.mbf']);
}

// void requestAllPermissions() async {
//   PermissionController permissionController = Get.find();
//   await permissionController.getPermissions([
//     Permission.location,
//     Permission.camera,
//   ]);
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     Get.put(AppsController(Get.find(), AppsRepository(Api())));
//     return GetMaterialApp(
//       navigatorKey: NavigationService.navigatorKey,
//       title: 'App Control',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(),
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
  int customerId = 0;

  @override
  void initState() {
    super.initState();
    // requestLocationPermission();
    if (Platform.isAndroid) {
      Get.put(AppsController(prefs: Get.find()));
      _initializeAndroidServices();
    }

    // _initializeNotifications();
  }

  Future<void> _initializeAndroidServices() async {
    final appsController = Get.find<AppsController>();
    final methodController = Get.find<MethodChannelController>();
    final permissionController = Get.find<PermissionController>();

    await appsController.getAppsData();
    await appsController.getLockedApps();
    await methodController.addToLockedAppsMethod();
    await permissionController.getPermissions(Permission.ignoreBatteryOptimizations);

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
        debugPrint(info.toString());
      }
    } on AppUsageException catch (e) {
      debugPrint("Erro ao obter uso de apps: $e");
    }
  }

  Future<void> _initializeNotifications() async {
    await Permission.notification.request();
    await FirebaseMessaging.instance.requestPermission();
    final token = await FirebaseMessaging.instance.getToken();

    NotificationHandler.initialize();
    debugPrint("TOKEN FCM: $token");
  }

  // Future<void> requestLocationPermission() async {
  //   var status = await Permission.location.request();
  //   if (status.isGranted) {
  //     loadCustomerId();
  //   } else {
  //     debugPrint('Location permission denied');
  //   }
  // }

  // Future<void> loadCustomerId() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     customerId = prefs.getInt('id') ?? 0;
  //     debugPrint('CustomerID na MAIN: $customerId');
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return const BackgroundMainPage(title: "Social Restrict");
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: customerId == 0
  //         ? const BackgroundMainPage(title: "Social Restrict")
  //         : const HomePage(),
  //   );
  // }
}
