import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from local .env asset
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Notice: .env file not found or failed to load ($e). Using default environment fallback.');
  }

  runApp(const FikirSignApp());
}
