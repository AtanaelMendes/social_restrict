import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

void main() => runApp(MyApp());

const simpleTaskKey = "simpleTask";
const rescheduledTaskKey = "rescheduledTask";
const failedTaskKey = "failedTask";
const simpleDelayedTask = "simpleDelayedTask";
const simplePeriodicTask = "simplePeriodicTask";
const simplePeriodic1HourTask = "simplePeriodic1HourTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case simpleTaskKey:
        print("SocialRestrict: $simpleTaskKey was executed. inputData = $inputData");
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("test", true);
        print("SocialRestrict: Bool from prefs: ${prefs.getBool("test")}");
        break;
      case rescheduledTaskKey:
        final key = inputData!['key']!;
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('unique-$key')) {
          print('SocialRestrict: has been running before, task is successful');
          return true;
        } else {
          await prefs.setBool('unique-$key', true);
          print('SocialRestrict: reschedule task');
          return false;
        }
      case failedTaskKey:
        print('SocialRestrict: failed task');
        return Future.error('failed');
      case simpleDelayedTask:
        print("SocialRestrict: $simpleDelayedTask was executed");
        break;
      case simplePeriodicTask:
        print("SocialRestrict: $simplePeriodicTask was executed");
        break;
      case simplePeriodic1HourTask:
        print("SocialRestrict: $simplePeriodic1HourTask was executed");
        break;
      case Workmanager.iOSBackgroundTask:
        print("SocialRestrict: The iOS background fetch was triggered");
        Directory? tempDir = await getTemporaryDirectory();
        String? tempPath = tempDir.path;
        print(
            "You can access other plugins in the background, for example Directory.getTemporaryDirectory(): $tempPath");
        break;
    }

    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum _Platform { android, ios }

class PlatformEnabledButton extends StatelessWidget {
  final _Platform platform;
  final Widget child;
  final VoidCallback onPressed;

  PlatformEnabledButton({
    required this.platform,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = (Platform.isAndroid && platform == _Platform.android) ||
        (Platform.isIOS && platform == _Platform.ios);

    return ElevatedButton(
      child: child,
      onPressed: isEnabled ? onPressed : null,
    );
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter WorkManager Example"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text("Plugin initialization",
                  style: Theme.of(context).textTheme.titleLarge),
              ElevatedButton(
                child: Text("Start the Flutter background service"),
                onPressed: () {
                  Workmanager().initialize(
                    callbackDispatcher,
                    isInDebugMode: true,
                  );
                },
              ),
              SizedBox(height: 16),
              Text("One Off Tasks (Android only)",
                  style: Theme.of(context).textTheme.titleLarge),
              PlatformEnabledButton(
                platform: _Platform.android,
                child: Text("Register OneOff Task"),
                onPressed: () {
                  Workmanager().registerOneOffTask(
                    "1",
                    simpleTaskKey,
                    inputData: <String, dynamic>{
                      'int': 1,
                      'bool': true,
                      'double': 1.0,
                      'string': 'string',
                      'array': [1, 2, 3],
                    },
                  );
                },
              ),
              PlatformEnabledButton(
                platform: _Platform.android,
                child: Text("Register rescheduled Task"),
                onPressed: () {
                  Workmanager().registerOneOffTask(
                    "1-rescheduled",
                    rescheduledTaskKey,
                    inputData: <String, dynamic>{
                      'key': Random().nextInt(64000),
                    },
                  );
                },
              ),
              PlatformEnabledButton(
                platform: _Platform.android,
                child: Text("Register failed Task"),
                onPressed: () {
                  Workmanager().registerOneOffTask(
                    "1-failed",
                    failedTaskKey,
                  );
                },
              ),
              PlatformEnabledButton(
                platform: _Platform.android,
                child: Text("Register Delayed OneOff Task"),
                onPressed: () {
                  Workmanager().registerOneOffTask(
                    "2",
                    simpleDelayedTask,
                    initialDelay: Duration(seconds: 10),
                  );
                },
              ),
              SizedBox(height: 8),
              Text("Periodic Tasks (Android only)",
                  style: Theme.of(context).textTheme.titleLarge),
              PlatformEnabledButton(
                platform: _Platform.android,
                child: Text("Register Periodic Task"),
                onPressed: () {
                  Workmanager().registerPeriodicTask(
                    "3",
                    simplePeriodicTask,
                    initialDelay: Duration(seconds: 10),
                  );
                },
              ),
              PlatformEnabledButton(
                platform: _Platform.android,
                child: Text("Register 1 hour Periodic Task"),
                onPressed: () {
                  Workmanager().registerPeriodicTask(
                    "5",
                    simplePeriodic1HourTask,
                    frequency: Duration(hours: 1),
                  );
                },
              ),
              PlatformEnabledButton(
                platform: _Platform.android,
                child: Text("Cancel All"),
                onPressed: () async {
                  await Workmanager().cancelAll();
                  print('SocialRestrict: Cancel all tasks completed');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
