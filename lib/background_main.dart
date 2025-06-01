import 'package:flutter/material.dart';
import 'package:flutter_screentime/modules/home/apps_controller.dart';
import 'package:flutter_screentime/android/widgets/ask_permission_dialog.dart';
import 'package:flutter_screentime/navigation_service.dart';
import 'package:flutter_screentime/modules/qr-code/qrviewpage.dart';
import 'package:flutter_screentime/politica_de_privacidade.dart';
import 'package:flutter_screentime/tutorial_android_page.dart';
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
                    "Solicite o QR Code ao seu guardião para escanear e utilizar o app, mas antes clique em \"VER TUTORIAL\"",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),

              const SizedBox(height: 10),

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
                    builder: (context) => TutorialPage(), // importa TutorialPage
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
