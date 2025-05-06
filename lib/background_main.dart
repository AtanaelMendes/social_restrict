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
import 'package:flutter_screentime/PoliticaDePrivacidade.dart';
import 'package:flutter_screentime/TutorialPage.dart';
import 'package:get/instance_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundMain extends StatelessWidget {
  const BackgroundMain({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SocialRestrict',
      navigatorKey: NavigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BackgroundMainPage(title: 'Social Restrict'),
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
        centerTitle: true,
      ),
      body: jsonSettings != null
          ? Center(
        child: Container(
          alignment: Alignment.center,
          child: const Text(
            'Instalação completa. Aplicativo PRONTO para receber atualizações.',
            textAlign: TextAlign.center,
          ),
        ),
      )
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Logo do App
              Column(
                children: [
                  Image.asset(
                    'assets/icon/socialrestrict.jpg',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 20),

                  // 2. Texto explicativo
                  const Text(
                    "Solicite o QR Code ao seu guardião para poder escanear e utilizar o app.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),

              // 3. Botão LER QR CODE
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code),
                label: const Text("LER QR CODE"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const QRViewPage(),
                  ));
                  initialize();
                },
              ),

              // 4. Botão VER TUTORIAL
              OutlinedButton.icon(
                icon: const Icon(Icons.help_outline),
                label: const Text("VER TUTORIAL"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TutorialPage(), // importa TutorialPage
                  ));
                },
              ),

              // 5. Botão Política de Privacidade
              ElevatedButton.icon(
                icon: const Icon(Icons.privacy_tip),
                label: const Text("Política de Privacidade"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const PoliticaDePrivacidade(),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


}
