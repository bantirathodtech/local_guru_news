import 'package:flutter/material.dart';
import 'package:local_guru_all/src/features/location/view/screens/location_screen_v2.dart';
import 'package:local_guru_all/src/src.dart';

class AppRoutes {
  // ============ Auth Routes ============
  static const String splash = '/splash';
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot_password';
  static const String resetPassword = '/reset_password';
  static const String profile = '/profile';

  // ============ Main App Routes ============
  static const String main = '/main';
  static const String dashboard = '/dashboard';

  // ============ Tab Routes ============
  static const String newsTab = '/news_tab';
  static const String jobsTab = '/jobs_tab';
  static const String listingsTab = '/listings_tab';
  static const String greetingsTab = '/greetings_tab';

  // ============ News Routes ============
  static const String newsDashboard = '/news_dashboard';
  static const String postView = '/post_view';
  static const String singlePostView = '/single_post_view';
  static const String comments = '/comments';
  static const String replyComments = '/reply_comments';
  static const String newComment = '/new_comment';
  static const String newsSearch = '/news_search';
  static const String followers = '/followers';

  // ============ Jobs Routes ============
  static const String jobsDashboard = '/jobs_dashboard';
  static const String jobsDetails = '/jobs_details';
  static const String jobSearch = '/job_search';
  static const String newJob = '/new_job';
  static const String jobComing = '/job_coming';

  // ============ Listings Routes ============
  static const String listingsDashboard = '/listings_dashboard';
  static const String listsDetails = '/lists_details';
  static const String listsSearch = '/lists_search';
  static const String listingComing = '/listing_coming';

  // ============ Greetings Routes ============
  static const String greetingsDashboard = '/greetings_dashboard';

  // ============ Location Routes ============
  static const String location = '/location';

  // ============ Other Routes ============
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // ============ Auth Routes ============
      splash: (context) => const SplashScreenV2(),
      signin: (context) => const SignInScreenV2(),
      signup: (context) => const SignUpScreenV2(),
      forgotPassword: (context) => const ForgotPasswordScreenV2(),
      resetPassword: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
        return ResetPasswordScreenV2(
          email: args?['email'] ?? '',
          role: args?['role'] ?? 'user',
        );
      },
      profile: (context) => const ProfileScreenV2(),

      // ============ Main App Routes ============
      main: (context) => DashBoardScreen(),
      dashboard: (context) => DashBoardScreen(),

      // ============ News Routes ============
      newsDashboard: (context) => const NewsDashboard(),
      singlePostView: (context) => const SinglePostView(),
      newComment: (context) => const NewCommentScreen(),
      newsSearch: (context) => const SearchScreen(),
      followers: (context) => const Followers(),

      // ============ Jobs Routes ============
      jobsDashboard: (context) => const JobsDashboard(),
      jobSearch: (context) => const JobSearchScreen(),
      jobComing: (context) => const JobComing(),

      // ============ Listings Routes ============
      listingsDashboard: (context) => const ListsDashboard(),
      listsSearch: (context) => const ListSearchScreen(),
      listingComing: (context) => const ListingComing(),

      // ============ Greetings Routes ============
      greetingsDashboard: (context) => const GreetingsDashboard(),

      // ============ Location Routes ============
      location: (context) => const LocationScreenV2(),
    };
  }
}
