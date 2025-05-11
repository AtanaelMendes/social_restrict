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
    controller.getCurrentLocation();
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
      print('Dayone voltou para primeiro plano Background mode');
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        controller.getCurrentLocation();
      });
    } else if (state == AppLifecycleState.paused) {
      print('Dayone mudou agora segundo plano Background mode');
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        controller.getCurrentLocation();
        //controller.startBackgroundFetch();
      });
    }
  }

  var jsonSettings = null;

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
  //     //Get.put(AppsController(Get.find(), AppsRepository(Api())));

  //     //Get.find<AppsController>().getAppsData();
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
        title: const Text('Social Restrict'),
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
            // Obx(
            //   () => Text(
            //     controller.latitude.toString(),
            //   ),
            // ),
            // const SizedBox(height: 10),
            // Obx(
            //   () => Text(
            //     controller.longitude.toString(),
            //   ),
            // ),
            // const SizedBox(height: 10),
            // Obx(
            //   () => Text(
            //     controller.fullAddress.value,
            //   ),
            // ),
            const SizedBox(height: 10),
            // ElevatedButton(
            //   onPressed: () {
            //     // controller.requestLocationPermission();
            //     controller.getCurrentLocation();
            //   },
            //   child: const Text('Get Location'),
            // ),
          ],
        ),
      ),
    );
  }

  // Future<void> requestLocationPermission() async {
  //   final ph.PermissionStatus status = await ph.Permission.location.request();
  //   if (status.isGranted) {
  //     // Permission granted; you can now retrieve the location.
  //   } else if (status.isDenied) {
  //     // Permission denied.
  //     print('Location_permission_denied');
  //   }
  // }

  // Future<void> getCurrentLocation() async {
  //   final loc.Location location = loc.Location();
  //   try {
  //     final loc.LocationData locationData = await location.getLocation();
  //     setState(() {
  //       latitude = locationData.latitude!;
  //       longitude = locationData.longitude!;
  //       getAddress(latitude, longitude);
  //     });
  //     // Handle the location data as needed.
  //   } catch (e) {
  //     // Handle errors, such as permissions not granted or location services disabled.
  //     print('Error getting location: $e');
  //   }
  // }

  // getAddress(double latitude, double longitude) async {
  //   try {
  //     List<Placemark> placemarks =
  //         await placemarkFromCoordinates(latitude, longitude);
  //     Placemark place = placemarks[0];

  //     String address =
  //         "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
  //     print(address);
  //     setState(() {
  //       fullAddress = address;
  //     });
  //   } catch (e) {
  //     print('No address available');
  //   }
  // }
}
