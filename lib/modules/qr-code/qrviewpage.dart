import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screentime/android/method_channel_controller.dart';
import 'package:flutter_screentime/background_notification.dart';
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
    if (Platform.isAndroid) {
      _checkLocationPermission();
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug QRViewPage'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Simula leitura QRCode sem criar um QRViewController fake
            final dummyScanData = Barcode('{"id":81,"companyId":33}', BarcodeFormat.qrcode, []);
            _onQRViewCreatedForDebug(dummyScanData);
          },
          child: const Text('Simular leitura QRCode'),
        ),
      ),
    );
    // currentContext = context;
    // return Scaffold(
    //   body: isLoading
    //       ? const Center(
    //           child: CircularProgressIndicator(),
    //         )
    //       : Column(
    //           children: <Widget>[
    //             Expanded(flex: 4, child: _buildQrView(context)),
    //           ],
    //         ),
    // );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea =
        (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 150.0 : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red, borderRadius: 10, borderLength: 30, borderWidth: 10, cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    bool valuesSent = false;

    controller.scannedDataStream.listen((scanData) async {
      if (valuesSent) return;
      valuesSent = true;

      await _handleScanData(scanData, controller);
    });
  }

  // Função auxiliar para simular leitura QRCode no modo debug
  Future<void> _onQRViewCreatedForDebug(Barcode scanData) async {
    await _handleScanData(scanData, null);
  }

  Future<void> _handleScanData(Barcode scanData, QRViewController? controller) async {
    // result = scanData;
    // Map<String, dynamic> data = jsonDecode(scanData.code!);
    // debugPrint(data.toString());
    // debugPrint("id: ${data['id'].toString()}");
    // debugPrint("companyId: ${data['companyId'].toString()}");

    // id = data['id'] ?? 0;
    // companyId = data['companyId'] ?? 0;
    
    id = 81;
    companyId = 33;

    TokenIdModel token = TokenIdModel(
      customerId: id,
      deviceId: tokenId,
      status: 1,
    );

    log("SocialRestrict id: $id");
    log("SocialRestrict companyId: $companyId");
    log("SocialRestrict tokenId: $tokenId");

    // bool confirmSendToken = await qrRepository.tokenId(token);
    bool confirmSendToken = true; // Simulando sucesso no envio do token

    controller?.dispose();

    if (confirmSendToken) {
      Get.snackbar(
        'Sucesso',
        'Token enviado.',
        snackPosition: SnackPosition.BOTTOM,
      );
      NavigationService.prefs?.setString("settings", scanData.code!);
      NavigationService.prefs?.setInt("id", id!);
      NavigationService.prefs?.setInt("companyId", companyId!);
        Get.find<AppsController>().savePasscode("927594");
        // NavigationService.prefs?.setString("token", tokenId!);
      if (Platform.isAndroid) {
        Get.find<MethodChannelController>().sendValuesToNative(id, companyId, tokenId);
        await Get.find<MethodChannelController>().startForeground();
      }
      if (Platform.isIOS) {
        NotificationHandler.initialize();
        await Get.find<MethodChannelController>().startBackgroundTask();
      }
    } else {
      Get.snackbar(
        'Erro',
        'Erro ao enviar token.',
        snackPosition: SnackPosition.BOTTOM,
      );
      NavigationService.prefs?.setInt("companyId", 0);
      NavigationService.prefs?.setInt("id", 0);
      NavigationService.prefs?.setString("settings", "");
      Get.find<MethodChannelController>().update();
    }

    // Libera o loading antes da navegação
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }

    // Aguarda um frame para garantir atualização da UI antes de navegar
    await Future.delayed(const Duration(milliseconds: 300));

    Get.offAll(() => const MyHomePage());
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
      log("Permissões de localização concedidas");
    } else {
      log("Permissões de localização não concedidas");
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

