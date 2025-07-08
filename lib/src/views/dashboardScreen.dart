import 'dart:developer' as developer;

import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:sizer/sizer.dart';

import '../src.dart';

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
    ComingSoon(),
    ComingSoon(),
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
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.blueGrey,
        selectedLabelStyle:
            TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 10.sp),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.solidNewspaper),
            label: "News",
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.briefcase),
            label: "Jobs",
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.solidListAlt),
            label: "Listings",
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.grinBeam),
            label: "Greetings",
          ),
        ],
      ),
    );
  }
}

// import 'package:double_back_to_close_app/double_back_to_close_app.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
// import 'package:sizer/sizer.dart';
//
// // import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
//
// import '../src.dart';
//
// class DashBoardScreen extends ConsumerStatefulWidget {
//   const DashBoardScreen({Key? key}) : super(key: key);
//
//   @override
//   _DashBoardScreenState createState() => _DashBoardScreenState();
// }
//
// class _DashBoardScreenState extends ConsumerState<DashBoardScreen> {
//   Box<String> box = Hive.box('user');
//   int _currentIndex = 0;
//
//   PersistentTabController? _controller;
//   @override
//   void initState() {
//     super.initState();
//     _controller = PersistentTabController(
//         initialIndex: ref.read(currentIndexProvider.notifier).state);
//     initDynamicLinks();
//
//     // NotificationService.initialize(context, ref); //Balu
//
//     // From Terminated state Notification
//     FirebaseMessaging.instance.getInitialMessage().then(
//       (message) async {
//         if (message != null) {
//           final type = message.data['type'];
//           final id = message.data['id'];
//
//           switch (type) {
//             case "post":
//               DatabaseService.updateViewCount(id);
//               ref.read(deepLinkPostId.notifier).state = int.parse(id);
//               await ref
//                   .refresh(postIndividualControllerProvider.notifier)
//                   .getPosts()
//                   .then((value) {
//                 Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (context) => SinglePostView()),
//                     (route) => false);
//               });
//               break;
//           }
//         }
//       },
//     );
//
//     // ForeGround Notification
//     FirebaseMessaging.onMessage.listen((message) {
//       NotificationService.display(message);
//     });
//
//     // BackGround state
//     FirebaseMessaging.onMessageOpenedApp.listen(
//       (RemoteMessage message) async {
//         if (message.data.isNotEmpty) {
//           final type = message.data['type'];
//           final id = message.data['id'];
//
//           switch (type) {
//             case "post":
//               DatabaseService.updateViewCount(id);
//               ref.read(deepLinkPostId.notifier).state = int.parse(id);
//               await ref
//                   .refresh(postIndividualControllerProvider.notifier)
//                   .getPosts()
//                   .then((value) {
//                 Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (context) => SinglePostView()),
//                     (route) => false);
//               });
//               break;
//           }
//         }
//       },
//     );
//   }
//
//   Future<void> initDynamicLinks() async {
//     FirebaseDynamicLinks.instance.onLink;
//
//     final PendingDynamicLinkData? data =
//         await FirebaseDynamicLinks.instance.getInitialLink();
//     final Uri? deepLink = data?.link;
//
//     if (deepLink != null) {
//       // ignore: unawaited_futures
//       String id = deepLink.toString().split('?').last;
//       DatabaseService.updateViewCount(id);
//       ref.read(deepLinkPostId.notifier).state = int.parse(id);
//       await ref
//           .refresh(postIndividualControllerProvider.notifier)
//           .getPosts()
//           .then((value) {
//         Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (context) => SinglePostView()),
//             (route) => false);
//       });
//     }
//   } //Balu
//
//   // Future<void> initDynamicLinks() async {
//   //   FirebaseDynamicLinks.instance.onLink(
//   //       onSuccess: (PendingDynamicLinkData? dynamicLink) async {
//   //         final Uri? deepLink = dynamicLink?.link;
//   //
//   //         if (deepLink != null) {
//   //           // ignore: unawaited_futures
//   //           String id = deepLink.toString().split('?').last;
//   //           DatabaseService.updateViewCount(id);
//   //           ref.read(deepLinkPostId.notifier).state = int.parse(id);
//   //           await ref
//   //               .refresh(postIndividualControllerProvider.notifier)
//   //               .getPosts()
//   //               .then((value) {
//   //             Navigator.pushAndRemoveUntil(
//   //                 context,
//   //                 MaterialPageRoute(builder: (context) => SinglePostView()),
//   //                     (route) => false);
//   //           });
//   //         }
//   //       }, onError: (OnLinkErrorException e) async {
//   //     print('onLinkError');
//   //     print(e.message);
//   //   });
//   //
//   //   final PendingDynamicLinkData? data =
//   //   await FirebaseDynamicLinks.instance.getInitialLink();
//   //   final Uri? deepLink = data?.link;
//   //
//   //   if (deepLink != null) {
//   //     // ignore: unawaited_futures
//   //     String id = deepLink.toString().split('?').last;
//   //     DatabaseService.updateViewCount(id);
//   //     ref.read(deepLinkPostId.notifier).state = int.parse(id);
//   //     await ref
//   //         .refresh(postIndividualControllerProvider.notifier)
//   //         .getPosts()
//   //         .then((value) {
//   //       Navigator.pushAndRemoveUntil(
//   //           context,
//   //           MaterialPageRoute(builder: (context) => SinglePostView()),
//   //               (route) => false);
//   //     });
//   //   }
//   // }
//
//   final List<Widget> _tabs = [
//     NewsDashboard(),
//     ComingSoon(),
//     // JobsDashboard(),
//     // Container(
//     //   child: Text('Deals'),
//     // ),
//     ComingSoon(), // ListsDashboard(),
//     GreetingsDashboard(),
//   ];
// //Updated by Banti
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: DoubleBackToCloseApp(
//         snackBar: const SnackBar(
//           content: Text('Tap back again to Close App'),
//         ),
//         child: _tabs[_currentIndex],
//         // child: AnimatedSwitcher(
//         //   duration: const Duration(milliseconds: 300),
//         //   child: _tabs[_currentIndex],
//         // ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.white,
//         selectedItemColor: Colors.red,
//         unselectedItemColor: Colors.blueGrey,
//         selectedLabelStyle:
//             TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
//         unselectedLabelStyle: TextStyle(fontSize: 10.sp),
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//             ref.read(currentIndexProvider.notifier).state = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(FontAwesomeIcons.solidNewspaper),
//             label: "News",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(FontAwesomeIcons.briefcase),
//             label: "jobs",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(FontAwesomeIcons.solidListAlt),
//             label: "Listings",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(FontAwesomeIcons.grinBeam),
//             label: "Greetings",
//           ),
//         ],
//       ),
//     );
//   }
//
//   // @override
//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //     body: DoubleBackToCloseApp(
//   //       snackBar: SnackBar(
//   //         content: Text('Tap back again to Close App'),
//   //       ),
//   //       child: PersistentTabView(
//   //         context,
//   //         screens: _tabs,
//   //         controller: _controller,
//   //         navBarStyle: NavBarStyle.style6,
//   //         decoration: NavBarDecoration(
//   //           border: Border(
//   //             top: BorderSide(
//   //               color: Colors.grey,
//   //               width: 1,
//   //             ),
//   //           ),
//   //         ),
//   //         // hideNavigationBar:
//   //         //     ref.watch(currentIndexProvider) == -1 ? true : false, //Balu
//   //         items: [
//   //           PersistentBottomNavBarItem(
//   //             icon: Icon(FontAwesomeIcons.solidNewspaper),
//   //             title: "వార్తలు",
//   //             activeColorPrimary: Colors.red,
//   //             inactiveColorPrimary: Colors.blueGrey,
//   //           ),
//   //           PersistentBottomNavBarItem(
//   //             icon: Icon(FontAwesomeIcons.briefcase),
//   //             title: "ఉద్యోగాలు",
//   //             activeColorPrimary: Colors.red,
//   //             inactiveColorPrimary: Colors.blueGrey,
//   //           ),
//   //           // PersistentBottomNavBarItem(
//   //           //   icon: Icon(FontAwesomeIcons.solidHandshake),
//   //           //   title: "Deals",
//   //           //   activeColorPrimary: Colors.red,
//   //           //   inactiveColorPrimary: Colors.blueGrey,
//   //           // ),
//   //           PersistentBottomNavBarItem(
//   //             icon: Icon(FontAwesomeIcons.solidListAlt),
//   //             title: "Listings",
//   //             activeColorPrimary: Colors.red,
//   //             inactiveColorPrimary: Colors.blueGrey,
//   //           ),
//   //           PersistentBottomNavBarItem(
//   //             icon: Icon(FontAwesomeIcons.grinBeam),
//   //             title: "Greetings",
//   //             activeColorPrimary: Colors.red,
//   //             inactiveColorPrimary: Colors.blueGrey,
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   //
//   //
//   //   // return Consumer(
//   //   //   builder: (context, watch, child) => Scaffold(
//   //   //     body: _tabs[watch(currentIndexProvider).state],
//   //   //     bottomNavigationBar: BottomNavigationBar(
//   //   //       currentIndex: watch(currentIndexProvider).state,
//   //   //       type: BottomNavigationBarType.fixed,
//   //   //       // backgroundColor: primaryColor,
//   //   //       backgroundColor: Colors.white,
//   //   //       selectedItemColor: Colors.red,
//   //   //       unselectedItemColor: Colors.blueGrey,
//   //   //       onTap: onTabTapped,
//   //   //       items: [
//   //   //         BottomNavigationBarItem(
//   //   //           icon: Icon(FontAwesomeIcons.solidNewspaper),
//   //   //           label: "వార్తలు",
//   //   //         ),
//   //   //         BottomNavigationBarItem(
//   //   //           icon: Icon(FontAwesomeIcons.briefcase),
//   //   //           label: "ఉద్యోగాలు",
//   //   //         ),
//   //   //         BottomNavigationBarItem(
//   //   //           icon: Icon(FontAwesomeIcons.solidHandshake),
//   //   //           label: "Deals",
//   //   //         ),
//   //   //         BottomNavigationBarItem(
//   //   //           icon: Icon(FontAwesomeIcons.solidListAlt),
//   //   //           label: "Listings",
//   //   //         ),
//   //   //         BottomNavigationBarItem(
//   //   //           icon: Icon(FontAwesomeIcons.grinBeam),
//   //   //           label: "Greetings",
//   //   //         ),
//   //   //       ],
//   //   //     ),
//   //   //   ),
//   //   // );
//   // }
//
//   void onTabTapped(int index) {
//     setState(() {
//       ref.read(currentIndexProvider.notifier).state = index;
//     });
//   }
//
//   // void initDynamicLinks() {}
// }
