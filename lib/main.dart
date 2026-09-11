import 'dart:io';
import 'package:flutter/material.dart';
import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final isDemo = Platform.environment['CODENOTCH_DEMO'] == '1';

  runApp(CodenotchApp(isDemo: isDemo));
}
