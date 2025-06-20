import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();
  static Env? _instance;
  static Env get instance {
    _instance ??= Env._();
    return _instance!;
  }

  Future<void> load() => dotenv.load();

  String? operator [](String key) => dotenv.env[key];
}
