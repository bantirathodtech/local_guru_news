import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../src.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // static void initialize(BuildContext context, WidgetRef ref) {
  //   final InitializationSettings initializationSettings =
  //       InitializationSettings(
  //           android: AndroidInitializationSettings("@mipmap/ic_launcher"));
  //
  //   _notificationsPlugin.initialize(initializationSettings,
  //       onSelectNotification: (String? data) async {
  //     String response = data!;
  //     Map<String, dynamic> result = jsonDecode(response);
  //
  //     if (data.isNotEmpty) {
  //       final type = result['type'];
  //       final id = result['id'];
  //
  //       switch (type) {
  //         case "post":
  //           DatabaseService.updateViewCount(id);
  //           ref.read(deepLinkPostId.notifier).state = int.parse(id);
  //           await ref
  //               .refresh(postIndividualControllerProvider.notifier)
  //               .getPosts()
  //               .then((value) {
  //             Navigator.pushAndRemoveUntil(
  //                 context,
  //                 MaterialPageRoute(builder: (context) => SinglePostView()),
  //                 (route) => false);
  //           });
  //           break;
  //       }
  //     }
  //   }
  //   );
  // } ////// Balu





  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
        "news_app",
        "News App",
        // "News App",
        importance: Importance.max,
        priority: Priority.high,
      ));

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload:
            '{"type":"${message.data["type"]}","id":"${message.data["id"]}"}',
      );
    } on Exception catch (e) {
      print(e);
    }
  }
}
