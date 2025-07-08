import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
// import 'package:social_share/social_share.dart'; //Balu
import 'package:sizer/sizer.dart';

import '../../../src.dart';

class SocialBanner extends ConsumerStatefulWidget {
  final String? id;
  final int? index;
  final String? whatsCount;
  final String? likes;
  final String? dislikes;
  final String? liked;
  final String? comments;
  final String? title;
  final String? image;
  final String? description;
  final String? layout;
  final bool? single;

  const SocialBanner({
    Key? key,
    required this.id,
    required this.index,
    required this.whatsCount,
    this.likes,
    this.dislikes,
    this.liked,
    this.comments,
    this.title,
    this.image,
    this.layout,
    this.single,
    this.description,
  }) : super(key: key);

  @override
  _SocialBannerState createState() => _SocialBannerState();
}

// class _SocialBannerState extends ConsumerState<SocialBanner> {
//   Box<String> box = Hive.box('user');
//
//   @override
//   Widget build(BuildContext context) {
//     // Check if widget.id, widget.likes, etc. are null and provide default values if necessary
//     final id = widget.id ?? ''; // Default to empty string if null
//     final likes = widget.likes ?? '0'; // Default to '0' if null
//     final dislikes = widget.dislikes ?? '0'; // Default to '0' if null
//     final comments = widget.comments ?? '0'; // Default to '0' if null
//     final whatsCount = widget.whatsCount ?? '0'; // Default to '0' if null
//     final title = widget.title ?? ''; // Default to empty string if null
//     final image = widget.image ?? ''; // Default to empty string if null
//     final description =
//         widget.description ?? ''; // Default to empty string if null
//     final liked = widget.liked ?? ''; // Default to empty string if null
//
//     return Container(
//       height: 5.5.h,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Like
//           // Like
//           InkWell(
//             onTap: () async {
//               if (box.containsKey('id') && box.get('id') != null) {
//                 widget.single!
//                     ? await ref
//                         .read(postIndividualControllerProvider.notifier)
//                         .likes(
//                           int.parse(widget.id!),
//                           'post',
//                           1,
//                           widget.index!,
//                         )
//                     : await ref
//                         .read(postPaginationControllerProvider.notifier)
//                         .likes(
//                           int.parse(widget.id!),
//                           'post',
//                           1,
//                           widget.index!,
//                         );
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text("You must Login to Like this Post"),
//                     action: SnackBarAction(
//                       onPressed: () {
//                         print('login');
//                       },
//                       label: 'Login',
//                     ),
//                   ),
//                 );
//               }
//             },
//             splashColor: Colors.transparent,
//             highlightColor: Colors.transparent,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       FontAwesomeIcons.thumbsUp,
//                       color: widget.liked == '1' ? Colors.blue : disabledColor,
//                       size: 12.sp,
//                     ),
//                     SizedBox(width: 5),
//                     Text(
//                       widget.likes != null && widget.likes != '0'
//                           ? NumberFormat('#,###')
//                               .format(int.parse(widget.likes!))
//                           : '',
//                       style: TextStyle(
//                         color:
//                             widget.liked == '1' ? Colors.blue : disabledColor,
//                         fontSize: 12.sp,
//                       ),
//                     )
//                   ],
//                 ),
//                 Text(
//                   'నచ్చింది',
//                   style: TextStyle(
//                     color: disabledColor,
//                     fontSize: 10.sp,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // DisLike
//           InkWell(
//             onTap: () async {
//               if (box.containsKey('id') && box.get('id') != null) {
//                 widget.single!
//                     ? await ref
//                         .read(postIndividualControllerProvider.notifier)
//                         .likes(int.parse(id), 'post', -1, widget.index!)
//                     : await ref
//                         .read(postPaginationControllerProvider.notifier)
//                         .likes(int.parse(id), 'post', -1, widget.index!);
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text("You must Login to Dislike this Post"),
//                     action: SnackBarAction(
//                       onPressed: () {
//                         print('login');
//                       },
//                       label: 'Login',
//                     ),
//                   ),
//                 );
//               }
//             },
//             splashColor: Colors.transparent,
//             highlightColor: Colors.transparent,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       FontAwesomeIcons.thumbsDown,
//                       color: liked == '-1' ? Colors.blue : disabledColor,
//                       size: 12.sp,
//                     ),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     Text(
//                       dislikes == '0'
//                           ? ''
//                           : NumberFormat('#,###').format(int.parse(dislikes)),
//                       style: TextStyle(
//                         color: dislikes == '1' ? Colors.blue : disabledColor,
//                         fontSize: 12.sp,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   'నచ్చలేదు',
//                   style: TextStyle(
//                     color: disabledColor,
//                     fontSize: 10.sp,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Comment
//           InkWell(
//             onTap: () {
//               ref.read(postid.notifier).state = id;
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => CommentsScreen(
//                     index: widget.index,
//                     single: widget.single!,
//                     id: id,
//                   ),
//                 ),
//               );
//             },
//             splashColor: Colors.transparent,
//             highlightColor: Colors.transparent,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       FontAwesomeIcons.commentDots,
//                       color: Colors.orangeAccent,
//                       size: 12.sp,
//                     ),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     Text(
//                       comments == '0'
//                           ? ''
//                           : NumberFormat('#,###').format(int.parse(comments)),
//                       style: TextStyle(
//                         color: comments == '1' ? Colors.blue : disabledColor,
//                         fontSize: 12.sp,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   'వ్యాఖ్యలు',
//                   style: TextStyle(
//                     color: disabledColor,
//                     fontSize: 10.sp,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // WhatsApp
//           InkWell(
//             onTap: () async {
//               widget.single!
//                   ? await ref
//                       .read(postIndividualControllerProvider.notifier)
//                       .whatsShare(id, whatsCount, widget.index!)
//                   : await ref
//                       .read(postPaginationControllerProvider.notifier)
//                       .whatsShare(id, whatsCount, widget.index!);
//
//               // firebaseDynamicLink(id, image, title, description)
//               //     .then((value) => SocialShare.shareWhatsapp(value));   //Balu
//             },
//             splashColor: Colors.transparent,
//             highlightColor: Colors.transparent,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       FontAwesomeIcons.whatsapp,
//                       color: Colors.green,
//                       size: 12.sp,
//                     ),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     Text(
//                       whatsCount == '0'
//                           ? ''
//                           : NumberFormat('#,###').format(int.parse(whatsCount)),
//                       style: TextStyle(
//                         color: whatsCount == '1' ? Colors.blue : disabledColor,
//                         fontSize: 12.sp,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   'వాట్సాప్',
//                   style: TextStyle(
//                     color: disabledColor,
//                     fontSize: 10.sp,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // More
//           Row(
//             children: [
//               Icon(
//                 FontAwesomeIcons.ellipsisV,
//                 color: Colors.grey,
//                 size: 12.sp,
//               ),
//               SizedBox(
//                 width: 5,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
class _SocialBannerState extends ConsumerState<SocialBanner> {
  Box<String> box = Hive.box('user');

  @override
  Widget build(BuildContext context) {
    final id = widget.id ?? '';
    final likes = widget.likes ?? '0';
    final dislikes = widget.dislikes ?? '0';
    final comments = widget.comments ?? '0';
    final whatsCount = widget.whatsCount ?? '0';
    final title = widget.title ?? '';
    final image = widget.image ?? '';
    final description = widget.description ?? '';
    final liked = widget.liked ?? '';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIconText(
              icon: FontAwesomeIcons.thumbsUp,
              label: 'నచ్చింది',
              count: likes,
              isActive: liked == '1',
              color: Colors.blue,
              onTap: () => _handleLikeDislike(1),
            ),
            _buildIconText(
              icon: FontAwesomeIcons.thumbsDown,
              label: 'నచ్చలేదు',
              count: dislikes,
              isActive: liked == '-1',
              color: Colors.blue,
              onTap: () => _handleLikeDislike(-1),
            ),
            _buildIconText(
              icon: FontAwesomeIcons.commentDots,
              label: 'వ్యాఖ్యలు',
              count: comments,
              isActive: false,
              color: Colors.orangeAccent,
              onTap: () {
                ref.read(postid.notifier).state = id;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommentsScreen(
                      index: widget.index,
                      single: widget.single!,
                      id: id,
                    ),
                  ),
                );
              },
            ),
            _buildIconText(
              icon: FontAwesomeIcons.whatsapp,
              label: 'WhatsApp',
              // label: 'వాట్సాప్',
              count: whatsCount,
              isActive: false,
              color: Colors.green,
              onTap: () async {
                widget.single!
                    ? await ref
                        .read(postIndividualControllerProvider.notifier)
                        .whatsShare(id, whatsCount, widget.index!)
                    : await ref
                        .read(postPaginationControllerProvider.notifier)
                        .whatsShare(id, whatsCount, widget.index!);
              },
            ),
            Icon(
              FontAwesomeIcons.ellipsisV,
              size: 16.sp,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconText({
    required IconData icon,
    required String label,
    required String count,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: isActive ? color : disabledColor,
          ),
          SizedBox(width: 4),
          if (count != '0')
            Text(
              NumberFormat('#,###').format(int.parse(count)),
              style: TextStyle(
                fontSize: 11.sp,
                color: isActive ? color : disabledColor,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleLikeDislike(int value) async {
    if (box.containsKey('id') && box.get('id') != null) {
      if (widget.single!) {
        await ref
            .read(postIndividualControllerProvider.notifier)
            .likes(int.parse(widget.id!), 'post', value, widget.index!);
      } else {
        await ref
            .read(postPaginationControllerProvider.notifier)
            .likes(int.parse(widget.id!), 'post', value, widget.index!);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "You must Login to ${value == 1 ? 'Like' : 'Dislike'} this Post"),
          action: SnackBarAction(
            label: 'Login',
            onPressed: () {
              // Handle login navigation
            },
          ),
        ),
      );
    }
  }
}
