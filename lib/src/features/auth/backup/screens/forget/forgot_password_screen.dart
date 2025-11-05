// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:local_guru_all/src/core/components/appBar/app_bar.dart';
// import 'package:local_guru_all/src/core/components/button/custom_button.dart';
// import 'package:local_guru_all/src/core/components/text_fields/custom_text_field.dart';
// import 'package:local_guru_all/src/core/constants/app_colors.dart';
// import 'package:local_guru_all/src/core/services/api/auth_service.dart';
// import 'package:lottie/lottie.dart';
//
// import '../../../src.dart';
//
// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({Key? key}) : super(key: key);
//
//   @override
//   _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
// }
//
// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _otpController = TextEditingController();
//   final TextEditingController _newPasswordController = TextEditingController();
//
//   String _selectedRole = 'user';
//   bool _isLoading = false;
//   bool _otpSent = false;
//   bool _showResetForm = false;
//
//   void _handleForgotPassword() async {
//     if (_emailController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please enter your email')),
//       );
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     final result = await AuthService.forgotPassword(
//       email: _emailController.text.trim(),
//       role: _selectedRole,
//     );
//
//     setState(() {
//       _isLoading = false;
//     });
//
//     if (result['status'] == 'Success') {
//       setState(() {
//         _otpSent = true;
//         _showResetForm = true;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('OTP sent to your email')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(result['message'] ?? 'Failed to send OTP')),
//       );
//     }
//   }
//
//   void _handleResetPassword() async {
//     if (_otpController.text.isEmpty || _newPasswordController.text.isEmpty) {
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
//     final result = await AuthService.resetPassword(
//       email: _emailController.text.trim(),
//       role: _selectedRole,
//       otp: _otpController.text.trim(),
//       newPassword: _newPasswordController.text.trim(),
//     );
//
//     setState(() {
//       _isLoading = false;
//     });
//
//     if (result['status'] == 'Success') {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Password reset successfully')),
//       );
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => LoginScreen(),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(result['message'] ?? 'Password reset failed')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Forgot Password',
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
//             if (!_showResetForm) ...[
//               // Forgot Password Form
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12.w),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     value: _selectedRole,
//                     isExpanded: true,
//                     items: ['user', 'editor']
//                         .map((role) => DropdownMenuItem(
//                               value: role,
//                               child: Text(
//                                 role.toUpperCase(),
//                                 style: TextStyle(fontSize: 14.sp),
//                               ),
//                             ))
//                         .toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedRole = value!;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20.h),
//
//               CustomTextField(
//                 controller: _emailController,
//                 labelText: 'Email',
//                 hintText: 'Enter your registered email',
//                 keyboardType: TextInputType.emailAddress,
//                 suffixIcon: Icon(Icons.email_rounded, size: 18.sp),
//               ),
//               SizedBox(height: 30.h),
//
//               _isLoading
//                   ? CircularProgressIndicator()
//                   : CustomButton(
//                       text: 'Send OTP',
//                       backgroundColor: AppColors.black,
//                       foregroundColor: AppColors.white,
//                       onPressed: _handleForgotPassword,
//                     ),
//             ] else ...[
//               // Reset Password Form
//               Text(
//                 'Enter OTP and New Password',
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 20.h),
//
//               CustomTextField(
//                 controller: _otpController,
//                 labelText: 'OTP',
//                 hintText: 'Enter OTP received via email',
//                 keyboardType: TextInputType.number,
//               ),
//               SizedBox(height: 20.h),
//
//               CustomTextField(
//                 controller: _newPasswordController,
//                 labelText: 'New Password',
//                 hintText: 'Enter new password',
//                 obscureText: true,
//               ),
//               SizedBox(height: 30.h),
//
//               _isLoading
//                   ? CircularProgressIndicator()
//                   : CustomButton(
//                       text: 'Reset Password',
//                       backgroundColor: AppColors.black,
//                       foregroundColor: AppColors.white,
//                       onPressed: _handleResetPassword,
//                     ),
//
//               SizedBox(height: 20.h),
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _showResetForm = false;
//                     _otpSent = false;
//                   });
//                 },
//                 child: Text('Back to Forgot Password'),
//               ),
//             ],
//             SizedBox(height: 20.h),
//             TextButton(
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => LoginScreen(),
//                   ),
//                 );
//               },
//               child: Text('Back to Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
