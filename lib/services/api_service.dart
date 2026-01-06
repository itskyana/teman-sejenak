import 'dart:convert';
import 'package:teman_sejenak/models/destination.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1/teman-sejenak/api";

  // REGISTER USER
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String placeOfBirth,
    required String dateOfBirth,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "full_name": fullName,
        "place_of_birth": placeOfBirth,
        "date_of_birth": dateOfBirth,
        "email": email,
        "password": password,
      }),
    );

    return jsonDecode(response.body);
  }

  // LOGIN USER
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  // GET USER PROFILE
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final url = Uri.parse("$baseUrl/user/profile");
    final response = await http.get(
      url,
      headers: {"Authorization": token, "Content-Type": "application/json"},
    );
    return jsonDecode(response.body);
  }

  // GET DESTINATIONS
  static Future<List<Destination>> getDestinations() async {
    final url = Uri.parse("$baseUrl/destination");

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    final body = jsonDecode(response.body);

    if (body["status"] != 200) {
      throw Exception(body["message"]);
    }

    return (body["data"] as List).map((e) => Destination.fromJson(e)).toList();
  }
}
