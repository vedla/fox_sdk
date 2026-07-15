/// Platform detection and resolution utilities for Flutter apps.
library;

import 'dart:io';

import 'package:fox_sdk/src/utils/flutter_platforms.dart';

/// Resolves the current Flutter platform when running inside Flutter.
final class PlatformResolver {
  /// Creates a [PlatformResolver].
  const PlatformResolver._();

  /// The current platform.
  static FlutterPlatforms get current {
    switch (Platform.operatingSystem) {
      case 'android':
        return FlutterPlatforms.android;

      case 'ios':
        return FlutterPlatforms.ios;

      case 'macos':
        return FlutterPlatforms.macos;

      case 'windows':
        return FlutterPlatforms.windows;

      case 'linux':
        return FlutterPlatforms.linux;

      case 'web':
        return FlutterPlatforms.web;

      default:
        return FlutterPlatforms.macos;
    }
  }

  FlutterPlatforms checkIfWeb(FlutterPlatforms platform) {
    return current == FlutterPlatforms.web ? FlutterPlatforms.web : platform;
  }

  /// Whether the current platform is web.
  static bool get isWeb => current == FlutterPlatforms.web;

  /// Whether the current platform is Android.
  static bool get isAndroid => current == FlutterPlatforms.android;

  /// Whether the current platform is iOS.
  static bool get isIOS => current == FlutterPlatforms.ios;

  /// Whether the current platform is macOS.
  static bool get isMacOS => current == FlutterPlatforms.macos;

  /// Whether the current platform is Windows.
  static bool get isWindows => current == FlutterPlatforms.windows;

  /// Whether the current platform is Linux.
  static bool get isLinux => current == FlutterPlatforms.linux;

  /// Whether the current platform is Android or iOS.
  static bool get isMobile => isAndroid || isIOS;

  /// Whether the current platform is a desktop platform.
  static bool get isDesktop => isMacOS || isWindows || isLinux;

  /// Whether the current platform is macOS or iOS.
  static bool get isApple => isIOS || isMacOS;

  /// Whether the current platform is desktop or web.
  static bool get isDesktopOrWeb => isDesktop || isWeb;

  /// The current operating system name.
  static String get operatingSystem => current.name;
}

/// Checks if the current platform is a mobile platform (Android or iOS).
final bool isMobile = PlatformResolver.isMobile;

/// Checks if the current platform is iOS.
final bool isIOS = PlatformResolver.isIOS;

/// Checks if the current platform is Android.
final bool isAndroid = PlatformResolver.isAndroid;

/// Checks if the current platform is a desktop platform.
final bool isDesktop = PlatformResolver.isDesktop;

/// Checks if the current platform is macOS.
final bool isMacOS = PlatformResolver.isMacOS;

/// Checks if the current platform is Windows.
final bool isWindows = PlatformResolver.isWindows;

/// Checks if the current platform is Linux.
final bool isLinux = PlatformResolver.isLinux;

/// Checks if the current platform is the web.
final bool isWeb = PlatformResolver.isWeb;

/// Checks if the current platform is a Darwin platform (macOS or iOS).
final bool isDarwin = PlatformResolver.isMacOS || PlatformResolver.isIOS;
