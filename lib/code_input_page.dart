// Crie um novo arquivo: lib/painel/code_input_page.dart
import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screentime/modules/home/apps_controller.dart';
// import 'package:flutter_screentime/home_page.dart';
import 'package:flutter_screentime/navigation_service.dart';
import 'package:flutter_screentime/android/method_channel_controller.dart';
import 'package:flutter_screentime/background_notification.dart';
import 'package:flutter_screentime/models/token_id_model.dart';
import 'package:flutter_screentime/modules/qr-code/qr_repository.dart';
import 'package:flutter_screentime/main.dart';
import 'package:get/get.dart';

class CodeInputPage extends StatefulWidget {
  const CodeInputPage({Key? key}) : super(key: key);

  @override
  State<CodeInputPage> createState() => _CodeInputPageState();
}

class _CodeInputPageState extends State<CodeInputPage> {
  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int? id;
  int? companyId;
  String? tokenId = NavigationService.prefs?.getString("token");
  final QrRepository qrRepository = QrRepository();

  Future<void> _handleCodeSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Decodifica a hash base64
      final decodedBytes = base64Decode(_codeController.text.trim());
      final decodedString = utf8.decode(decodedBytes);
      
      // Extrai customer_id:company_id
      final parts = decodedString.split(':');
      if (parts.length != 2) {
        throw Exception('Formato inválido');
      }

      final customerId = int.parse(parts[0]);
      final companyId = int.parse(parts[1]);

      // Chama o fluxo completo do QR Code
      await _handleActivationData(customerId, companyId, _codeController.text.trim());
      
    } catch (e) {
      _showErrorDialog('Código inválido. Verifique o formato.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleActivationData(int customerId, int companyId, String originalCode) async {
    try {
      id = customerId;
      this.companyId = companyId;
      
      if (Platform.isIOS) {
        await Get.find<MethodChannelController>().setTokenFirebase();
      }
      tokenId = NavigationService.prefs?.getString("token");

      TokenIdModel token = TokenIdModel(
        customerId: id,
        deviceId: tokenId,
        status: 1,
      );

      log("SocialRestrict id: $id");
      log("SocialRestrict companyId: $companyId");
      log("SocialRestrict tokenId: $tokenId");

      bool confirmSendToken = await qrRepository.tokenId(token);

      if (confirmSendToken) {
        Get.snackbar(
          'Sucesso',
          'Código ativado com sucesso.',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Salva os dados no NavigationService (mesmo fluxo do QR Code original)
        NavigationService.prefs?.setString("settings", originalCode);
        NavigationService.prefs?.setInt("id", id!);
        NavigationService.prefs?.setInt("companyId", companyId);
        Get.find<AppsController>().savePasscode("927594");

        if (Platform.isAndroid) {
          Get.find<MethodChannelController>().sendValuesToNative(id, companyId, tokenId);
          await Get.find<MethodChannelController>().startForeground();
        }

        if (Platform.isIOS) {
          NotificationHandler.initialize();
          await Get.find<MethodChannelController>().startBackgroundTask();
        }

        // Libera o loading antes da navegação
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        // Aguarda um frame para garantir atualização da UI antes de navegar
        await Future.delayed(const Duration(milliseconds: 300));

        Get.offAll(() => const MyHomePage());
        
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
        
        _showErrorDialog('Erro ao ativar o código. Tente novamente.');
      }
      
    } catch (e) {
      log('Erro ao processar ativação: $e');
      _showErrorDialog('Erro ao processar o código: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inserir Código'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Digite o código de ativação',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Código de Ativação',
                        hintText: 'Cole o código aqui',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.vpn_key),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira o código';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleCodeSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              )
                            : const Text(
                                'Ativar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}