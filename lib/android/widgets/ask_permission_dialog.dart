import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screentime/android/constant.dart';
import 'package:flutter_screentime/android/method_channel_controller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';

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
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Text(
                        "Social Restrict precisa de algumas permissões para funcionar corretamente.",
                        textAlign: TextAlign.center,
                        style: MyFont().subtitle(
                          color: Colors.white,
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
                              onTap: () {
                                state.askOverlayPermission();
                                setState(() {}); // Atualiza a UI
                              },
                              child: permissionWidget(
                                context,
                                "Sobreposição a outros apps",
                                state.isOverlayPermissionGiven,
                              ),
                            ),
                          if (!state.isUsageStatPermissionGiven)
                            GestureDetector(
                              onTap: () {
                                state.askUsageStatsPermission();
                                setState(() {}); // Atualiza a UI
                              },
                              child: permissionWidget(
                                context,
                                "Acesso ao uso",
                                state.isUsageStatPermissionGiven,
                              ),
                            ),
                          if (!state.isNotificationPermissionGiven)
                            GestureDetector(
                              onTap: () {
                                state.askNotificationPermission();
                                setState(() {}); // Atualiza a UI
                              },
                              child: permissionWidget(
                                context,
                                "Enviar notificações",
                                state.isNotificationPermissionGiven,
                              ),
                            ),
                          if (!state.isBackgroundFetchAvailable)
                            GestureDetector(
                              onTap: () {
                                state.checkBackgroundFetchStatus();
                                setState(() {}); // Atualiza a UI
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
                    MaterialButton(
                      color: Colors.white,
                      onPressed: () async {
                        if (await state.checkOverlayPermission() &&
                            await state.checkUsageStatePermission() &&
                            await state.checkNotificationPermission() &&
                            state.isBackgroundFetchAvailable) {
                          Fluttertoast.showToast(msg: "Permissões concedidas");
                          Navigator.pop(context);
                        } else {
                          Fluttertoast.showToast(msg: "Permissões negadas");
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
                    )
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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Permissões necessárias",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (!state.isUsageStatPermissionGiven)
            ElevatedButton.icon(
              icon: const Icon(Icons.shield),
              label: const Text("Permitir Acesso ao Uso"),
              onPressed: () {
                state.askUsageStatsPermission();
                setState(() {});
              },
            ),
          if (!state.isBackgroundFetchAvailable)
            ElevatedButton.icon(
              icon: const Icon(Icons.access_alarm),
              label: const Text("Permitir Atualização em Segundo Plano"),
              onPressed: () {
                state.checkBackgroundFetchStatus();
                setState(() {});
              },
            ),
          if (!state.isBackgroundLocationPermissionGiven)
            ElevatedButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text("Permitir Localização"),
              onPressed: () {
                state.askBackgroundLocationPermission();
                setState(() {});
              },
            ),
          if (!state.isNotificationPermissionGiven)
            ElevatedButton.icon(
              icon: const Icon(Icons.notifications),
              label: const Text("Permitir Notificações"),
              onPressed: () {
                state.askNotificationPermission();
                setState(() {});
              },
            ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.close),
            label: const Text("Fechar"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
