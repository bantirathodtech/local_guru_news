// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:local_guru_all/src/core/components/appBar/app_bar.dart';
// import 'package:local_guru_all/src/core/components/button/custom_button.dart';
// import 'package:local_guru_all/src/core/components/text_fields/custom_text_field.dart';
// import 'package:local_guru_all/src/core/constants/app_colors.dart';
// import 'package:local_guru_all/src/core/services/api/auth_service.dart';
// import 'package:lottie/lottie.dart';
//
// import '../../../src.dart';
//
// class RegistrationScreen extends StatefulWidget {
//   const RegistrationScreen({Key? key}) : super(key: key);
//
//   @override
//   _RegistrationScreenState createState() => _RegistrationScreenState();
// }
//
// class _RegistrationScreenState extends State<RegistrationScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _contactController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _aadharController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//
//   String _selectedRole = 'user';
//   bool _isLoading = false;
//
//   Box<String> box = Hive.box('user');
//
//   void _handleRegistration() async {
//     if (_nameController.text.isEmpty ||
//         _contactController.text.isEmpty ||
//         _emailController.text.isEmpty ||
//         _passwordController.text.isEmpty ||
//         _aadharController.text.isEmpty ||
//         _addressController.text.isEmpty) {
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
//     final result = await AuthService.register(
//       name: _nameController.text.trim(),
//       contact: _contactController.text.trim(),
//       email: _emailController.text.trim(),
//       password: _passwordController.text.trim(),
//       role: _selectedRole,
//       aadharNumber: _aadharController.text.trim(),
//       address: _addressController.text.trim(),
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
//         SnackBar(content: Text('Registration Successful')),
//       );
//
//       Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => DashBoardScreen()),
//         (route) => false,
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(result['message'] ?? 'Registration failed')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Create Account',
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
//               height: 120.h,
//               fit: BoxFit.contain,
//             ),
//             SizedBox(height: 20.h),
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
//               controller: _nameController,
//               labelText: 'Full Name',
//               hintText: 'Enter your full name',
//             ),
//             SizedBox(height: 15.h),
//
//             CustomTextField(
//               controller: _contactController,
//               labelText: 'Contact Number',
//               hintText: 'Enter your contact number',
//               keyboardType: TextInputType.phone,
//               maxLength: 10,
//             ),
//             SizedBox(height: 15.h),
//
//             CustomTextField(
//               controller: _emailController,
//               labelText: 'Email',
//               hintText: 'Enter your email',
//               keyboardType: TextInputType.emailAddress,
//             ),
//             SizedBox(height: 15.h),
//
//             CustomTextField(
//               controller: _passwordController,
//               labelText: 'Password',
//               hintText: 'Enter your password',
//               obscureText: true,
//             ),
//             SizedBox(height: 15.h),
//
//             CustomTextField(
//               controller: _aadharController,
//               labelText: 'Aadhar Number',
//               hintText: 'Enter your Aadhar number',
//               keyboardType: TextInputType.number,
//               maxLength: 12,
//             ),
//             SizedBox(height: 15.h),
//
//             CustomTextField(
//               controller: _addressController,
//               labelText: 'Address',
//               hintText: 'Enter your address',
//               maxLines: 2,
//             ),
//             SizedBox(height: 30.h),
//
//             _isLoading
//                 ? CircularProgressIndicator()
//                 : CustomButton(
//                     text: 'Register',
//                     backgroundColor: AppColors.black,
//                     foregroundColor: AppColors.white,
//                     onPressed: _handleRegistration,
//                   ),
//
//             SizedBox(height: 20.h),
//
//             TextButton(
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => LoginScreen(),
//                   ),
//                 );
//               },
//               child: Text('Already have an account? Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
