import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:background_fetch/background_fetch.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screentime/android/application_model.dart';
import 'package:flutter_screentime/android/constant.dart';
import 'package:flutter_screentime/android/method_channel_controller.dart';
import 'package:flutter_screentime/android/permission_controller.dart';
import 'package:flutter_screentime/android/widgets/ask_permission_dialog.dart';
import 'package:flutter_screentime/block_unblock_manager.dart';
import 'package:flutter_screentime/models/block_app_model.dart';
import 'package:flutter_screentime/models/location_model.dart';
import 'package:flutter_screentime/modules/home/apps_repository.dart';
import 'package:flutter_screentime/provider/api.dart';
import 'package:flutter_screentime/main.dart';
import 'package:flutter_screentime/navigation_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
// import 'package:location/location.dart' as loc;
// import 'package:location/location.dart';
// import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppsController extends GetxController implements GetxService {
  SharedPreferences prefs;
  final AppsRepository repository;
  AppsController(
      this.prefs,
      this.repository,
  );


  String? dummyPasscode;
  int? selectQuestion;
  TextEditingController typeAnswer = TextEditingController();
  TextEditingController checkAnswer = TextEditingController();
  TextEditingController searchApkText = TextEditingController();
  List<Application> unLockList = [];
  List<ApplicationDataModel> searchedApps = [];
  List<ApplicationDataModel> lockList = [];
  List<String> selectLockList = [];
  bool addToAppsLoading = false;
  List<AppInfo> blockApps = [];
  List<AppInfo> unBlockApps = [];
  Timer? timer;

  final PermissionController permissionController = Get.find();

  RxDouble latitude = RxDouble(0.0);
  RxDouble longitude = RxDouble(0.0);
  RxString fullAddress = RxString('');

  double? latitudeValue;
  double? longitudeValue;

  List<String> excludedApps = ["com.android.settings"];

  int appSearchUpdate = 1;
  int addRemoveToUnlockUpdate = 2;
  int addRemoveToUnlockUpdateSearch = 3;

  var jsonSettings = {}.obs;

  @override
  void onReady() {
    initialize();
    timer = Timer.periodic(const Duration(minutes: 2), (timer) {
      initservice();
    });
    super.onReady();
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  initialize() async {
    NavigationService.prefs ??= await SharedPreferences.getInstance();

    if (Platform.isAndroid) {
      Get.put(AppsController(Get.find(), AppsRepository(Api())));

      Get.find<AppsController>().getAppsData();
      Get.find<AppsController>().getLockedApps();

      Get.find<PermissionController>().getPermissions(Permission.ignoreBatteryOptimizations);

      getAndroidPermissions();
      getAndroidUsageStats();

      askPermissionBottomSheet(NavigationService.navigatorKey.currentContext);
    }
    initializeNotifications();

    var settings = NavigationService.prefs?.getString("settings");
    if (settings != null && settings != "") {
      jsonSettings.value = jsonDecode(settings);
    }

    jsonSettings.value = {};
  }

  changeQuestionIndex(index) {
    selectQuestion = index;
    update();
  }

  resetAskQuetionsPage() {
    selectQuestion = null;
    typeAnswer.clear();
    checkAnswer.clear();
  }

  void maybeAskPermissionBottomSheet(context) async {
    var controller = Get.find<MethodChannelController>();
    if (!(await controller.checkOverlayPermission() &&
        await controller.checkUsageStatePermission() &&
        await controller.checkNotificationPermission())) {
      askPermissionBottomSheet(context);
    }
  }

  savePasscode(counter) {
    prefs.setString(AppConstants.setPassCode, counter);
    Get.find<MethodChannelController>().setPassword();
    log("${prefs.getString(AppConstants.setPassCode)}", name: "save passcode");
  }

  getPasscode() {
    return prefs.getString(AppConstants.setPassCode) ?? "";
  }

  removePasscode() {
    return prefs.remove(AppConstants.setPassCode);
  }

  setSplash() {
    prefs.setBool("Splash", true);
    return prefs.getBool("Splash");
  }

  getSplash() async {
    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getBool("Splash")) != null) {
      return true;
    } else {
      return false;
    }
  }

  excludeApps() {
    for (var e in excludedApps) {
      unLockList.removeWhere((element) => element.packageName == e);
    }
  }

  getAppsData() async {
    unLockList = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );
    excludeApps();
    update();
  }

  addRemoveFromLockedAppsFromSearch(ApplicationData app) {
    addToAppsLoading = true;
    update();
    try {
      if (selectLockList.contains(app.appName)) {
        selectLockList.remove(app.appName);
        lockList.removeWhere((element) => element.application!.appName == app.appName);
      } else {
        if (lockList.length < 16) {
          selectLockList.add(app.appName);
          lockList.add(
            ApplicationDataModel(
              isLocked: true,
              application: ApplicationData(
                apkFilePath: app.apkFilePath,
                appName: app.appName,
                category: app.category,
                dataDir: app.dataDir,
                enabled: app.enabled,
                icon: getAppIcon(app.appName),
                installTimeMillis: app.installTimeMillis,
                packageName: app.packageName,
                systemApp: app.systemApp,
                updateTimeMillis: app.updateTimeMillis,
                versionCode: app.versionCode,
                versionName: app.versionName,
              ),
            ),
          );
        } else {
          Fluttertoast.showToast(msg: "You can add only 16 apps in locked list");
        }
      }
    } catch (e) {
      log("-------$e", name: "addRemoveFromLockedAppsFromSearch");
    }
    addToAppsLoading = false;
    update();
  }

  addToLockedApps(Application app) async {
    addToAppsLoading = true;
    update([addRemoveToUnlockUpdate]);

    try {
      if (selectLockList.contains(app.appName)) {
        selectLockList.remove(app.appName);
        lockList.removeWhere((em) => em.application!.appName == app.appName);
        log("REMOVE: $selectLockList");
        Get.find<MethodChannelController>().addToLockedAppsMethod();
      } else {
        if (lockList.length < 16) {
          selectLockList.add(app.appName);
          lockList.add(
            ApplicationDataModel(
              isLocked: true,
              application: ApplicationData(
                apkFilePath: app.apkFilePath,
                appName: app.appName,
                category: "${app.category}",
                dataDir: "${app.dataDir}",
                enabled: app.enabled,
                icon: (app as ApplicationWithIcon).icon,
                installTimeMillis: "${app.installTimeMillis}",
                packageName: app.packageName,
                systemApp: app.systemApp,
                updateTimeMillis: '${app.updateTimeMillis}',
                versionCode: '${app.versionCode}',
                versionName: '${app.versionName}',
              ),
            ),
          );
          log("ADD: $selectLockList", name: "addToLockedApps");
          Get.find<MethodChannelController>().addToLockedAppsMethod();
        } else {
          Fluttertoast.showToast(msg: "You can add only 16 apps in locked list");
        }
      }
    } catch (e) {
      log("-------$e", name: "addToLockedApps");
    }
    prefs.setString(AppConstants.lockedApps, applicationDataModelToJson(lockList));
    addToAppsLoading = false;
    update([addRemoveToUnlockUpdate]);
  }

  getLockedApps() {
    try {
      lockList = applicationDataModelFromJson(prefs.getString(AppConstants.lockedApps) ?? '');
      selectLockList.clear();
      log('${lockList.length}', name: "STORED LIST");
      for (var e in lockList) {
        selectLockList.add(e.application!.appName);
      }
      log('${lockList.length}-$selectLockList', name: "Locked Apps");
    } catch (e) {
      log("-------$e", name: "getLockedApps");
    }

    update();
  }

  Uint8List getAppIcon(String appName) {
    return (unLockList[unLockList.indexWhere((element) {
      return appName == element.appName;
    })] as ApplicationWithIcon)
        .icon;
  }

  appSearch() {
    searchedApps.clear();
    if (searchApkText.text.length > 2) {
      for (var e in unLockList) {
        if (e.appName.toUpperCase().contains(searchApkText.text.toUpperCase().trim())) {
          searchedApps.add(
            ApplicationDataModel(
              isLocked: null,
              application: ApplicationData(
                apkFilePath: e.apkFilePath,
                appName: e.appName,
                category: "${e.category}",
                dataDir: "${e.dataDir}",
                enabled: e.enabled,
                icon: (e as ApplicationWithIcon).icon,
                installTimeMillis: "${e.installTimeMillis}",
                packageName: e.packageName,
                systemApp: e.systemApp,
                updateTimeMillis: '${e.updateTimeMillis}',
                versionCode: '${e.versionCode}',
                versionName: '${e.versionName}',
              ),
            ),
          );
        }
      }
      update([appSearchUpdate]);
    }
  }

  onUpdateAppBlocks() async {
    AppInfo? appInfo;
    String? blockBundle;
    List<String> blockBundles = [];
    String? unBlockBundle;
    List<String> unBlockBundles = [];

    blockApps = [
      AppInfo(id: 10, bundle: 'br.com.brainweb.ifood'),
      AppInfo(id: 12, bundle: 'com.google.android.youtube'),
      AppInfo(id: 12, bundle: 'com.linkedin.android'),
      AppInfo(id: 12, bundle: 'com.mercadolibre')
    ];
    unBlockApps = [];

    for (var e in blockApps) {
      blockBundle = e.bundle;
      blockBundles.add(blockBundle ?? '');
      if (blockApps != null && blockApps.isNotEmpty) {
        await BlockUnblockManager.blockApps(blockBundles);
      }
    }
    for (var e in unBlockApps) {
      unBlockBundle = e.bundle;
      unBlockBundles.add(unBlockBundle ?? '');
      if (unBlockApps != null && unBlockApps.isNotEmpty) {
        await BlockUnblockManager.unblockApps(unBlockBundles);
      }
      debugPrint('O valor que esta no unBlockBundle: $unBlockBundle');
    }
    debugPrint('Os valores que estao no blockApps: $blockApps' + 'Os valores que estao no unBlockApps: $unBlockApps');
    update();
  }

  // Future<void> getCurrentLocation() async {
  //   final loc.Location location = loc.Location();
  //   try {
  //     final loc.LocationData locationData = await location.getLocation();
  //     latitude.value = locationData.latitude!;
  //     longitude.value = locationData.longitude!;
  //     getAddress(latitude.value, longitude.value);
  //     location.onLocationChanged.listen((loc.LocationData currentLocation) {
  //       latitude.value = currentLocation.latitude!;
  //       longitude.value = currentLocation.longitude!;
  //       getAddress(latitude.value, longitude.value);
  //     });
  //     location.enableBackgroundMode(enable: true);
  //     location.isBackgroundModeEnabled().then((value) {
  //       debugPrint('Dayone primeiro plano Background mode: $value');
  //     });
  //   } catch (e) {
  //     debugPrint('Dayone primeiro plano Error getting location: $e');
  //   }
  // }

  // getAddress(double latitude, double longitude) async {
  //   try {
  //     List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
  //     Placemark place = placemarks[0];
  //
  //     String address = "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
  //
  //     String foregroundOrBackground = WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed ? 'primeiro plano' : 'segundo plano';
  //
  //     latitudeValue = latitude;
  //     longitudeValue = longitude;
  //
  //     fullAddress.value = address;
  //   } catch (e) {
  //     debugPrint('Dayone primeiro plano No address available');
  //   }
  // }

  void startBackgroundFetch() {
    BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 1,
          stopOnTerminate: true,
          startOnBoot: false,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          requiredNetworkType: NetworkType.NONE,
        ), (String taskId) async {
      // LocationData locationData = await fetchLocation() ?? LocationData.fromMap({});

      BackgroundFetch.finish(taskId);
    }).then((int status) async {
      // LocationData locationData = await fetchLocation() ?? LocationData.fromMap({});
    }).catchError((e) {});
  }

  // Future<LocationData?> fetchLocation() async {
  //   loc.Location location = loc.Location();
  //   bool serviceEnabled = await location.serviceEnabled();
  //   if (!serviceEnabled) {
  //     serviceEnabled = await location.requestService();
  //     if (!serviceEnabled) {
  //       return null;
  //     }
  //   }
  //
  //   await permissionController.getPermissions([Permission.location]);
  //
  //   loc.PermissionStatus permissionStatus = await location.hasPermission();
  //   if (permissionStatus != loc.PermissionStatus.granted) {
  //     return null;
  //   }
  //
  //   return await location.getLocation();
  // }

  Future<void> sendLocation(
    int customerId,
    double latitude,
    double longitude,
  ) async {
    LocationModel locationModel = LocationModel(
      customerId: customerId,
      lat: latitude,
      long: longitude,
    );

    await repository.postLocation(locationModel);
  }

  Future<void> initservice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int customerId = prefs.getInt("id") ?? 0;
    debugPrint('Dayone primeiro plano CustomerId: $customerId');
    double latitude = latitudeValue ?? 0.0;
    double longitude = longitudeValue ?? 0.0;

    sendLocation(customerId, latitude, longitude);
  }
}
