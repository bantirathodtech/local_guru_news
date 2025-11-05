import 'dart:developer' as developer;

import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:sizer/sizer.dart';

import '../../src.dart';

class DashBoardScreen extends ConsumerStatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends ConsumerState<DashBoardScreen> {
  Box<String> box = Hive.box('user');
  int _currentIndex = 0;
  PersistentTabController? _controller;

  final List<Widget> _tabs = [
    NewsDashboard(),
    JobComing(),
    ListingComing(),
    GreetingsDashboard(),
  ];

  @override
  void initState() {
    super.initState();
    // Clamp initial index to valid range (0 to _tabs.length - 1)
    final initialIndex = ref
        .read(currentIndexProvider.notifier)
        .state
        .clamp(0, _tabs.length - 1);
    _currentIndex = initialIndex;
    _controller = PersistentTabController(initialIndex: initialIndex);
    ref.read(currentIndexProvider.notifier).state = initialIndex;
    developer.log(
        'Initialized DashBoardScreen with _currentIndex: $_currentIndex, tabs length: ${_tabs.length}');

    initDynamicLinks();

    // From Terminated state Notification
    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null) {
        final type = message.data['type'];
        final id = message.data['id'];
        developer.log('Received initial message: type=$type, id=$id');
        if (type == "post" && id != null) {
          try {
            DatabaseService.updateViewCount(id);
            ref.read(deepLinkPostId.notifier).state = int.parse(id);
            await ref
                .refresh(postIndividualControllerProvider.notifier)
                .getPosts()
                .then((value) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SinglePostView()),
                (route) => false,
              );
            });
          } catch (e) {
            developer.log('Error handling initial message: $e');
          }
        }
      }
    });

    // ForeGround Notification
    FirebaseMessaging.onMessage.listen((message) {
      developer.log('Received foreground message: ${message.data}');
      NotificationService.display(message);
    });

    // BackGround state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      developer.log('Received background message: ${message.data}');
      if (message.data.isNotEmpty) {
        final type = message.data['type'];
        final id = message.data['id'];
        if (type == "post" && id != null) {
          try {
            DatabaseService.updateViewCount(id);
            ref.read(deepLinkPostId.notifier).state = int.parse(id);
            await ref
                .refresh(postIndividualControllerProvider.notifier)
                .getPosts()
                .then((value) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SinglePostView()),
                (route) => false,
              );
            });
          } catch (e) {
            developer.log('Error handling background message: $e');
          }
        }
      }
    });
  }

  Future<void> initDynamicLinks() async {
    try {
      final PendingDynamicLinkData? data =
          await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri? deepLink = data?.link;

      if (deepLink != null) {
        final id = deepLink.queryParameters['id'] ??
            deepLink.toString().split('?').last;
        developer.log('Received dynamic link with id: $id');
        if (id.isNotEmpty) {
          try {
            DatabaseService.updateViewCount(id);
            ref.read(deepLinkPostId.notifier).state = int.parse(id);
            await ref
                .refresh(postIndividualControllerProvider.notifier)
                .getPosts()
                .then((value) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SinglePostView()),
                (route) => false,
              );
            });
          } catch (e) {
            developer.log('Error handling dynamic link: $e');
          }
        }
      }

      FirebaseDynamicLinks.instance.onLink
          .listen((PendingDynamicLinkData? dynamicLink) {
        final Uri? deepLink = dynamicLink?.link;
        if (deepLink != null) {
          final id = deepLink.queryParameters['id'] ??
              deepLink.toString().split('?').last;
          developer.log('Received dynamic link (onLink): $id');
          if (id.isNotEmpty) {
            try {
              DatabaseService.updateViewCount(id);
              ref.read(deepLinkPostId.notifier).state = int.parse(id);
              ref
                  .refresh(postIndividualControllerProvider.notifier)
                  .getPosts()
                  .then((value) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SinglePostView()),
                  (route) => false,
                );
              });
            } catch (e) {
              developer.log('Error handling dynamic link (onLink): $e');
            }
          }
        }
      }).onError((error) {
        developer.log('Dynamic link error: $error');
      });
    } catch (e) {
      developer.log('Error initializing dynamic links: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch currentIndexProvider to respond to drawer tab changes
    final providerIndex = ref.watch(currentIndexProvider);

    // Sync local state with provider if different
    if (providerIndex != _currentIndex &&
        providerIndex >= 0 &&
        providerIndex < _tabs.length) {
      _currentIndex = providerIndex;
      _controller?.jumpToTab(providerIndex);
      developer.log('Tab changed to index: $providerIndex from drawer');
    }

    // Validate _currentIndex before accessing _tabs
    if (_currentIndex < 0 || _currentIndex >= _tabs.length) {
      developer.log(
          'Invalid _currentIndex detected: $_currentIndex, resetting to 0');
      _currentIndex = 0;
      ref.read(currentIndexProvider.notifier).state = 0;
      _controller?.jumpToTab(0);
    }

    return Scaffold(
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(
          content: Text('Tap back again to Close App'),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _tabs[_currentIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline, // Underline for selected label
          decorationColor: Colors.black, // Black underline color
          decorationThickness: 2, // Thickness for underline
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          decoration: TextDecoration.none, // No underline for unselected label
        ),
        onTap: (index) {
          if (index >= 0 && index < _tabs.length) {
            setState(() {
              _currentIndex = index;
              ref.read(currentIndexProvider.notifier).state = index;
              _controller?.jumpToTab(index);
            });
            developer.log('Tab changed to index: $index');
          } else {
            developer.log('Attempted to select invalid tab index: $index');
          }
        },
        items: List.generate(_tabs.length, (index) {
          final baseSize = 24.0;
          final iconSize = _currentIndex == index ? 36.0 : baseSize;

          const icons = [
            'assets/icons/tabs/news.svg',
            'assets/icons/tabs/job.svg',
            'assets/icons/tabs/listing.svg',
            'assets/icons/tabs/greeting.svg',
          ];
          const labels = [
            "News",
            "Jobs",
            "Listings",
            "Greetings",
          ];

          return BottomNavigationBarItem(
            icon: SvgPicture.asset(
              icons[index],
              width: iconSize,
              height: iconSize,
            ),
            label: labels[index],
          );
        }),
      ),
    );
  }
}
