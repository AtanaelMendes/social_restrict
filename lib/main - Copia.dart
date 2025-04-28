import 'dart:io';

import 'package:app_usage/app_usage.dart';
import 'package:device_apps/device_apps.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_restrict/android/apps_controller.dart';
import 'package:social_restrict/android/method_channel_controller.dart';
import 'package:social_restrict/android/permission_controller.dart';
import 'package:social_restrict/android/widgets/ask_permission_dialog.dart';
import 'package:social_restrict/background_notification.dart';
import 'package:social_restrict/background_main.dart';
import 'package:social_restrict/block_unblock_manager.dart';
import 'package:social_restrict/init.dart';
import 'package:social_restrict/navigation_service.dart';
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

const methodChannel = MethodChannel('social_restrict');

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
    if (Platform.isAndroid) {
      Get.put(AppsController(prefs: Get.find()));

      Get.find<AppsController>().getAppsData();
      Get.find<AppsController>().getLockedApps();
      Get.find<MethodChannelController>().addToLockedAppsMethod();
      Get.find<PermissionController>()
          .getPermission(Permission.ignoreBatteryOptimizations);
      
      askPermissionBottomSheet(NavigationService.navigatorKey.currentContext);
      getAndroidPermissions();
      getAndroidUsageStats();
    }
    initializeNotifications();

    super.initState();
  }

  void initializeNotifications() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await FirebaseMessaging.instance.requestPermission();
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    ;

    NotificationHandler.initialize();
    print("TOKEN: " + fcmToken!);
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
      askPermissionBottomSheet(context);
    }

    await setAndroidPasscode();
    await Get.find<MethodChannelController>().startForeground();
  }

  @override
  Widget build(BuildContext context) {
    return const BackgroundMainPage(title: "RHBrasil");
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(widget.title),
    //   ),
    //   body: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         TextButton(
    //           onPressed: () async {
    //             if (Platform.isIOS) {
    //               methodChannel.invokeMethod('blockApps', { 'apps': ['ph.telegra.Telegraph', 'com.copel.mbf'] });
    //             }

    //             if (Platform.isAndroid) {
    //                //var apps = await DeviceApps.getInstalledApplications(includeAppIcons: false, includeSystemApps: false, onlyAppsWithLaunchIntent: true);
    //                var app = await DeviceApps.getApp("com.google.android.youtube", true);
    //                await Get.find<AppsController>().addToLockedApps(app!);
    //             }

    //           },
    //           child: const Text('bloquear aplicativos'),
    //         ),
    //         TextButton(
    //           onPressed: () async {
    //             if (Platform.isIOS) {
    //               methodChannel.invokeMethod('unlockApps', { 'apps': ['ph.telegra.Telegraph', 'com.copel.mbf'] });
    //             }

    //             if (Platform.isAndroid) {
    //               //  var app = await DeviceApps.getApp("com.google.android.youtube", true);
    //               //  var appData = new ApplicationData(appName: app!.appName,
    //               //  apkFilePath: app!.apkFilePath, packageName: app!.packageName,
    //               //  versionName: app!.versionName!,
    //               //  versionCode: app!.versionCode!.toString(),
    //               //  dataDir: app!.dataDir!,
    //               //  systemApp: app!.systemApp,
    //               //  installTimeMillis: app!.installTimeMillis.toString(),
    //               //  updateTimeMillis: app!.updateTimeMillis.toString(),
    //               //  category: app!.category.name,
    //               //  enabled: app!.enabled);
    //               //  await Get.find<AppsController>().addRemoveFromLockedAppsFromSearch(appData);

    //                var app = await DeviceApps.getApp("com.google.android.youtube", true);
    //                await Get.find<AppsController>().addToLockedApps(app!);
    //             }

    //           },
    //           child: const Text('liberar aplicativos'),
    //          ),
    //           TextButton(
    //           onPressed: () {
    //             if (Platform.isIOS) {
    //               methodChannel.invokeMethod('report');
    //             }

    //             if (Platform.isAndroid) {

    //             }

    //           },
    //           child: const Text('Relatorio'),
    //          ),
    //         // TextButton(
    //         //   onPressed: () {
    //         //     methodChannel.invokeMethod('selectAppsToDiscourage');
    //         //   },
    //         //   child: const Text('selectAppsToDiscourage'),
    //         // ),
    //         // TextButton(
    //         //   onPressed: () {
    //         //     methodChannel.invokeMethod('selectAppsToEncourage');
    //         //   },
    //         //   child: const Text('selectAppsToEncourage'),
    //         // ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
