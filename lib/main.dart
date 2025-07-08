// // import 'package:device_preview/device_preview.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:sizer/sizer.dart';
//
// import 'src/src.dart';
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
// }
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Firebase
//   await Firebase.initializeApp();
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//   // Firebase Token
//   // firebaseToken().then((value) => DatabaseService.getToken(value));
//
// // Hive
//   await Hive.initFlutter();
//   await Hive.openBox<String>('user');
//
//   runApp(
//     ProviderScope(
//       child: MyApp(),
//     ),
//   );
//   // runApp(
//   //   DevicePreview(
//   //     enabled: !kReleaseMode,
//   //     builder: (context) => ProviderScope(
//   //       child: MyApp(),
//   //     ),
//   //   ),
//   // );
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       SystemUiOverlayStyle(
//         statusBarColor: Colors.white,
//         statusBarIconBrightness: Brightness.dark,
//       ),
//     );
//     Box<String> box = Hive.box('user');
//     return Sizer(
//       builder: (context, orientation, deviceType) {
//         return MaterialApp(
//           title: appName,
//           theme: ThemeData(
//             primarySwatch: Colors.red,
//             scaffoldBackgroundColor: primaryColor,
//             appBarTheme: AppBarTheme(
//               backgroundColor: primaryColor,
//               elevation: 0, systemOverlayStyle: SystemUiOverlayStyle.light,
//             ),
//           ),
//           debugShowCheckedModeBanner: false,
//           home: box.containsKey('landmark')
//               ? box.get('landmark')!.isNotEmpty
//                   ? DashBoardScreen()
//                   : LocationScreen()
//               : LocationScreen(),
//           // home: ShareImageStamp(),
//         );
//       },
//     );
//   }
// }





///////////////////////



import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';

import 'src/src.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Manually initializing Firebase with custom options
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyBp0QJ_KcT9f5wsj8D_px5kLLW7WiQAsSE',
      appId: 'localguru-cde88',
      messagingSenderId: '39697531048-1jrke4f31gar4he8h13hnqt181tvjb1h.apps.googleusercontent.com', // Replace with your messaging sender ID
      projectId: 'localguru-cde88',
      storageBucket: 'localguru-cde88.appspot.com',
      // projectNumber: '39697531048',
    ),
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Firebase Token - if you need this later
  // firebaseToken().then((value) => DatabaseService.getToken(value));

  // Hive setup
  await Hive.initFlutter();
  await Hive.openBox<String>('user');

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    Box<String> box = Hive.box('user');
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: appName,
          theme: ThemeData(
            primarySwatch: Colors.red,
            scaffoldBackgroundColor: primaryColor,
            appBarTheme: AppBarTheme(
              backgroundColor: primaryColor,
              elevation: 0, systemOverlayStyle: SystemUiOverlayStyle.light,
            ),
          ),
          debugShowCheckedModeBanner: false,
          home:
          // DashBoardScreen()

          box.containsKey('landmark')
              ? box.get('landmark')!.isNotEmpty
              ? DashBoardScreen()
              : LocationScreen()
              : LocationScreen(), //Balu
        );
      },
    );
  }
}
