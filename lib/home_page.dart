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
        title: const Text('Social Restrict'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 10),
              child: const Text(
                'Instalação completa aplicativo PRONTO para receber atualizações',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
}
