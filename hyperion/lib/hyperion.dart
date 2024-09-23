import 'package:flutter/material.dart';
import 'package:hyperion/pages/root.dart';

class Hyperion extends StatelessWidget {
  const Hyperion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hyperion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Root(),
    );
  }
}
