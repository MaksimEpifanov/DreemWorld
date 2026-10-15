import 'package:flutter/material.dart';

class DreemWorldApp extends StatelessWidget {
  const DreemWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dreem World',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C4DFF)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Dreem World'),
        ),
      ),
    );
  }
}
