import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:hashtagable/hashtagable.dart';  //Balu
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:numeral/numeral.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';

import '../../../src.dart';

class ReplyCommentsScreen extends ConsumerStatefulWidget {
  final String? userId;
  final String? imageUrl;
  final String? name;
  final String? date;
  final String? commentData;
  final int? commentIndex;
  final int? index;
  final int? id;
  const ReplyCommentsScreen({
    Key? key,
    @required this.userId,
    @required this.imageUrl,
    @required this.name,
    @required this.date,
    this.commentIndex,
    @required this.commentData,
    @required this.index,
    @required this.id,
  }) : super(key: key);

  @override
  _ReplyCommentsScreenState createState() => _ReplyCommentsScreenState();
}

class _ReplyCommentsScreenState extends ConsumerState<ReplyCommentsScreen> {
  Box<String> box = Hive.box('user');

  _loadMore() {
    ref.read(replyCommentsPaginationControllerProvider.notifier).getComments();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(replyCommentsPaginationControllerProvider);
    final commentsState =
        ref.watch(replyCommentsPaginationControllerProvider.notifier).state;
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          splashColor: Colors.transparent,
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.chevron_left_rounded,
            color: Colors.black,
          ),
        ),
        elevation: 0.5,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: LazyLoadScrollView(
          onEndOfPage: _loadMore,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.8),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 5,
                          bottom: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 4.h,
                                  width: 4.h,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        widget.imageUrl!,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: widget.name!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 10.sp,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '  ·  ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black,
                                          fontSize: 10.sp,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                      TextSpan(
                                        text: widget.date!,
                                        style: TextStyle(
                                          color: disabledColor,
                                          fontSize: 10.sp,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Report!',
                                      ),
                                      content: Text(
                                        'Do you want to report this as spam?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            DatabaseService()
                                                .report(widget.id.toString(),
                                                    'comment')
                                                .then((value) {
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text("Reported"),
                                                ),
                                              );
                                            });
                                          },
                                          child: Text('Yes'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('No'),
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(
                                FontAwesomeIcons.flag,
                                size: 9.sp,
                                color: disabledColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        child: ReadMoreText(
                          widget.commentData!,
                          trimLines: 3,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: 'more',
                          trimExpandedText: 'less',
                          moreStyle: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          lessStyle: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              if (box.containsKey('id') &&
                                  box.get('id') != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewCommentScreen(
                                      index: widget.index!,
                                      commentId: widget.id!.toString(),
                                      commentIndex: widget.commentIndex!,
                                      commentType: 'reply',
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("You must Login..."),
                                    action: SnackBarAction(
                                      onPressed: () {
                                        print('login');
                                      },
                                      label: 'Login',
                                    ),
                                  ),
                                );
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(0),
                            ),
                            child: Text(
                              'Reply',
                              style: TextStyle(
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Builder(
                  builder: (context) {
                    if (commentsState.refreshError) {
                      return ErrorBody(
                        message: commentsState.errorMessage,
                      );
                    } else if (commentsState.comments!.isEmpty) {
                      return DelayedDisplay(
                        // delay: Duration(seconds: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.comment,
                              size: 30,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text('Fetching Comments'),
                          ],
                        ),
                      );
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: commentsState.comments!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 4.h,
                                            width: 4.h,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  commentsState.comments![index]
                                                      .userImage!,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: commentsState
                                                      .comments![index]
                                                      .username!,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                    fontSize: 10.sp,
                                                    letterSpacing: 0.1,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '  ·  ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.black,
                                                    fontSize: 10.sp,
                                                    letterSpacing: 0.1,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: commentsState
                                                      .comments![index]
                                                      .commentDate!,
                                                  style: TextStyle(
                                                    color: disabledColor,
                                                    fontSize: 10.sp,
                                                    letterSpacing: 0.1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                  'Report!',
                                                ),
                                                content: Text(
                                                  'Do you want to report this as spam?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      DatabaseService()
                                                          .report(
                                                              commentsState
                                                                  .comments![
                                                                      index]
                                                                  .id!,
                                                              'comment')
                                                          .then((value) {
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                                "Reported"),
                                                          ),
                                                        );
                                                      });
                                                    },
                                                    child: Text('Yes'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('No'),
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        icon: Icon(
                                          FontAwesomeIcons.flag,
                                          size: 9.sp,
                                          color: disabledColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.symmetric(
                                //     horizontal: 20,
                                //   ),
                                //   child: HashTagText(
                                //     text: commentsState
                                //         .comments![index].commentData!,
                                //     decoratedStyle: TextStyle(
                                //       fontSize: 11.5.sp,
                                //       color: Colors.blue,
                                //       letterSpacing: 0.5,
                                //     ),
                                //     basicStyle: TextStyle(
                                //       fontSize: 11.5.sp,
                                //       color: Colors.black87,
                                //       letterSpacing: 0.5,
                                //     ),
                                //     decorateAtSign: true,
                                //   ),
                                // ),  //Balu
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          // Like Button
                                          IconButton(
                                            onPressed: () async {
                                              if (box.containsKey('id') &&
                                                  box.get('id') != null) {
                                                await ref
                                                    .read(
                                                        replyCommentsPaginationControllerProvider
                                                            .notifier)
                                                    .likes(
                                                      int.parse(commentsState
                                                          .comments![index]
                                                          .id!),
                                                      'comment',
                                                      1,
                                                      index,
                                                      -1,
                                                    );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "You must Login to Like this Post"),
                                                    action: SnackBarAction(
                                                      onPressed: () {
                                                        print('login');
                                                      },
                                                      label: 'Login',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            padding: EdgeInsets.all(0),
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            icon: Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.thumbsUp,
                                                  color: commentsState
                                                              .comments![index]
                                                              .liked ==
                                                          '1'
                                                      ? Colors.blue
                                                      : disabledColor,
                                                  size: 11.sp,
                                                ),
                                                SizedBox(
                                                  width: 3,
                                                ),
                                                // Text(
                                                //   commentsState.comments![index]
                                                //               .likes! ==
                                                //           '0'
                                                //       ? ''
                                                //       : Numeral(int.parse(
                                                //               commentsState
                                                //                   .comments![
                                                //                       index]
                                                //                   .likes!))
                                                //           .value(),
                                                //   style: TextStyle(
                                                //     color: commentsState
                                                //                 .comments![
                                                //                     index]
                                                //                 .liked ==
                                                //             '1'
                                                //         ? Colors.blue
                                                //         : disabledColor,
                                                //     fontSize: 11.5.sp,
                                                //   ),
                                                // ),  // Balu
                                              ],
                                            ),
                                          ),
                                          // Dislike Button
                                          IconButton(
                                            onPressed: () async {
                                              if (box.containsKey('id') &&
                                                  box.get('id') != null) {
                                                await ref
                                                    .read(
                                                        replyCommentsPaginationControllerProvider
                                                            .notifier)
                                                    .likes(
                                                      int.parse(commentsState
                                                          .comments![index]
                                                          .id!),
                                                      'comment',
                                                      -1,
                                                      index,
                                                      -1,
                                                    );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "You must Login to Like this Post"),
                                                    action: SnackBarAction(
                                                      onPressed: () {
                                                        print('login');
                                                      },
                                                      label: 'Login',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            padding: EdgeInsets.all(0),
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            icon: Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.thumbsDown,
                                                  color: commentsState
                                                              .comments![index]
                                                              .liked ==
                                                          '-1'
                                                      ? Colors.blue
                                                      : disabledColor,
                                                  size: 11.sp,
                                                ),
                                                SizedBox(
                                                  width: 3,
                                                ),
                                                // Text(
                                                //   commentsState.comments![index]
                                                //               .dislikes! ==
                                                //           '0'
                                                //       ? ''
                                                //       : Numeral(int.parse(
                                                //               commentsState
                                                //                   .comments![
                                                //                       index]
                                                //                   .dislikes!))
                                                //           .value(),
                                                //   style: TextStyle(
                                                //     color: commentsState
                                                //                 .comments![
                                                //                     index]
                                                //                 .liked ==
                                                //             '-1'
                                                //         ? Colors.blue
                                                //         : disabledColor,
                                                //     fontSize: 11.5.sp,
                                                //   ),
                                                // ),  //Balu
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (box.containsKey('id') &&
                                              box.get('id') != null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    NewCommentScreen(
                                                  index: widget.index!,
                                                  commentId:
                                                      widget.id!.toString(),
                                                  commentIndex:
                                                      widget.commentIndex!,
                                                  commentType: 'replyreply',
                                                  replyUserName: box
                                                              .get('id') ==
                                                          commentsState
                                                              .comments![index]
                                                              .userId!
                                                      ? ''
                                                      : commentsState
                                                          .comments![index]
                                                          .username!,
                                                  replyUserId: box.get('id') ==
                                                          commentsState
                                                              .comments![index]
                                                              .userId!
                                                      ? '0'
                                                      : commentsState
                                                          .comments![index]
                                                          .userId!,
                                                ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content:
                                                    Text("You must Login..."),
                                                action: SnackBarAction(
                                                  onPressed: () {
                                                    print('login');
                                                  },
                                                  label: 'Login',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.all(0),
                                        ),
                                        child: Text(
                                          'Reply',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                index == commentsState.comments!.length - 1
                                    ? SizedBox.shrink()
                                    : Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Divider(
                                          indent: 30,
                                          endIndent: 30,
                                        ),
                                      ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
