import 'package:flutter/material.dart';
import 'core/jarvis_config.dart';
import 'presentation/main.dart';

void main() {
  const config = JarvisConfig();
  runApp(const JarvisApp(config: config));
}
