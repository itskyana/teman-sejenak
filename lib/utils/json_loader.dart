import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Loader generik: berikan nama file dan fungsi `fromJson`.
class JsonLoader {
  /// Contoh pakai:
  /// `JsonLoader.loadList<Destination>('destination_data.json', Destination.fromJson)`
  static Future<List<T>> loadList<T>(
    String fileName,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final String str = await rootBundle.loadString('assets/data/$fileName');
      final List<dynamic> raw = jsonDecode(str);
      return raw.map((e) => fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e, stackTrace) {
      debugPrint('JsonLoader Error loading $fileName: $e');
      debugPrint('Stack trace: $stackTrace');
      return []; // Return empty list instead of crashing
    }
  }
}
