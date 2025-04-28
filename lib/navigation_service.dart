import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationService {
  static SharedPreferences? prefs;
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static MethodChannel methodChannel =
      const MethodChannel('social_restrict');
}
