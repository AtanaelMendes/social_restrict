import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

// class PermissionController extends GetxController implements GetxService {
//   Future<void> getPermission(Permission permsn) async {
//     var status;
//     try {
//       if (!(await permsn.isGranted)) {
//         status = await permsn.request();
//         log("___________________-----$status-----___________________1",
//             name: permsn.toString());
//       } else {
//         log("___________________-----Granted-----___________________2",
//             name: permsn.toString());
//       }
//     } on PlatformException catch (e) {
//       log("Failed to get permission: ${e.message}");
//     }
//     log("$status", name: "Permission Status");
//   }
// }

class PermissionController extends GetxController implements GetxService {
  final _semaphore = AsyncSemaphore(1);

  Future<void> requestLocationPermission() async {
    await _semaphore.acquire();
    try {
      final ph.PermissionStatus status = await ph.Permission.location.request();
      if (status.isGranted) {
      } else if (status.isDenied) {
        // Permission denied.
        print('Dayone primeiro plano Location_permission_denied');
      }
    } finally {
      _semaphore.release();
    }
  }

  Future<Map<Permission, PermissionStatus>> getPermissions(
      List<Permission> permissions) async {
    await _semaphore.acquire();
    Map<Permission, PermissionStatus> statuses = {};
    try {
      statuses = await permissions.request();
      statuses.forEach((permission, status) {
        log("Permission: $permission, Status: $status");
      });
    } on PlatformException catch (e) {
      log("Failed to get permissions: ${e.message}");
    } finally {
      _semaphore.release();
    }
    return statuses;
  }
}

class AsyncSemaphore {
  int _counter = 0;
  final List<Completer<void>> _waitQueue = [];

  AsyncSemaphore(int permits) {
    _counter = permits;
  }

  Future<void> acquire() {
    if (_counter > 0) {
      _counter--;
      return Future.value();
    } else {
      final completer = Completer<void>();
      _waitQueue.add(completer);
      return completer.future;
    }
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeAt(0);
      completer.complete();
    } else {
      _counter++;
    }
  }
}
