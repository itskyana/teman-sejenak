class Guide {
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
    required this.description,
  });

  factory Guide.fromJson(Map<String, dynamic> j) => Guide(
        name: j['name'],
        gender: j['gender'],
        age: j['age'],
        location: j['location'],
        languages: List<String>.from(j['languages']),
        available: List<String>.from(j['available']),
        interests: List<String>.from(j['interests']),
        imageUrl: j['imageUrl'],
        verified: j['verified'],
        rating: (j['rating'] as num).toDouble(),
        description: j['description'] as String?,
        ordersHandled: j['ordersHandled'] ?? 0,
        gallery: j['gallery'] != null
            ? List<String>.from(j['gallery'])
            : <String>[],
      );
}
