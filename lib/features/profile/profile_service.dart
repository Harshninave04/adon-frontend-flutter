import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';

class ProfileService {
  // 1. Get Profile Details (Fetch by ID)
  static Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) return null;

      // GET /api/profile/:id
      final response = await ApiClient.get(
        '${ApiConstants.profile}/$userId',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print("Error fetching profile: $e");
      return null;
    }
  }

  // 2. Update Profile (Pending)
  static Future<bool> updateProfile(Map<String, dynamic> updateData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) return false;

      // PUT /api/profile/:id
      final response = await ApiClient.put(
        '${ApiConstants.profile}/$userId',
        updateData,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
