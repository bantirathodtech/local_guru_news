// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:local_guru_all/src/core/constants/app_colors.dart';
// import 'package:local_guru_all/src/core/constants/app_strings.dart';
//
// // import '../../../../../core/states/helpers/provider_helper.dart';
// // import '../../../../../core/ui/constants/app_colors.dart';
// // import '../../../../../core/ui/constants/app_strings.dart';
// // import '../../../../../core/ui/navigation/routes/routes.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   SplashScreenState createState() => SplashScreenState();
// }
//
// class SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
//     );
//     _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
//     );
//     _animationController.forward();
//     _initializeAndNavigate();
//   }
//
//   Future<void> _initializeAndNavigate() async {
//     final authProvider = ProvidersHelper.auth(context);
//     final isLoggedIn = await authProvider.isLoggedInPersistent();
//
//     if (isLoggedIn) {
//       await authProvider.refreshUserData();
//       // Load any other necessary data for logged-in user
//     }
//
//     await Future.delayed(const Duration(seconds: 3));
//     if (mounted) {
//       // FIXED: Use proper navigation based on login status
//       if (authProvider.user != null) {
//         // Navigate to main screen (which is now HomeScreen)
//         Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
//       } else {
//         // Navigate to login screen
//         Navigator.pushReplacementNamed(context, AppRoutes.signin);
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primary,
//       body: Center(
//         child: FadeTransition(
//           opacity: _fadeAnimation,
//           child: ScaleTransition(
//             scale: _scaleAnimation,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   'assets/images/Medycart_patner.png',
//                   height: 100.h,
//                   width: 100.w,
//                   fit: BoxFit.scaleDown,
//                 ),
//                 SizedBox(height: 16.h),
//                 Text(
//                   AppStrings.appName,
//                   style: TextStyle(
//                     fontSize: 40.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                     letterSpacing: 2.0,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 Text(
//                   'medycart.in',
//                   style: TextStyle(
//                     fontSize: 18.sp,
//                     color: Colors.white70,
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//                 SizedBox(height: 24.h),
//                 CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
