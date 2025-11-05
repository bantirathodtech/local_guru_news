import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

// Token
Future<String> firebaseToken() async {
  await Firebase.initializeApp();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? token = await _firebaseMessaging.getToken();

  return token!;
}

// Dynamic Links
Future<String> firebaseDynamicLink(
  String id,
  String image,
  String title,
  String description,
) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: 'https://localguru.page.link',
    link: Uri.parse('https://localguru.in/_api/news/postById_api.php?$id'),
    androidParameters: AndroidParameters(
      packageName: 'com.local.guru',
      minimumVersion: 0,
    ),
    socialMetaTagParameters: SocialMetaTagParameters(
      title: title,
      description: description,
      imageUrl: Uri.parse(image),
    ),
  );

  final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
  final Uri shortUrl = shortDynamicLink.shortUrl;

  return shortUrl.toString();
}

extension on DynamicLinkParameters {
  buildShortLink() {}
}  // Balu
