import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';

class AuthService {
  /// ============================
  /// USER SIGNUP

  static Future<bool> signup({
    required String email,
    required String password,
    required String name,
    required String mobileNumber,
  }) async {
    try {
      final response = await ApiClient.post(
        ApiConstants.signup,
        {
          "email": email.trim(),
          "password": password,
          "name": name.trim(),
          "mobileNumber": mobileNumber.trim(),
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// ============================
  /// USER LOGIN (EMAIL + PASSWORD)
  /// ============================
  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.post(
        ApiConstants.login,
        {
          "email": email.trim(),
          "password": password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;

        final prefs = await SharedPreferences.getInstance();

        // ✅ STORE TOKEN
        final token = data['accessToken'];
        if (token == null) {
          return false;
        }
        await prefs.setString('accessToken', token);

        // ✅ BACKEND RETURNS `developer`
        final user = data['user'] ?? data['developer'];

        if (user == null) {
          return false;
        }

        await prefs.setString('userId', user['id']);
        await prefs.setString('userEmail', user['email']);
        await prefs.setString('userName', user['name']);

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// ============================
  /// LOGIN WITH TOKEN (AUTO LOGIN)
  /// ============================
  static Future<bool> loginWithToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null || token.isEmpty) {
        return false;
      }

      final response = await ApiClient.post(
        ApiConstants.loginWithToken,
        {
          "accessToken": token,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final user = data['user'] ?? data['developer'];

        if (user != null) {
          await prefs.setString('userId', user['id']);
          await prefs.setString('userEmail', user['email']);
          await prefs.setString('userName', user['name']);
          return true;
        } else {
          print('❌ No user/developer data in auto-login response');
        }
      } else {
        print('❌ Auto-login failed with status: ${response.statusCode}');
      }

      // Token is invalid, clear it
      await prefs.remove('accessToken');
      return false;
    } catch (e) {
      return false;
    }
  }

  /// ============================
  /// VERIFY TOKEN
  /// ============================
  static Future<bool> verifyToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null || token.isEmpty) {
        return false;
      }

      final response = await ApiClient.post(
        ApiConstants.verifyToken,
        {
          "token": token,
        },
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// ============================
  /// LOGOUT USER
  /// ============================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// ============================
  /// AUTH STATE CHECK
  /// ============================
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    return token != null && token.isNotEmpty;
  }

  /// ============================
  /// GET STORED USER
  /// ============================
  static Future<Map<String, String?>> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "id": prefs.getString('userId'),
      "email": prefs.getString('userEmail'),
      "name": prefs.getString('userName'),
    };
  }

  /// ============================
  /// FORGOT PASSWORD (SEND OTP)
  /// ============================
  static Future<bool> forgotPassword(String email) async {
    try {
      final response = await ApiClient.post(
        ApiConstants.forgotPassword,
        {
          "email": email.trim(),
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// ============================
  /// RESET PASSWORD (OTP + NEW PASSWORD)
  /// ============================
  static Future<bool> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    try {
      final response = await ApiClient.post(
        ApiConstants.resetPassword,
        {
          "email": email.trim(),
          "otp": otp.trim(),
          "password": password,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
