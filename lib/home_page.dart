import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screentime/modules/home/apps_controller.dart';
import 'package:flutter_screentime/modules/home/apps_repository.dart';
import 'package:flutter_screentime/provider/api.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final controller = Get.put(AppsController(Get.find(), AppsRepository(Api())));
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // controller.getCurrentLocation();
    WidgetsBinding.instance.addObserver(this);
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
      debugPrint('Dayone voltou para primeiro plano Background mode');
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        // controller.getCurrentLocation();
      });
    } else if (state == AppLifecycleState.paused) {
      debugPrint('Dayone mudou agora segundo plano Background mode');
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        // controller.getCurrentLocation();
        //controller.startBackgroundFetch();
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
                    "Seu aplicativo está configurado e pronto para receber atualizações.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Agora pode fechar o aplicativo que cuidaremos do resto.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
