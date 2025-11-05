// import 'package:flutter/material.dart';
// import 'package:local_guru_all/src/core/components/appBar/app_bar.dart';
// import 'package:local_guru_all/src/core/components/button/custom_button.dart';
// import 'package:local_guru_all/src/core/components/text_fields/custom_text_field.dart';
// import 'package:local_guru_all/src/core/constants/app_colors.dart';
// import 'package:lottie/lottie.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../src.dart';
//
// class MobileAuthScreen extends StatefulWidget {
//   @override
//   _MobileAuthScreenState createState() => _MobileAuthScreenState();
// }
//
// class _MobileAuthScreenState extends State<MobileAuthScreen> {
//   TextEditingController mobile = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Login',
//         backgroundColor: AppColors.primary,
//         iconColor: AppColors.black,
//         titleColor: AppColors.black,
//         actions: [
//           Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: 2.h,
//             ),
//             child: TextButton.icon(
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => LocationScreen(),
//                 ),
//               ),
//               icon: Icon(
//                 Icons.location_on_rounded,
//                 color: AppColors.black, // Using white color for icon
//               ),
//               label: Text(
//                 'Change Location',
//                 style: TextStyle(
//                   color: AppColors.black, // Using white color for text
//                   fontSize: 14.sp,
//                   fontFamily: 'Roboto',
//                 ),
//               ),
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.white, // Using white color
//                 backgroundColor: Colors.transparent,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         physics: BouncingScrollPhysics(),
//         child: Container(
//           width: MediaQuery.of(context).size.width,
//           height: 80.h,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Lottie.asset(
//                 lottie + 'logo.json',
//                 height: 30.h,
//               ),
//               SizedBox(
//                 height: 60,
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: CustomTextField(
//                   controller: mobile,
//                   labelText: 'Mobile Number',
//                   hintText: 'Enter Mobile Number',
//                   keyboardType: TextInputType.number,
//                   maxLength: 10,
//                   prefixIcon: Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
//                     child: Text(
//                       '+91 ',
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                   ),
//                   suffixIcon: Icon(
//                     Icons.phonelink_setup_rounded,
//                     size: 14.sp,
//                     color: Colors.grey[600],
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter mobile number';
//                     }
//                     if (value.length != 10) {
//                       return 'Enter valid 10-digit number';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               SizedBox(
//                 height: 60,
//               ),
//               Padding(
//                 padding: EdgeInsets.all(16.0.sp),
//                 child: CustomButton(
//                   backgroundColor: Colors.black,
//                   foregroundColor: Colors.white,
//                   text: 'Get OTP',
//                   onPressed: () async {
//                     if (mobile.text.length != 10) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text("Enter Valid Number"),
//                         ),
//                       );
//                     } else {
//                       try {
//                         final value = await DatabaseService.getOtp(mobile.text);
//                         if (value != null && value.isNotEmpty) {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => OtpAuthScreen(
//                                 id: value.first.id,
//                                 otp: value.first.otp,
//                                 contact: value.first.mobile,
//                               ),
//                             ),
//                           );
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content:
//                                   Text("Failed to get OTP. Please try again."),
//                             ),
//                           );
//                         }
//                       } catch (e) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text("Error: $e"),
//                           ),
//                         );
//                       }
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
