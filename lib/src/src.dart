//! ________________________[News]______________________

//todo =======>[Components]<=======
export 'core/components/drawer/custom_drawer.dart'; // Custom Drawer Component
// export 'core/components//drawer.dart'; // Drawer Component (commented out)
export 'core/components/errorBody.dart'; // Error Body
export 'core/components/hexColorComponent.dart'; // Hex Color Component
export 'core/components/paginated_list/paginated_list_view.dart'; // Reusable Paginated List View
export 'core/components/empty_state.dart'; // Empty State Component
export 'core/components/loading_overlay.dart'; // Loading Overlay Component
export 'core/components/improved_shimmer.dart'; // Improved Shimmer Loading
export 'core/components/animations/fade_in_widget.dart'; // Animation Widgets
export 'core/components/error_widget_improved.dart'; // Improved Error Widget
export 'core/components/improved_button.dart'; // Improved Button Component
export 'features/news/rss/cache/rss_cache_manager.dart'; // RSS Cache Manager
export 'core/api/shared/state/app_state.dart'; // Global Riverpod providers
//todo =======>[Theme]<=======
export 'core/theme/app_theme.dart'; // App Theme Configuration
export 'core/theme/app_spacing.dart'; // Spacing System
export 'core/providers/theme_provider.dart'; // Theme Mode Provider
//todo =======>[Utils]<=======
export 'core/utils/assets.dart'; //Assets
export 'core/utils/colors.dart'; //Colors
export 'core/utils/responsiveService.dart'; // Responsive Service
export 'core/utils/strings.dart'; //Strings
export 'core/utils/timeAgo.dart'; // TimeAgo Service
export 'features/auth/data/model/mobileAuth_Model.dart'; // Mobile Auth Model (data layer)
// export 'features/auth/otp/otp_auth_screen.dart';
// export 'features/auth/profile/profileScreen.dart'; // Profile
// export 'features/auth/signin/mobileAuthScreen.dart'; // Mobile Auth
// NEW: Auth (data/model)
export 'features/auth/data/model/userModel.dart'; // User Model (data layer)
// NEW: Auth (data/repository)
export 'features/auth/data/repository/auth_repository.dart'; // Auth Repository
// export 'features/auth/view/screens/forget/forgot_otp_v2.dart';
export 'features/auth/view/screens/forget/forgot_password_v2.dart';
// export 'features/auth/view/screens/otp/otp_v2.dart';
export 'features/auth/view/screens/profile/profile_v2.dart';
// NEW: Auth V2 Screens
export 'features/auth/view/screens/signin/sign_in_v2.dart';
export 'features/auth/view/screens/signinup/sign_up_v2.dart';
export 'features/auth/view/screens/splash/splash_v2.dart';
// NEW: Auth (viewmodel)
export 'features/auth/viewmodel/auth_provider.dart'; // Auth Provider
//! ________________________[End Listings]______________________

//! ________________________[Deals]______________________

//todo =======>[Models]<=======
//todo =======>[Views]<=======
//todo =======>[Controllers]<=======
//todo =======>[Services]<=======
//todo =======>[Components]<=======

//! ________________________[End Deals]______________________

//! ________________________[Greetings]______________________

