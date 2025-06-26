import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screentime/android/constant.dart';
import 'package:flutter_screentime/android/method_channel_controller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

askPermissionBottomSheet(context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (Platform.isAndroid) {
      showModalBottomSheet(
        barrierColor: Colors.black.withOpacity(0.8),
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return const AskPermissionBootomSheet();
        },
      );
    } else if (Platform.isIOS) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) {
          return const IOSPermissionBottomSheet();
        },
      );
    }
  });
}


class AskPermissionBootomSheet extends StatefulWidget {
  const AskPermissionBootomSheet({Key? key}) : super(key: key);

  @override
  State<AskPermissionBootomSheet> createState() => _AskPermissionBootomSheetState();
}

class _AskPermissionBootomSheetState extends State<AskPermissionBootomSheet> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: GetBuilder<MethodChannelController>(builder: (state) {
              // Verifica se todas as permissões foram concedidas
              bool allPermissionsGranted = state.isOverlayPermissionGiven &&
                  state.isUsageStatPermissionGiven &&
                  state.isNotificationPermissionGiven &&
                  state.isBackgroundFetchAvailable;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Text(
                        allPermissionsGranted
                            ? "Sucesso! Todas as permissões foram concedidas."
                            : "Social Restrict precisa de algumas permissões para funcionar corretamente.",
                        textAlign: TextAlign.center,
                        style: MyFont().subtitle(
                          color: allPermissionsGranted ? Colors.green : Colors.white,
                          fontweight: FontWeight.w400,
                          fontsize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (!state.isOverlayPermissionGiven)
                            GestureDetector(
                              onTap: () async {
                                bool granted = await state.askOverlayPermission();
                                if (granted) {
                                  setState(() {});
                                }
                              },
                              child: permissionWidget(
                                context,
                                "Sobreposição a outros apps",
                                state.isOverlayPermissionGiven,
                              ),
                            ),
                          if (!state.isUsageStatPermissionGiven)
                            GestureDetector(
                              onTap: () async {
                                bool granted = await state.askUsageStatsPermission();
                                if (granted) {
                                  setState(() {});
                                }
                              },
                              child: permissionWidget(
                                context,
                                "Acesso ao uso",
                                state.isUsageStatPermissionGiven,
                              ),
                            ),
                          if (!state.isNotificationPermissionGiven)
                            GestureDetector(
                              onTap: () async {
                                bool granted = await state.askNotificationPermission();
                                if (granted) {
                                  setState(() {});
                                }
                              },
                              child: permissionWidget(
                                context,
                                "Enviar notificações",
                                state.isNotificationPermissionGiven,
                              ),
                            ),
                          if (!state.isBackgroundFetchAvailable)
                            GestureDetector(
                              onTap: () async {
                                await state.checkBackgroundFetchStatus();
                                setState(() {});
                              },
                              child: permissionWidget(
                                context,
                                "Atualização em segundo plano",
                                state.isBackgroundFetchAvailable,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Exibe botões diferentes dependendo do status das permissões
                    if (allPermissionsGranted)
                      MaterialButton(
                        color: Colors.green,
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Fechar",
                          style: MyFont().subtitle(
                            color: Colors.white,
                            fontweight: FontWeight.w400,
                            fontsize: 14,
                          ),
                        ),
                      )
                    else ...[
                      MaterialButton(
                        color: Colors.white,
                        onPressed: () async {
                          if (await state.checkOverlayPermission() &&
                              await state.checkUsageStatePermission() &&
                              await state.checkNotificationPermission() &&
                              state.isBackgroundFetchAvailable
                            ) {
                                Fluttertoast.showToast(msg: "Permissões concedidas");
                                setState(() {});
                                Navigator.pop(context);
                          } else {
                            Fluttertoast.showToast(msg: "Permissões negadas");
                            setState(() {});
                          }
                        },
                        child: Text(
                          "Verificar",
                          style: MyFont().subtitle(
                            color: Colors.black,
                            fontweight: FontWeight.w400,
                            fontsize: 14,
                          ),
                        ),
                      ),
                      MaterialButton(
                        color: Colors.white,
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Cancelar",
                          style: MyFont().subtitle(
                            color: Colors.black,
                            fontweight: FontWeight.w400,
                            fontsize: 14,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget permissionWidget(BuildContext context, String name, bool permission) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 6,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).primaryColor,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 6,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                name,
                style: MyFont().subtitle(
                  color: Colors.white,
                  fontweight: FontWeight.w400,
                  fontsize: 14,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.check_circle,
                color: permission ? Colors.green : Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IOSPermissionBottomSheet extends StatefulWidget {
  const IOSPermissionBottomSheet({Key? key}) : super(key: key);

  @override
  State<IOSPermissionBottomSheet> createState() => _IOSPermissionBottomSheet();
}

class _IOSPermissionBottomSheet extends State<IOSPermissionBottomSheet> {

  @override
  Widget build(BuildContext context) {
    final state = Get.find<MethodChannelController>();
    
    // Verifica se todas as permissões foram concedidas para iOS
    bool allPermissionsGranted = state.isUsageStatPermissionGiven &&
        state.isBackgroundFetchAvailable &&
        state.isBackgroundLocationPermissionGiven &&
        state.isNotificationPermissionGiven;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            allPermissionsGranted
                ? "Sucesso! Todas as permissões foram concedidas."
                : "Permissões necessárias",
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: allPermissionsGranted ? Colors.green : null,
            ),
          ),
          const SizedBox(height: 10),
          // Mostra botões de permissão apenas se nem todas estiverem concedidas
          if (!allPermissionsGranted) ...[
            if (!state.isUsageStatPermissionGiven)
              ElevatedButton.icon(
                icon: const Icon(Icons.shield),
                label: const Text("Permitir Acesso ao Uso"),
                onPressed: () async {
                  bool granted = await state.askUsageStatsPermission();
                  if (granted) {
                    setState(() {});
                  }
                },
              ),
            if (!state.isBackgroundFetchAvailable)
              ElevatedButton.icon(
                icon: const Icon(Icons.access_alarm),
                label: const Text("Permitir Atualização em Segundo Plano"),
                onPressed: () async {
                  await state.checkBackgroundFetchStatus();
                  setState(() {});
                },
              ),
            if (!state.isBackgroundLocationPermissionGiven)
              ElevatedButton.icon(
                icon: const Icon(Icons.location_on),
                label: const Text("Permitir Localização"),
                onPressed: () async {
                  bool granted = await state.askBackgroundLocationPermission();
                  if (granted) {
                    setState(() {});
                  }
                },
              ),
            if (!state.isNotificationPermissionGiven)
              ElevatedButton.icon(
                icon: const Icon(Icons.notifications),
                label: const Text("Permitir Notificações"),
                onPressed: () async {
                  bool granted = await state.askNotificationPermission();
                  if (granted) {
                    setState(() {});
                  }
                },
              ),
          ],
          const SizedBox(height: 10),
          // Mostra o botão "Fechar" apenas se todas as permissões estiverem concedidas
          if (allPermissionsGranted)
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Fechar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }
}
