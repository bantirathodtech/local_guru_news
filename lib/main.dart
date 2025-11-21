import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';

import 'src/src.dart';
import 'src/core/providers/app_providers.dart';

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
      messagingSenderId:
          '39697531048-1jrke4f31gar4he8h13hnqt181tvjb1h.apps.googleusercontent.com', // Replace with your messaging sender ID
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
      child: AppProviders(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Sizer(
      builder: (context, orientation, deviceType) {
        // Initialize ScreenUtil with safer parameters - moved to didChangeDependencies
        // Initialize ScreenUtil here with proper context
        ScreenUtil.init(
          context,
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
        );
        return MaterialApp(
          title: appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          home: const SplashScreenV2(),
        );
      },
    );
  }
}
