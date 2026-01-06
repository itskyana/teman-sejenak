/// Base model class with common functionality
abstract class BaseModel {
  /// Convert model to JSON map
  Map<String, dynamic> toJson();
  
  @override
  String toString() => toJson().toString();
}
