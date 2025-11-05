// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:local_guru_all/src/core/components/appBar/app_bar.dart';
// import 'package:local_guru_all/src/core/components/button/custom_button.dart';
// import 'package:local_guru_all/src/core/components/text_fields/custom_text_field.dart';
// import 'package:local_guru_all/src/core/constants/app_colors.dart';
// // import 'package:local_guru_all/src/core/services/api/auth_service.dart';
// import 'package:lottie/lottie.dart';
//
// // import '../../../src.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);
//
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   String _selectedRole = 'user';
//   bool _isLoading = false;
//
//   Box<String> box = Hive.box('user');
//
//   void _handleLogin() async {
//     if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please fill all fields')),
//       );
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     final result = await AuthService.login(
//       email: _emailController.text.trim(),
//       password: _passwordController.text.trim(),
//       role: _selectedRole,
//     );
//
//     setState(() {
//       _isLoading = false;
//     });
//
//     if (result['status'] == 'Success') {
//       // Store user data in Hive
//       box.put('id', result['id'].toString());
//       box.put('name', result['name'].toString());
//       box.put('role', result['role'].toString());
//       box.put('email', _emailController.text.trim());
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(result['message'] ?? 'Login Successful')),
//       );
//
//       Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => DashBoardScreen()),
//         (route) => false,
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(result['message'] ?? 'Login failed')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Email Login',
//         backgroundColor: AppColors.primary,
//         iconColor: AppColors.black,
//         titleColor: AppColors.black,
//       ),
//       body: SingleChildScrollView(
//         physics: BouncingScrollPhysics(),
//         padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Lottie.asset(
//               lottie + 'logo.json',
//               height: 150.h,
//               fit: BoxFit.contain,
//             ),
//             SizedBox(height: 30.h),
//
//             // Role Selection
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 12.w),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   value: _selectedRole,
//                   isExpanded: true,
//                   items: ['user', 'editor']
//                       .map((role) => DropdownMenuItem(
//                             value: role,
//                             child: Text(
//                               role.toUpperCase(),
//                               style: TextStyle(fontSize: 14.sp),
//                             ),
//                           ))
//                       .toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedRole = value!;
//                     });
//                   },
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.h),
//
//             CustomTextField(
//               controller: _emailController,
//               labelText: 'Email',
//               hintText: 'Enter your email',
//               keyboardType: TextInputType.emailAddress,
//               suffixIcon: Icon(Icons.email_rounded, size: 18.sp),
//             ),
//             SizedBox(height: 20.h),
//
//             CustomTextField(
//               controller: _passwordController,
//               labelText: 'Password',
//               hintText: 'Enter your password',
//               obscureText: true,
//               suffixIcon: Icon(Icons.lock_rounded, size: 18.sp),
//             ),
//             SizedBox(height: 30.h),
//
//             _isLoading
//                 ? CircularProgressIndicator()
//                 : CustomButton(
//                     text: 'Login',
//                     backgroundColor: AppColors.black,
//                     foregroundColor: AppColors.white,
//                     onPressed: _handleLogin,
//                   ),
//
//             SizedBox(height: 20.h),
//
//             // Navigation to other auth screens
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => RegistrationScreen(),
//                       ),
//                     );
//                   },
//                   child: Text('Create Account'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ForgotPasswordScreen(),
//                       ),
//                     );
//                   },
//                   child: Text('Forgot Password?'),
//                 ),
//               ],
//             ),
//
//             // Divider with OR text
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: 20.h),
//               child: Row(
//                 children: [
//                   Expanded(child: Divider()),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 10.w),
//                     child: Text('OR'),
//                   ),
//                   Expanded(child: Divider()),
//                 ],
//               ),
//             ),
//
//             // Mobile login option
//             CustomButton(
//               text: 'Login with Mobile',
//               backgroundColor: AppColors.primary,
//               foregroundColor: AppColors.black,
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => MobileAuthScreen(),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
