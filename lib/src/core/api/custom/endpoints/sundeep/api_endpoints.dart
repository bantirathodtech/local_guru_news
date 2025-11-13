/// API endpoints and configuration constants
/// Used by: All feature services
class ApiEndpoints {
  /// 🔗 Legacy Base URL
  static const String baseUrl = 'https://localguru.in/_api/';

  /// 🔗 Base URL v1
  static const String baseUrl2 = 'https://localguru.in/_api_v1/';

  /// 📂 Category Base URLs
  // static const String newsUrl = '${baseUrl}news/';
  static const String newsUrlV1 = '${baseUrl2}user/';
  static const String jobUrlV1 = '${baseUrl2}user/';
  static const String listingsUrlV1 = '${baseUrl2}user/';
  static const String greetingUrlV1 = '${baseUrl2}user/';

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

  // ============================
  // 👤 User Profile APIs
  // ============================
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
  // static const String postApi = '${newsUrl}posts_api.php';
  static const String getAllPostsApi = '${newsUrlV1}get_all_posts_api.php';
  static const String fetchEditorPostsApi =
      '${newsUrlV1}fetch_editor_posts_api.php';
  // static const String postByIdApi = '${newsUrl}postById_api.php';
  static const String postByIdApi = '${newsUrlV1}postById_api.php';
  // static const String topicsApi = '${newsUrlV1}topics_api.php';
  static const String topicsApi = '${editorApiV1}topics_api.php';
  static const String politicianApi = '${newsUrlV1}politicians_api.php';
  static const String commentsApi = '${newsUrlV1}comments_api.php';
  static const String replyCommentsApi = '${newsUrlV1}replyComments.php';
  static const String viewCountUpdateApi =
      '${newsUrlV1}view_count_update_api.php';
  static const String whatsShareCountApi =
      '${newsUrlV1}whats_share_count_api.php';
  static const String likeApi = '${newsUrlV1}like_api.php';
  static const String newCommentApi = '${newsUrlV1}new_comment_api.php';
  static const String reportApi = '${newsUrlV1}report_api.php';
  static const String updatePoliticianStatusApi =
      '${newsUrlV1}update_politician_status_api.php';

  // ============================
  // 💼 Jobs APIs
  // ============================
  static const String jobsApi = '${jobUrlV1}jobs_posts_api.php';
  static const String addNewJobApi = '${jobUrlV1}add_new_job.php';
  static const String searchJobsApi = '${jobUrlV1}job_search_api.php';
  static const String jobNewDataApi = '${jobUrlV1}job_new_data_api.php';

  // ============================
  // 📋 Listings APIs
  // ============================
  static const String listSearchApi = '${listingsUrlV1}lists_search_api.php';
  static const String listPostApi = '${listingsUrlV1}lists_posts_api.php';
  static const String listTopicsApi = '${listingsUrlV1}list_topics_api.php';

  // ============================
  // 🎉 Greetings APIs
  // ============================
  static const String greetingsApi = '${greetingUrlV1}greetings_api.php';
  static const String greetingsTopicsApi =
      '${greetingUrlV1}greetings_topics_api.php';

  // ============================
  // 📦 Requirements APIs
  // ============================
  static const String requirementsMenuApi =
      '${baseUrl}requirements_menu_api.php';
  static const String requirementsApi = '${baseUrl}requirements_api.php';
}
