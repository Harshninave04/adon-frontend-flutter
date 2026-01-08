// class ApiConstants {
//   static const String devBaseUrl = 'https://api.dev.adonservice.in';
//   static const String prodBaseUrl = 'https://api.adonservice.in';

//   static const String baseUrl = devBaseUrl;

//   // Auth
//   static const String signup = '/api/auth/signup';
//   static const String login = '/api/auth/login';
// }

class ApiConstants {
  static const String baseUrl = 'https://api.dev.adonservice.in';

  static const String signup = '/api/auth/signup';
  static const String login = '/api/auth/login';
  static const String loginWithToken = '/api/auth/login-with-token';
  static const String verifyToken = '/api/auth/verify-token';

  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';

  static const String profile = '/api/profile';
}
