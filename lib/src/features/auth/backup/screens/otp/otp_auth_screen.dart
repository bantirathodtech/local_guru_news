// import 'package:circular_countdown_timer/circular_countdown_timer.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:local_guru_all/src/core/components/appBar/app_bar.dart';
// import 'package:local_guru_all/src/core/components/button/custom_button.dart';
// import 'package:local_guru_all/src/core/components/text_fields/custom_text_field.dart';
// import 'package:local_guru_all/src/core/constants/app_colors.dart';
// import 'package:local_guru_all/src/src.dart';
// import 'package:lottie/lottie.dart';
//
// class OtpAuthScreen extends StatefulWidget {
//   final int? id;
//   final int? otp;
//   final String? contact;
//
//   const OtpAuthScreen({
//     Key? key,
//     this.id,
//     this.otp,
//     this.contact,
//   }) : super(key: key);
//
//   @override
//   _OtpAuthState createState() => _OtpAuthState();
// }
//
// class _OtpAuthState extends State<OtpAuthScreen> {
//   TextEditingController otpController = TextEditingController();
//
//   CountDownController _controller = CountDownController();
//   int countdown = 60;
//
//   bool expired = false;
//
//   late int id;
//   late int otp;
//   late String contact;
//
//   @override
//   void initState() {
//     super.initState();
//     id = widget.id!;
//     otp = widget.otp!;
//     contact = widget.contact!;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset:
//           true, // Important to avoid overflow when keyboard appears
//       appBar: CustomAppBar(
//         title: 'OTP Verification',
//         backgroundColor: AppColors.primary,
//         iconColor: AppColors.black,
//         titleColor: AppColors.black,
//       ),
//       body: SafeArea(
//         child: GestureDetector(
//           onTap: () => FocusScope.of(context)
//               .unfocus(), // Dismiss keyboard on tap outside
//           child: SingleChildScrollView(
//             physics: BouncingScrollPhysics(),
//             padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Lottie.asset(
//                   lottie + 'logo.json',
//                   height: 150.h,
//                   fit: BoxFit.contain,
//                 ),
//                 SizedBox(height: 30.h),
//                 CustomTextField(
//                   controller: otpController,
//                   labelText: 'OTP',
//                   hintText: 'Enter Received OTP',
//                   keyboardType: TextInputType.number,
//                   suffixIcon: Icon(
//                     Icons.mobile_friendly_rounded,
//                     size: 18.sp,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter OTP';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 30.h),
//                 CustomButton(
//                   text: 'Submit',
//                   backgroundColor: AppColors.black,
//                   foregroundColor: AppColors.white,
//                   onPressed: () {
//                     if (otp.toString() == otpController.text) {
//                       firebaseToken().then((token) {
//                         return DatabaseService()
//                             .verifyUser(
//                           id.toString(),
//                           contact,
//                           otp.toString(),
//                           token,
//                         )
//                             .then((value) {
//                           if (value == "success") {
//                             Navigator.of(context, rootNavigator: true)
//                                 .pushAndRemoveUntil(
//                                     MaterialPageRoute(
//                                       builder: (context) => DashBoardScreen(),
//                                     ),
//                                     (route) => false);
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                   "Unable to Login, Please Check Your OTP again.....",
//                                 ),
//                               ),
//                             );
//                           }
//                         });
//                       });
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                             "Incorrect OTP, please try again.",
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                 ),
//                 SizedBox(height: 20.h),
//                 CircularCountDownTimer(
//                   duration: countdown,
//                   initialDuration: 0,
//                   controller: _controller,
//                   width: 50.w,
//                   height: 50.w,
//                   ringColor: Colors.blue,
//                   fillColor: Colors.blue[100]!,
//                   backgroundColor: Colors.blue[500],
//                   strokeWidth: 8.0,
//                   strokeCap: StrokeCap.round,
//                   textStyle: TextStyle(
//                     fontSize: 28.sp,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textFormat: CountdownTextFormat.S,
//                   isReverse: true,
//                   isReverseAnimation: false,
//                   isTimerTextShown: true,
//                   autoStart: true,
//                   onComplete: () {
//                     DatabaseService.expireOTP(
//                       id.toString(),
//                       contact,
//                       otp.toString(),
//                     ).then((value) {
//                       setState(() {
//                         expired = true;
//                       });
//                     });
//                   },
//                 ),
//                 SizedBox(height: 10.h),
//                 Text(
//                   expired
//                       ? 'Your OTP Expired'
//                       : 'Your OTP Expires in 60 seconds',
//                   style: TextStyle(
//                     color: expired ? Colors.red : Colors.black,
//                     fontSize: 14.sp,
//                   ),
//                 ),
//                 if (expired)
//                   Padding(
//                     padding: EdgeInsets.symmetric(vertical: 10.h),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         TextButton(
//                           onPressed: () {
//                             DatabaseService.getOtp(contact).then((value) {
//                               setState(() {
//                                 id = value.first.id!;
//                                 otp = value.first.otp!;
//                                 contact = value.first.mobile!;
//                                 expired = false;
//                                 countdown = 60;
//                               });
//                             });
//                             _controller.restart();
//                           },
//                           child: Text(
//                             'Resend',
//                             style: TextStyle(
//                               color: Colors.red.shade700,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14.sp,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
