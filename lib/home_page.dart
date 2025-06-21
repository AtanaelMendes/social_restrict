import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screentime/modules/home/apps_controller.dart';
import 'package:flutter_screentime/painel/login.dart';
// import 'package:flutter_screentime/modules/home/apps_repository.dart';
// import 'package:flutter_screentime/provider/api.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final controller = Get.find<AppsController>();
  Timer? _timer;
  bool isLoading = false; // <- flag para loading

  @override
  void initState() {
    super.initState();
    // controller.getCurrentLocation();
    WidgetsBinding.instance.addObserver(this);
    controller.startBackgroundFetch();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _timer?.cancel();
    if (state == AppLifecycleState.resumed) {
      debugPrint('SOCIAL RESTRICT voltou para primeiro plano');
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        // controller.getCurrentLocation();
      });
    } else if (state == AppLifecycleState.paused) {
      debugPrint('SOCIAL RESTRICT mudou agora segundo plano');
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        // controller.getCurrentLocation();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Social Restrict'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Image.asset(
                    'assets/icon/180.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Seu aplicativo está configurado, agora periodicamente iremos buscar a lista de restrições.",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: "Agora pode fechar o aplicativo ou atualize a lista clicando no botão "),
                        TextSpan(
                          text: "Buscar lista de restrições",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: "."),
                      ],
                    ),
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 24),
                  ),

                  const SizedBox(height: 20),

                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: "Também é possível acessar o painel administrativo clicando no botão "),
                        TextSpan(
                          text: "Painel administrativo",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: "."),
                      ],
                    ),
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 24),
                  )
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        await controller.initservice();
                        setState(() => isLoading = false);
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text("Buscar lista de restrições"),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        // Navega para a tela de login
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                child: const Text("Painel administrativo"),
              ),
              //  const SizedBox(height: 10),
              //   ElevatedButton(
              //     onPressed: () async  {
              //       await controller.selectAppsToEncourage();
              //     },
              //     child: const Text("Selecionar apps incentivados"),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
