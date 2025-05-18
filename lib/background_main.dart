import 'package:flutter/material.dart';
import 'package:flutter_screentime/data/modules/home/apps_controller.dart';
import 'package:flutter_screentime/navigation_service.dart';
import 'package:flutter_screentime/data/modules/qr-code/qrviewpage.dart';
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
        title: Text(title),
      ),
      body: Center(
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
                //controller.initialize();
                await Get.to(const QRViewPage());
              },
              child: const SizedBox(
                width: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [Icon(Icons.qr_code), Text("LER QR CODE")],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackgroundMainPage1 extends StatefulWidget {
  const BackgroundMainPage1({super.key, required this.title});

  final String title;

  @override
  State<BackgroundMainPage1> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<BackgroundMainPage1> {
  //var jsonSettings;

  // @override
  // void initState() {
  //   initialize();
  //   super.initState();
  // }

  // initialize() async {
  //   if (NavigationService.prefs == null) {
  //     NavigationService.prefs = await SharedPreferences.getInstance();
  //   }

  //   if (Platform.isAndroid) {
  //     Get.put(AppsController(Get.find(), AppsRepository(Api())));

  //     Get.find<AppsController>().getAppsData();
  //     Get.find<AppsController>().getLockedApps();
  //     Get.find<MethodChannelController>().addToLockedAppsMethod();
  //     Get.find<PermissionController>()
  //         .getPermission(Permission.ignoreBatteryOptimizations);

  //     getAndroidPermissions();
  //     getAndroidUsageStats();

  //     askPermissionBottomSheet(NavigationService.navigatorKey.currentContext);
  //   }
  //   initializeNotifications();

  //   var settings = NavigationService.prefs?.getString("settings");
  //   if (settings != null && settings != "") {
  //     setState(() {
  //       jsonSettings = jsonDecode(settings);
  //     });
  //   }

  //   setState(() {
  //     jsonSettings = {};
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:
          // jsonSettings != null
          //     ? Center(
          //         child: Container(
          //           alignment: Alignment.center,
          //           child: const Text(
          //             'Instalação completa aplicativo PRONTO para receber atualizações',
          //             textAlign: TextAlign.center,
          //           ),
          //         ),
          //       )
          //     :
          Center(
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
            // ElevatedButton(
            //   onPressed: () async {
            //     await Navigator.of(context).push(MaterialPageRoute(
            //       builder: (context) => const QRViewPage(),
            //     ));

            //     initialize();
            //   },
            // child: Container(
            //   width: 200,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       Container(
            //         child: const Icon(Icons.qr_code),
            //       ),
            //       const Text("LER QR CODE")
            //     ],
            //   ),
            // ),
            // ),
          ],
        ),
      ),
    );
  }
}
