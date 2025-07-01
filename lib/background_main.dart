import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screentime/code_input_page.dart';
import 'package:flutter_screentime/modules/home/apps_controller.dart';
import 'package:flutter_screentime/android/widgets/ask_permission_dialog.dart';
import 'package:flutter_screentime/android/method_channel_controller.dart';
import 'package:flutter_screentime/navigation_service.dart';
import 'package:flutter_screentime/modules/qr-code/qrviewpage.dart';
import 'package:flutter_screentime/politica_de_privacidade.dart';
import 'package:flutter_screentime/tutorial_android_page.dart';
import 'package:flutter_screentime/tutorial_ios_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class BackgroundMain extends GetView {
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

class BackgroundMainPage extends GetView<AppsController> {
  const BackgroundMainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
      ),
      body: SafeArea(
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
                    "Solicite o código de ativação ao seu guardião para ativar o app, mas antes clique em \"VER TUTORIAL\", depois conceda as permissões necessárias clicando em \"VERIFICAR PERMISSÕES\".",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 4. Botão VER TUTORIAL
              OutlinedButton.icon(
                icon: const Icon(Icons.help_outline),
                label: const Text("VER TUTORIAL"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      if (Platform.isAndroid) {
                        return TutorialAndroidPage();
                        // return TutorialIosPage();
                      } else {
                        return TutorialIosPage();
                      }
                    },
                  ));
                },
              ),

              const SizedBox(height: 10),

              // VERIFICAR PERMISSÕES
              ElevatedButton.icon(
                icon: const Icon(Icons.verified_user),
                label: const Text("VERIFICAR PERMISSÕES"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                onPressed: () async {
                  askPermissionBottomSheet(NavigationService.navigatorKey.currentContext);
                },
              ),

              const SizedBox(height: 10),

              // 3. Botão INSERIR CÓDIGO (substituindo LER QR CODE)
              ElevatedButton.icon(
                icon: const Icon(Icons.vpn_key),
                label: const Text("INSERIR CÓDIGO"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                onPressed: () async {
                  // Verifica se todas as permissões foram concedidas antes de abrir a tela de código
                  if (await _checkAllPermissions()) {
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const CodeInputPage(),
                    ));
                    // initialize();
                  } else {
                    Fluttertoast.showToast(
                      msg: "Conceda todas as permissões antes de usar o código",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                    );
                  }
                },
              ),

              const SizedBox(height: 10),

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

  /// Verifica se todas as permissões necessárias foram concedidas
  Future<bool> _checkAllPermissions() async {
    try {
      final state = Get.find<MethodChannelController>();
      
      if (Platform.isAndroid) {
        // Para Android: verifica overlay, usage stats, notificação e background fetch
        bool overlayPermission = await state.checkOverlayPermission();
        bool usageStatsPermission = await state.checkUsageStatePermission();
        bool notificationPermission = await state.checkNotificationPermission();
        await state.checkBackgroundFetchStatus(); // Atualiza o status
        
        return overlayPermission && 
               usageStatsPermission && 
               notificationPermission && 
               state.isBackgroundFetchAvailable;
      } else {
        bool backgroundLocationPermission = await state.checkBackgroundLocationPermission();
        bool notificationPermission = await state.checkNotificationPermission();
        await state.checkBackgroundFetchStatus(); // Atualiza o status
        
        return
               backgroundLocationPermission && 
               notificationPermission && 
               state.isBackgroundFetchAvailable;
      }
    } catch (e) {
      debugPrint('Erro ao verificar permissões: $e');
      return false;
    }
  }
}
