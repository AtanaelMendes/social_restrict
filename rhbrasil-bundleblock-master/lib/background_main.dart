import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screentime/android/apps_controller.dart';
import 'package:flutter_screentime/android/method_channel_controller.dart';
import 'package:flutter_screentime/android/permission_controller.dart';
import 'package:flutter_screentime/android/widgets/ask_permission_dialog.dart';
import 'package:flutter_screentime/main.dart';
import 'package:flutter_screentime/navigation_service.dart';
import 'package:flutter_screentime/qrviewpage.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/instance_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundMain extends StatelessWidget {
  const BackgroundMain({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DayOne',
      navigatorKey: NavigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BackgroundMainPage(title: 'DayOne Control'),
    );
  }
}

class BackgroundMainPage extends StatefulWidget {
  const BackgroundMainPage({super.key, required this.title});

  final String title;

  @override
  State<BackgroundMainPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<BackgroundMainPage> {
  var jsonSettings = null;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() async {
    if (NavigationService.prefs == null) {
      NavigationService.prefs = await SharedPreferences.getInstance();
    }

    if (Platform.isAndroid) {
      Get.put(AppsController(prefs: Get.find()));

      Get.find<AppsController>().getAppsData();
      Get.find<AppsController>().getLockedApps();
      Get.find<MethodChannelController>().addToLockedAppsMethod();
      Get.find<PermissionController>()
          .getPermission(Permission.ignoreBatteryOptimizations);
      
      getAndroidPermissions();
      getAndroidUsageStats();

      askPermissionBottomSheet(NavigationService.navigatorKey.currentContext);
    }
    initializeNotifications();

    var settings = NavigationService.prefs?.getString("settings");
    if (settings != null && settings != "") {
      setState(() {
        jsonSettings = jsonDecode(settings);
      });
    }

  }

  @override
  Widget build(BuildContext context) {
     

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: jsonSettings != null
          ? Center(
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  'Instalação completa aplicativo PRONTO para receber atualizações',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: const Text(
                      'Leia o QR code para finalizar a configuração do aplicativo',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const QRViewPage(),
                      ));

                      initialize();
                    },
                    child: Container(
                      width: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: const Icon(Icons.qr_code),
                          ),
                          const Text("LER QR CODE")
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