//todo =======>[Models]<=======
export 'features/greetings/data/model/greetingsModel.dart'; //Greetings
//////////
export 'features/greetings/data/model/greetingsPaginationModel.dart'; //Greetings
export 'features/greetings/data/model/greetingsTopicsModel.dart'; //Greetings Topics
//todo =======>[Services]<=======
export 'features/greetings/data/repository/greetingsPaginationService.dart'; //Greetings
export 'features/greetings/data/repository/greetingsTopicsService.dart'; //Greetings Topics
//todo =======>[Views]<=======
export 'features/greetings/view/screens/greetings_dashboard.dart'; //Greetings
//todo =======>[Components]<=======
export 'features/greetings/view/widgets/GreetingsTopicListComponent.dart'; // Greetings Topics List Component
//todo =======>[Controllers]<=======
export 'features/greetings/viewmodel/greetingsPaginationController.dart'; //Greetings
export 'features/greetings/viewmodel/greetingsTopicsController.dart'; //Greetings Topics
export 'features/greetings/viewmodel/greetingsTopicsModel.dart'; //Greetings Topics
//todo =======>[Views]<=======
export 'features/home/dashboardScreen.dart'; // Dashboard
export 'features/jobs/data/model/jobSearchModel.dart'; //Job Search
export 'features/jobs/data/model/jobSearchPagination.dart';
//! ________________________[End News]__________________

//! ________________________[Jobs]______________________

//todo =======>[Models]<=======
export 'features/jobs/data/model/jobsModel.dart'; //Jobs Posts
//////////
export 'features/jobs/data/model/jobsPagination.dart';
export 'features/jobs/data/model/newJobDataModel.dart'; //New Job Data
//todo =======>[Services]<=======
export 'features/jobs/data/repository/jobPaginationService.dart'; //Jobs Posts
export 'features/jobs/data/repository/jobSearchPaginationService.dart';
export 'features/jobs/view/screens/job_coming.dart'; // Coming Soon
export 'features/jobs/view/screens/job_search.dart'; //Search Job
//todo =======>[Views]<=======
export 'features/jobs/view/screens/jobs_dashboard.dart'; //Jobs
export 'features/jobs/view/screens/jobs_details.dart'; //Jobs Details
export 'features/jobs/view/screens/new_job.dart'; //Add New Job
//todo =======>[Components]<=======
export 'features/jobs/view/widgets/jobComponent.dart'; // JobLayout Component
export 'features/jobs/viewmodel/jobSearchPaginationController.dart';
//todo =======>[Controllers]<=======
export 'features/jobs/viewmodel/jobsPaginationController.dart';
export 'features/listing/data/model/listSearchModel.dart'; //Search Posts
export 'features/listing/data/model/listSearchPaginationModel.dart'; //Lists Posts
//! ________________________[End Jobs]______________________

//! ________________________[Listings]______________________

//todo =======>[Models]<=======
export 'features/listing/data/model/listTopics.dart'; //Lists Topics
export 'features/listing/data/model/listsModel.dart'; //Lists Posts
//////////
export 'features/listing/data/model/listsPostPaginationModel.dart'; //Lists Posts
export 'features/listing/data/repository/listSearchPaginationService.dart';
//todo =======>[Services]<=======
export 'features/listing/data/repository/listsPaginationService.dart';
export 'features/listing/view/screen/listing_coming.dart'; // Coming Soon
//todo =======>[Views]<=======
export 'features/listing/view/screen/listings_dashboard.dart';
export 'features/listing/view/screen/listsDetails.dart';
export 'features/listing/view/screen/lists_Search.dart';
//todo =======>[Components]<=======
export 'features/listing/view/widgets/listsTopicComponent.dart';
//todo =======>[Controllers]<=======
export 'features/listing/viewmodel/listsPostPaginationController.dart';
export 'features/listing/viewmodel/listsSearchPaginationController.dart';
//! ________________________[End Listings]______________________

//! ________________________[Requirements]______________________
//todo =======>[Models]<=======
export 'features/requirement/data/model/requirementsModel.dart'; // Requirements Model
//todo =======>[Repositories]<=======
export 'features/requirement/data/repository/requirements_repository.dart'; // Requirements Repository
//todo =======>[Views]<=======
export 'features/requirement/view/screen/requirementsScreen.dart'; // Requirements Screen
//! ________________________[End Requirements]______________________

//! ________________________[App]_______________

