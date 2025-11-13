/// API endpoints and configuration constants
/// Used by: All feature services
class ApiEndpoints {
  /// 🔗 Base URL
  /// https://localguru.in/_api/news/topics_api.php
  static const String baseUrl = 'https://localguru.in/_api/';

  /// 📂 Category Base URLs
  static const String jobUrl = '${baseUrl}jobs/';
  static const String listingsUrl = '${baseUrl}listings/';
  static const String greetingUrl = '${baseUrl}greetings/';

  // ============================
  // 🔐 Authentication APIs (v1)
  // ============================

  // Legacy/misc auth endpoints (if still in use elsewhere)
  static const String phoneAuthApi = '${baseUrl}phoneAuth_api.php';
  static const String verifyUserApi = '${baseUrl}verifyUser_Api.php';
  static const String expireOtpApi = '${baseUrl}expireOtp_api.php';

  // ============================
  // 👤 User Profile APIs
  // ============================
  static const String updateProfileApi = '${baseUrl}updateProfile_api.php';

  // ============================
  // 🌍 Location APIs (v1)
  // ============================
  // Old location API - commented out, now using 3 separate APIs
  // static const String locationApi = '${baseUrl}location.php';
  // static const String locationApiV1 = '${userApiV1}location_api.php';

  // ============================
  // 💼 Jobs APIs
  // ============================
  static const String jobsApi = '${jobUrl}jobs_posts_api.php';
  static const String addNewJobApi = '${jobUrl}add_new_job.php';
  static const String searchJobsApi = '${jobUrl}job_search_api.php';
  static const String jobNewDataApi = '${jobUrl}job_new_data_api.php';

  // ============================
  // 📋 Listings APIs
  // ============================
  static const String listSearchApi = '${listingsUrl}lists_search_api.php';
  static const String listPostApi = '${listingsUrl}lists_posts_api.php';
  static const String listTopicsApi = '${listingsUrl}list_topics_api.php';

  // ============================
  // 🎉 Greetings APIs
  // ============================
  static const String greetingsApi = '${greetingUrl}greetings_api.php';
  static const String greetingsTopicsApi =
      '${greetingUrl}greetings_topics_api.php';

  // ============================
  // 📦 Requirements APIs
  // ============================
  static const String requirementsMenuApi =
      '${baseUrl}requirements_menu_api.php';
  static const String requirementsApi = '${baseUrl}requirements_api.php';
}
