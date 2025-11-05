// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../viewmodel/auth_provider.dart';
//
// class OtpScreenV2 extends StatefulWidget {
//   const OtpScreenV2({Key? key}) : super(key: key);
//
//   @override
//   State<OtpScreenV2> createState() => _OtpScreenV2State();
// }
//
// class _OtpScreenV2State extends State<OtpScreenV2> {
//   final TextEditingController _mobileController = TextEditingController();
//   final TextEditingController _otpController = TextEditingController();
//   final TextEditingController _idController = TextEditingController();
//   final TextEditingController _tokenController = TextEditingController();
//
//   @override
//   void dispose() {
//     _mobileController.dispose();
//     _otpController.dispose();
//     _idController.dispose();
//     _tokenController.dispose();
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
//   Future<void> _verify() async {
//     final auth = context.read<AuthProvider>();
//     try {
//       await auth.verifyUser(
//         id: _idController.text.trim(),
//         mobile: _mobileController.text.trim(),
//         otp: _otpController.text.trim(),
//         token: _tokenController.text.trim(),
//       );
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Verified successfully')),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Verification failed: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final auth = context.watch<AuthProvider>();
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('OTP (V2)')),
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
//             const SizedBox(height: 12),
//             TextField(
//               controller: _tokenController,
//               decoration: const InputDecoration(labelText: 'Token'),
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
//                     onPressed: auth.isLoading ? null : _verify,
//                     child: const Text('Verify'),
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