//todo =======>[Models]<=======
export 'features/location/model/locationModel.dart'; // Location Model
export 'features/location/view/screen/locationScreen.dart'; // Location
export 'features/news/data/model/comments/all/commentsModel.dart'; // Comments
export 'features/news/data/model/comments/all/commentsPagination.dart'; // Comments
export 'features/news/data/model/comments/reply/replyCommentsPagination.dart'; // Reply Comments
export 'features/news/data/model/politician/politiciansModel.dart'; // Politicians
export 'features/news/data/model/politician/politicians_Model.dart'; //Politicians
//////////
export 'features/news/data/model/posts/all/postsPaginationModel.dart'; // Posts
//todo =======>[Models]<=======
export 'features/news/data/model/posts/all/posts_Model.dart'; // Posts
export 'features/news/data/model/posts/individual/postIndividualModel.dart'; // Single Post
export 'features/news/data/model/posts/postModelById.dart'; // Single Post
export 'features/news/data/model/topics/topics_Model.dart'; // Topics
export 'features/news/data/repository/comments/all/commentsPaginationService.dart'; // Comments Service
export 'features/news/data/repository/comments/reply/replyCommentsPaginationService.dart'; // Reply Comments Service
export 'features/news/data/repository/politician/politiciansServices.dart'; // Politicans
export 'features/news/data/repository/post/post_engagement_repository.dart'; // Post Engagement Repository
export 'features/news/data/repository/post/new_api/all/postsRepository.dart'; // Posts Repository (New APIs)
//todo =======>[Services]<=======
export 'features/news/data/repository/post/new_api/all/postPaginationService.dart'; // Posts Service
export 'features/news/data/repository/post/new_api/individual/postIndividualService.dart'; // Single Post Service
export 'features/news/data/repository/post/old_api/all/postPaginationService.dart'; // Legacy Posts Service
export 'features/news/data/repository/topics/topicsRepository.dart'; // Topics
export 'features/news/view/screens/comments/all/commentsScreen.dart'; //Comments
export 'features/news/view/screens/comments/reply/replyCommentsScreen.dart'; //Reply Comments
export 'features/news/view/screens/comments/single/newCommentScreen.dart'; // New Comment
export 'features/news/view/screens/followers/followers.dart'; //Followers
//todo =======>[Views]<=======
export 'features/news/view/screens/news_dashboard.dart'; // News Dashboard Screen
export 'features/news/view/screens/post/all/postViewScreen.dart'; //Posts
export 'features/news/view/screens/post/single/postViewSingle.dart'; //Single Post
export 'features/news/view/screens/search/searchScreen.dart'; //Search
//todo =======>[Components]<=======
export 'features/news/view/widgets/newsLayoutComponent.dart'; // News Layout Component
export 'features/news/view/widgets/news_shimmer.dart'; // News Shimmers
export 'features/news/view/widgets/politiciansLayout.dart'; // Politicians Component
export 'features/news/view/widgets/related_news_card.dart'; // Related News Card Component
export 'features/news/view/widgets/socialBanner.dart'; // SocialBanner Component
export 'features/news/view/widgets/topicListComponent.dart'; // Topics List Component
export 'features/news/view/widgets/videoItem.dart'; // Video Item Component
export 'features/news/viewmodel/comments/all/commentsPaginationController.dart'; //Comments
export 'features/news/viewmodel/comments/reply/replyCommentsPaginationController.dart'; // Reply Comments
export 'features/news/viewmodel/politician/politiciansControllers.dart'; // Politicians
//todo =======>[Controllers]<=======
export 'features/news/viewmodel/post/new_api/all/postPaginationController.dart'; // Posts
export 'features/news/viewmodel/post/new_api/single/postIndividualController.dart'; // Single Post
export 'features/news/viewmodel/post/old_api/all/legacy_news_filters.dart'; // Legacy Filter Providers
export 'features/news/viewmodel/post/old_api/all/postPaginationController.dart'; // Legacy Posts
export 'features/news/viewmodel/topics/topicsController.dart'; // Topics
