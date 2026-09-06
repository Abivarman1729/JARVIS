import 'package:flutter/material.dart';
import '../core/jarvis_config.dart';

class JarvisApp extends StatelessWidget {
  const JarvisApp({super.key, required this.config});
  final JarvisConfig config;
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'JARVIS',
        theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
        home: const JarvisHomePage(),
      );
}

class JarvisHomePage extends StatelessWidget {
  const JarvisHomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('JARVIS')),
        body: const Center(child: Text('Voice-first JARVIS core is ready.')),
      );
}
