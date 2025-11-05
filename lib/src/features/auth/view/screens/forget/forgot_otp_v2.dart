// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../viewmodel/auth_provider.dart';
//
// class ForgotOtpScreenV2 extends StatefulWidget {
//   const ForgotOtpScreenV2({Key? key}) : super(key: key);
//
//   @override
//   State<ForgotOtpScreenV2> createState() => _ForgotOtpScreenV2State();
// }
//
// class _ForgotOtpScreenV2State extends State<ForgotOtpScreenV2> {
//   final TextEditingController _mobileController = TextEditingController();
//   final TextEditingController _idController = TextEditingController();
//   final TextEditingController _otpController = TextEditingController();
//
//   @override
//   void dispose() {
//     _mobileController.dispose();
//     _idController.dispose();
//     _otpController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _sendOtp() async {
//     final auth = context.read<AuthProvider>();
//     try {
//       await auth.sendOtp(mobile: _mobileController.text.trim());
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('OTP sent')),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to send OTP: $e')),
//       );
//     }
//   }
//
//   Future<void> _expireOtp() async {
//     final auth = context.read<AuthProvider>();
//     try {
//       await auth.expireOtp(
//         id: _idController.text.trim(),
//         mobile: _mobileController.text.trim(),
//         otp: _otpController.text.trim(),
//       );
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('OTP expired')),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to expire OTP: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final auth = context.watch<AuthProvider>();
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Forgot OTP (V2)')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _mobileController,
//               decoration: const InputDecoration(labelText: 'Mobile'),
//               keyboardType: TextInputType.phone,
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _idController,
//               decoration: const InputDecoration(labelText: 'ID'),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _otpController,
//               decoration: const InputDecoration(labelText: 'OTP'),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 24),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: auth.isLoading ? null : _sendOtp,
//                     child: const Text('Send OTP'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: auth.isLoading ? null : _expireOtp,
//                     child: const Text('Expire OTP'),
//                   ),
//                 ),
//               ],
//             ),
//             if (auth.error != null) ...[
//               const SizedBox(height: 12),
//               Text(auth.error!, style: const TextStyle(color: Colors.red)),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
