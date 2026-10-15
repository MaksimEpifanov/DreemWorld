import 'package:flutter/material.dart';

import '../../core/theme/index.dart';

class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dreem World')),
      body: SafeArea(
        child: Center(
          child: Text(
            'Главный экран (Discover)',
            style: AppTextStyles.title(),
          ),
        ),
      ),
    );
  }
}
