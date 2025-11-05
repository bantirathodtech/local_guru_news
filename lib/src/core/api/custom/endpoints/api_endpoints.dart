/// API endpoints and configuration constants
/// Used by: All feature services
class ApiEndpoints {
  /// 🔗 Base URL
  static const String baseUrl = 'https://localguru.in/_api/';

  /// 🔗 Base URL v1
  static const String baseUrl2 = 'https://localguru.in/_api_v1/';

  /// 📂 Category Base URLs
  static const String newsUrl = '${baseUrl}news/';
  static const String jobUrl = '${baseUrl}jobs/';
  static const String listingsUrl = '${baseUrl}listings/';
  static const String greetingUrl = '${baseUrl}greetings/';

  /// 📂 Category Base URLs (v1)
  static const String userApiV1 = '${baseUrl2}user/';
  static const String editorApiV1 = '${baseUrl2}editor/';

  // ============================
  // 🔐 Authentication APIs (v1)
  // ============================
  static const String loginV1 = '${userApiV1}login_api.php';
  static const String registrationV1 = '${userApiV1}registration_api.php';
  static const String forgotPasswordV1 = '${userApiV1}forgot_password_api.php';
  static const String resetPasswordV1 = '${userApiV1}reset_password_api.php';

  // Legacy/misc auth endpoints (if still in use elsewhere)
  static const String phoneAuthApi = '${baseUrl}phoneAuth_api.php';
  static const String verifyUserApi = '${baseUrl}verifyUser_Api.php';
  static const String expireOtpApi = '${baseUrl}expireOtp_api.php';

  // ============================
  // 👤 User Profile APIs
  // ============================
  static const String updateProfileApi = '${baseUrl}updateProfile_api.php';
  static const String updateProfileV1 = '${userApiV1}update_profile_api.php';

  // ============================
  // 🌍 Location APIs (v1)
  // ============================
  // Old location API - commented out, now using 3 separate APIs
  // static const String locationApi = '${baseUrl}location.php';
  // static const String locationApiV1 = '${userApiV1}location_api.php';

  // New Location APIs - using separate endpoints
  static const String getStatesApiV1 = '${userApiV1}get_states_api.php';
  static const String getDistrictsApiV1 = '${userApiV1}get_districts_api.php';
  // Note: API filename might be 'get_landmarks_api.php' (with 'k') instead of 'get_landmars_api.php'
  // Trying both variants - verify with backend which is correct
  static const String getLandmarksApiV1 = '${userApiV1}get_landmarks_api.php';
  // static const String getLandmarksApiV1 = '${userApiV1}get_landmars_api.php'; // Alternative if above doesn't work

  // ============================
  // ✏️ Editor APIs (v1)
  // ============================
  static const String addStatesApiV1 = '${editorApiV1}add_states_api.php';
  static const String addDistrictsApiV1 = '${editorApiV1}add_districts_api.php';
  static const String addLandmarksApiV1 = '${editorApiV1}add_landmarks_api.php';
  static const String addTopicsApiV1 = '${editorApiV1}add_topics_api.php';
  static const String addPostApiV1 = '${editorApiV1}add_post_api.php';

  // ============================
  // 📰 News APIs
  // ============================
  static const String postApi = '${newsUrl}posts_api.php';
  static const String postByIdApi = '${newsUrl}postById_api.php';
  static const String topicsApi = '${newsUrl}topics_api.php';
  static const String politicianApi = '${newsUrl}politicians_api.php';
  static const String commentsApi = '${newsUrl}comments_api.php';
  static const String replyCommentsApi = '${newsUrl}replyComments.php';
  static const String viewCountUpdateApi =
      '${newsUrl}view_count_update_api.php';
  static const String whatsShareCountApi =
      '${newsUrl}whats_share_count_api.php';
  static const String likeApi = '${newsUrl}like_api.php';
  static const String newCommentApi = '${newsUrl}new_comment_api.php';
  static const String reportApi = '${newsUrl}report_api.php';
  static const String updatePoliticianStatusApi =
      '${newsUrl}update_politician_status_api.php';

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
