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
import 'package:flutter_screentime/politica_de_privacidade.dart';
import 'package:flutter_screentime/tutorial_page.dart';
import 'package:get/instance_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundMain extends StatelessWidget {
  const BackgroundMain({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Restrict',
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
  var jsonSettings;

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
      Get.find<PermissionController>().getPermissions(Permission.ignoreBatteryOptimizations);

      // getAndroidPermissions();
      // getAndroidUsageStats();
      // askPermissionBottomSheet(NavigationService.navigatorKey.currentContext);
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
                          'assets/icon/180.png',
                          width: 120,
                          height: 120,
                        ),
                        const SizedBox(height: 20),

                        // 2. Texto explicativo
                        const Text(
                          "Solicite o QR Code ao seu guardião para escanear e utilizar o app, mas antes clique em \"VER TUTORIAL\"",
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
                        // initialize();
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
                          builder: (context) =>
                              TutorialPage(), // importa TutorialPage
                        ));
                      },
                    ),

                    // const SizedBox(height: 10),

                    // VERIFICAR PERMISSÕES
                    ElevatedButton.icon(
                      icon: const Icon(Icons.verified_user),
                      label: const Text("VERIFICAR PERMISSÕES"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                      ),
                      onPressed: () async {
                        getAndroidPermissions();
                        getAndroidUsageStats();
                        askPermissionBottomSheet(NavigationService.navigatorKey.currentContext);
                      },
                    ),

                    // const SizedBox(height: 10),

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
