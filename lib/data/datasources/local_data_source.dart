import 'dart:convert';
import 'package:flutter/services.dart';

/// Local data source for loading JSON files from assets
/// 
/// This class handles all local JSON data operations.
/// When migrating to API, you only need to create a RemoteDataSource
/// that implements the same interface.
class LocalDataSource {
  LocalDataSource._();
  static final LocalDataSource instance = LocalDataSource._();

  /// Load and parse a list from JSON file
  /// 
  /// Example:
  /// ```dart
  /// final destinations = await LocalDataSource.instance.loadList<Destination>(
  ///   'assets/data/destination_data.json',
  ///   Destination.fromJson,
  /// );
  /// ```
  Future<List<T>> loadList<T>(
    String assetPath,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((item) => fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      throw DataSourceException('Failed to load $assetPath: $e');
    }
  }

  /// Load and parse a single object from JSON file
  Future<T> loadSingle<T>(
    String assetPath,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return fromJson(jsonMap);
    } catch (e) {
      throw DataSourceException('Failed to load $assetPath: $e');
    }
  }

  /// Load raw JSON as Map
  Future<Map<String, dynamic>> loadRawJson(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      return jsonDecode(jsonString);
    } catch (e) {
      throw DataSourceException('Failed to load $assetPath: $e');
    }
  }
}

/// Exception for data source errors
class DataSourceException implements Exception {
  final String message;
  DataSourceException(this.message);

  @override
  String toString() => 'DataSourceException: $message';
}
