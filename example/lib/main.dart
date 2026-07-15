import 'package:flutter/material.dart';

import 'package:fox_sdk/fox_logger.dart';
import 'package:fox_sdk/fox_sdk.dart';

void main() {
  AppUtils.configureLogger(
    settings: const FoxLoggerSettings(
      defaultTitle: 'Fox SDK Example',
      level: LogLevel.debug,
      enableColors: false,
    ),
  );

  AppUtils.info('Starting fox_sdk example with a custom logger config.');
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
