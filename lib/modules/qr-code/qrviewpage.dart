import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screentime/main.dart';
import 'package:flutter_screentime/models/token_id_model.dart';
import 'package:flutter_screentime/modules/home/apps_controller.dart';
import 'package:flutter_screentime/modules/home/apps_repository.dart';
import 'package:flutter_screentime/navigation_service.dart';
import 'package:flutter_screentime/modules/qr-code/qr_repository.dart';
import 'package:flutter_screentime/provider/api.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

const platform = MethodChannel('flutter.native/helper');

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
  final appController = Get.put(AppsController(Get.find(), AppsRepository(Api())));

  @override
  void initState() {
    initialize();
    super.initState();
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

    controller.scannedDataStream.listen((scanData) async {
        setState(() {
          isLoading = true;
        });
        result = scanData;
        Map<String, dynamic> data = jsonDecode(scanData.code!);
        setState(() {
          debugPrint(data.toString());
          debugPrint("id: ${data['id'].toString()}");
          debugPrint("companyId: ${data['companyId'].toString()}");
          id = data['id'] ?? 0;
          companyId = data['companyId'] ?? 0;
        });

        // appController.getCurrentLocation();

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

          bool confirmSendToken = await qrRepository.tokenId(token);

          controller.dispose();

          if (confirmSendToken) {
            Get.snackbar(
              'Sucesso',
              'Token enviado.',
              snackPosition: SnackPosition.BOTTOM,
            );
            NavigationService.prefs?.setString("settings", scanData.code!);
            NavigationService.prefs?.setInt("id", id!);
            NavigationService.prefs?.setInt("companyId", companyId!);
            sendValuesToNative(id, companyId, tokenId);

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
                () => const MyHomePage(),
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

void sendValuesToNative(id, companyId, tokenId) async {
  try {
    final int? id = NavigationService.prefs?.getInt("id");
    final int? companyId = NavigationService.prefs?.getInt("companyId");
    final String? tokenId = NavigationService.prefs?.getString("token");

    final Map<String, dynamic> values = {
      'id': id,
      'companyId': companyId,
      'tokenId': tokenId,
    };
    debugPrint('ENVIANDO VALORES PARA O NATIVO: $values');
    final String result = await platform.invokeMethod('sendValues', values);
    debugPrint('Valores enviados com sucesso: $result');
  } on PlatformException catch (e) {
    debugPrint("FALHA ao enviar valores para o nativo: '${e.message}'.");
  }
}
