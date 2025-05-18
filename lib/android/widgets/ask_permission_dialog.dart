import 'package:flutter/material.dart';
import 'package:flutter_screentime/android/constant.dart';
import 'package:flutter_screentime/android/method_channel_controller.dart';
import 'package:flutter_screentime/data/modules/home/apps_controller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';

askPermissionBottomSheet(context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
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
                        "AppLock needs system permissions to work with.",
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
                                "System overlay",
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
                                "Usage access",
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
                                "Push notification",
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
                                "Background fetch",
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
                          Navigator.pop(context);
                        } else {
                          Fluttertoast.showToast(msg: "Required permissions not given !");
                        }
                      },
                      child: Text(
                        "Confirm",
                        style: MyFont().subtitle(
                          color: Colors.black,
                          fontweight: FontWeight.w400,
                          fontsize: 14,
                        ),
                      ),
                    ),
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
                "$name",
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
