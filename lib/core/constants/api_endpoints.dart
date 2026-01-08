import 'api_config.dart';

class ApiEndpoints {
  // URL de base pour les endpoints d'authentification et de comptes
  static String get baseUrl => "${ApiConfig.apiBaseUrl}/accounts/";
  
  // Auth
  static String get login => "${baseUrl}login/";
  static String get refreshToken => "${baseUrl}refresh/";
  static String get logout => "${baseUrl}logout/";

  // Users
  static String get users => "${baseUrl}users/";
  static String get usersByType => "${baseUrl}users/type/";
  static String userDetail(int userId) => "${baseUrl}users/profile/$userId/";
  
  // Registration
  static String get register => "${baseUrl}register/";
  static String get registerStudent => "${baseUrl}register/student/";
  static String get registerPupil => "${baseUrl}register/pupil/"; 
  static String get registerTeacher => "${baseUrl}register/teacher/";
  static String get registerAdvisor => "${baseUrl}register/advisor/";
  
  // Profile
  static String get userProfile => "${baseUrl}profile/";
  static String get changePassword => "${baseUrl}profile/password/";
  static String get uploadProfilePicture => "${baseUrl}profile/picture/";
  
  // Specific profiles
  static String get studentProfile => "${baseUrl}profile/student/";
  static String get teacherProfile => "${baseUrl}profile/teacher/";
  static String get advisorProfile => "${baseUrl}profile/advisor/";
  
  // Verification
  static String get requestVerification => "${baseUrl}verification/request/";
  static String get verificationStatus => "${baseUrl}verification/status/";
  
  // Password Reset
  static String get passwordResetRequest => "${baseUrl}password/reset/";

  // Notification
  static String get notifications => "${baseUrl}notifications/";
}