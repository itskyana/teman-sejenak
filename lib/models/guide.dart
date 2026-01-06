class Guide {
  final int id;
  final String name;
  final String gender;
  final int age;
  final String location;
  final List<String> languages;
  final List<String> available;
  final List<String> interests;
  final String imageUrl;
  final bool verified;
  final double rating;
  final int ordersHandled;           
  final List<String> gallery;        
  final String? description; 

  Guide({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.location,
    required this.languages,
    required this.available,
    required this.interests,
    required this.imageUrl,
    required this.verified,
    required this.rating,
    required this.ordersHandled,
    required this.gallery,
    this.description,
  });

  factory Guide.fromJson(Map<String, dynamic> j) {
    // Parse id - support both int and string
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }
    
    return Guide(
      id: parseId(j['id']),
      name: j['name'] ?? '',
      gender: j['gender'] ?? '',
      age: j['age'] is int ? j['age'] : int.tryParse(j['age']?.toString() ?? '0') ?? 0,
      location: j['location'] ?? '',
      languages: j['languages'] != null ? List<String>.from(j['languages']) : <String>[],
      available: j['available'] != null ? List<String>.from(j['available']) : <String>[],
      interests: j['interests'] != null ? List<String>.from(j['interests']) : <String>[],
      imageUrl: j['imageUrl'] ?? j['image_url'] ?? '',
      verified: j['verified'] ?? false,
      rating: j['rating'] != null ? (j['rating'] as num).toDouble() : 0.0,
      description: j['description'] as String?,
      ordersHandled: j['ordersHandled'] ?? j['orders_handled'] ?? 0,
      gallery: j['gallery'] != null ? List<String>.from(j['gallery']) : <String>[],
    );
  }
}
