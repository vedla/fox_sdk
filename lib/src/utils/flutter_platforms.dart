/// Enums and utilities for Flutter platform detection in the CLI.
library;

/// Flutter platforms understood by the CLI.
enum FlutterPlatforms {
  /// The web platform.
  web,

  /// Apple desktop.
  macos,

  /// Windows desktop.
  windows,

  /// Linux desktop.
  linux,

  /// Android mobile.
  android,

  /// iOS mobile.
  ios,

  /// Fuchsia.
  fuchsia,

  /// A desktop platform resolved from the host OS.
  desktop,
}
