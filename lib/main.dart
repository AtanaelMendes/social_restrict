import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screentime/config/env.dart';
import 'package:flutter_screentime/modules/home/apps_controller.dart';
import 'package:flutter_screentime/background_main.dart';
import 'package:flutter_screentime/modules/home/apps_repository.dart';
import 'package:flutter_screentime/provider/api.dart';
import 'package:flutter_screentime/home_page.dart';
import 'package:flutter_screentime/init.dart';
import 'package:flutter_screentime/navigation_service.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:background_fetch/background_fetch.dart';
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
  BackgroundFetch.finish(taskId);
}

const methodChannel = MethodChannel('flutter_screentime');

Future<void> initState() async {
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
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
  companyId = NavigationService.prefs?.getInt("companyId") ?? 0;
  customerId = NavigationService.prefs?.getInt("id") ?? 0;
  await dotenv.load(fileName: '.env');
  await Env.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AppsController(Get.find(), AppsRepository(Api())));
    return GetMaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'App Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int customerId = 0;
  @override
  void initState() {
    super.initState();
    loadCustomerId();
  }

  Future<void> loadCustomerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      customerId = prefs.getInt('id') ?? 0;
      debugPrint('CustomerID na MAIN: $customerId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: customerId == 0
          ? const BackgroundMainPage(title: "Social Restrict")
          : const HomePage(),
    );
  }
}
