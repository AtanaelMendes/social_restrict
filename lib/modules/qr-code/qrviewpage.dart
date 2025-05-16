import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screentime/background_main.dart';
import 'package:flutter_screentime/models/token_id_model.dart';
import 'package:flutter_screentime/modules/home/apps_controller.dart';
import 'package:flutter_screentime/modules/home/apps_repository.dart';
import 'package:flutter_screentime/provider/api.dart';
import 'package:flutter_screentime/navigation_service.dart';
import 'package:flutter_screentime/modules/qr-code/qr_repository.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

const platform = MethodChannel('samples.flutter.dev/native');

class QRViewPage extends StatefulWidget {
  const QRViewPage({super.key});

  @override
  State<StatefulWidget> createState() => _QRViewPageState();
}

class _QRViewPageState extends State<QRViewPage> {
  Barcode? result;
  BuildContext? currentContext;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  int? id;
  int? companyId;
  String? tokenId = NavigationService.prefs?.getString("token");
  final QrRepository qrRepository = QrRepository();
  bool isLoading = false;
  // final appController = Get.put(AppsController(Get.find(), AppsRepository(Api())));

  @override
  void initState() {
    initialize();
    super.initState();
    // appController.getCurrentLocation();
    _checkCameraPermission();
    _checkLocationPermission();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    currentContext = context;
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: <Widget>[
                Expanded(flex: 4, child: _buildQrView(context)),
              ],
            ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 150.0 : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(borderColor: Colors.red, borderRadius: 10, borderLength: 30, borderWidth: 10, cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    bool valuesSent = false;

    controller.scannedDataStream.listen(
      (scanData) async {
        setState(() {
          isLoading = true;
        });
        setState(() {
          result = scanData;
          Map<String, dynamic> data = jsonDecode(scanData.code!);
          if (kDebugMode) {
            print(data);
          }
          NavigationService.prefs?.setString("settings", scanData.code!);
          NavigationService.prefs?.setInt("id", data['id'] ?? 0);
          if (kDebugMode) {
            print(data['id']);
          }
          NavigationService.prefs?.setInt("companyId", data['companyId'] ?? 0);
          if (kDebugMode) {
            print(data['companyId']);
          }

          id = data['id'] ?? 0;
          companyId = data['companyId'] ?? 0;
        });

        if (!valuesSent) {
          valuesSent = true;

          setState(() {
            isLoading = true;
          });

          TokenIdModel token = TokenIdModel(
            customerId: id,
            deviceId: tokenId,
            status: 1,
          );

          sendValuesToNative();
          bool confirmSendToken = await qrRepository.tokenId(token);

          controller.dispose();

          if (confirmSendToken) {
            Get.snackbar(
              'Sucesso',
              'Token enviado.',
              snackPosition: SnackPosition.BOTTOM,
            );
          } else {
            Get.snackbar(
              'Erro',
              'Erro ao enviar token.',
              snackPosition: SnackPosition.BOTTOM,
            );
            setState(() {
              NavigationService.prefs?.setInt("companyId", 0);
              NavigationService.prefs?.setInt("id", 0);
              NavigationService.prefs?.setString("settings", "");
            });
          }

          setState(() {
            isLoading = false;
          });

          Future.delayed(
            const Duration(seconds: 2),
            () {
              Get.offAll(
                () => const BackgroundMainPage(title: "Social Restrict"),
              );
            },
          );
        }
      },
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  void _checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      Permission.camera.request();
    }
  }

  void _checkLocationPermission() async {
    var statusFine = await Permission.location.request();
    var statusCoarse = await Permission.locationAlways.request();

    if (statusFine.isGranted && statusCoarse.isGranted) {
      print("Permissões de localização concedidas");
    } else {
      print("Permissões de localização não concedidas");
    }
  }

  void initialize() async {
    if (Permission.camera.status == PermissionStatus.denied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.camera,
      ].request();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

void sendValuesToNative() async {
  const platform = MethodChannel('samples.flutter.dev/native');
  try {
    final int? id = NavigationService.prefs?.getInt("id");
    final int? companyId = NavigationService.prefs?.getInt("companyId");
    final String? tokenId = NavigationService.prefs?.getString("token");

    final Map<String, dynamic> values = {
      'id': id,
      'companyId': companyId,
      'tokenId': tokenId,
    };

    final String result = await platform.invokeMethod('sendValues', values);
    debugPrint('Dayone FLUTTER Received: $result');
    debugPrint('Dayone FLUTTER Values para o nativo*******: $values');
  } on PlatformException catch (e) {
    debugPrint("Dayone FLUTTER Failed to send values: '${e.message}'.");
  }
}
