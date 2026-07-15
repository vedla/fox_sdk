import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/painting.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import 'package:path/path.dart' as p;
// import 'package:fox_sdk/fox_sdk.dart' show AppUtils;

abstract class AssetProvider {
  /// Fetches an asset as bytes.
  Future<Uint8List> loadAssetBytes(String path);

  /// Fetches an asset as a string (e.g., text, json).
  Future<String> loadAssetString(String path);

  /// Resolves an asset path to an absolute file path or URI (if applicable).
  String resolvePath(String path);

  /// Returns a Flutter ImageProvider for the given asset path.
  ImageProvider getImageProvider(String path);
}

class BundledAssetProvider implements AssetProvider {
  BundledAssetProvider({this.assetBase = 'assets'});

  final String assetBase;

  @override
  Future<Uint8List> loadAssetBytes(String path) async {
    final byteData = await rootBundle.load(resolvePath(path));
    return byteData.buffer.asUint8List();
  }

  @override
  Future<String> loadAssetString(String path) async {
    return rootBundle.loadString(resolvePath(path));
  }

  @override
  String resolvePath(String path) {
    if (path.startsWith('assets/')) return path;
    return p.normalize('$assetBase/$path');
  }

  @override
  ImageProvider getImageProvider(String path) {
    return AssetImage(resolvePath(path));
  }
}

class LocalAssetProvider implements AssetProvider {
  LocalAssetProvider({required this.assetBase});
  final String assetBase;

  @override
  Future<Uint8List> loadAssetBytes(String path) async {
    // AppUtils.debug('Loading asset: ${resolvePath(path)}');
    final file = File(resolvePath(path));
    return file.readAsBytes();
  }

  @override
  Future<String> loadAssetString(String path) async {
    // AppUtils.debug('Loading asset: ${resolvePath(path)}');
    final file = File(resolvePath(path));
    return file.readAsString();
  }

  @override
  String resolvePath(String path) {
    if (p.isAbsolute(path)) return p.normalize(path);
    return p.normalize('$assetBase/$path');
  }

  @override
  ImageProvider getImageProvider(String path) {
    // AppUtils.debug('Loading image: ${resolvePath(path)}');
    return FileImage(File(resolvePath(path)));
  }
}

class RemoteAssetProvider implements AssetProvider {
  RemoteAssetProvider({required this.baseUrl});
  final Uri baseUrl;

  @override
  Future<Uint8List> loadAssetBytes(String path) async {
    final response = await http.get(Uri.parse(resolvePath(path)));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception('Failed to load asset $path: ${response.statusCode}');
  }

  @override
  Future<String> loadAssetString(String path) async {
    final response = await http.get(Uri.parse(resolvePath(path)));
    if (response.statusCode == 200) {
      return response.body;
    }
    throw Exception(
      'Failed to load asset string $path: ${response.statusCode}',
    );
  }

  @override
  String resolvePath(String path) {
    // Ensure path doesn't start with a slash so it concatenates properly
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return baseUrl.resolve(cleanPath).toString();
  }

  @override
  ImageProvider getImageProvider(String path) {
    return NetworkImage(resolvePath(path));
  }
}
