import 'package:flutter/material.dart';

import 'package:fox_sdk/fox_sdk.dart';

void main() {
  runApp(const FoxSdkExampleApp());
}

class FoxSdkExampleApp extends StatelessWidget {
  const FoxSdkExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('fox_sdk example')),
        body: Center(
          child: Text(
            'Current platform: ${PlatformResolver.current.name}',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
