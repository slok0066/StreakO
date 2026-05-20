import 'package:flutter/material.dart';
import 'app.dart';

void main() async {
  // Ensure Flutter engine bindings are fully initialized before running tasks
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app shell
  runApp(const StreakoApp());
}
