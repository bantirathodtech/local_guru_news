import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:numeral/numeral.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';

import '../../../src.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final int? index;
  final bool? single;
  final String? id;
  const CommentsScreen({
    Key? key,
    @required this.index,
    required this.single,
    required this.id,
  }) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  Box<String> box = Hive.box('user');

  _loadMore() {
    ref.read(commentsPaginationControllerProvider.notifier).getComments();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(commentsPaginationControllerProvider);
    final commentsState =
        ref.watch(commentsPaginationControllerProvider.notifier).state;
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.chevron_left,
            color: Colors.black,
          ),
        ),
        title: Text(
          'Comments',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15.sp,
          ),
        ),
        elevation: 0.8,
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
        ),
        height: 55,
        decoration: BoxDecoration(
          border: Border(
              // top: BorderSide(width: 0.09),
              ),
        ),
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            if (box.containsKey('id') && box.get('id') != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewCommentScreen(
                    index: widget.index,
                    postId: widget.id,
                    commentType: 'new',
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
          child: Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.only(
              left: 20,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.12),
              // border: Border.all(
              //   width: 0.4,
              // ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              'Enter Comment . . .',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.9),
                fontSize: 10.sp,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Builder(
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
                      size: 15.sp,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Fetching Comments',
                      style: TextStyle(
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return LazyLoadScrollView(
                onEndOfPage: _loadMore,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: commentsState.comments!.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                          commentsState
                                              .comments![index].userImage!,
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
                                              .comments![index].username!,
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
                                              .comments![index].commentDate!,
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
                                                          .comments![index].id!,
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
                          ),
                          child: ReadMoreText(
                            commentsState.comments![index].commentData!,
                            trimLines: 5,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  commentsState.comments![index].replyCount ==
                                          '0'
                                      ? SizedBox.shrink()
                                      : Container(
                                          height: 16,
                                          child: TextButton(
                                            onPressed: () {
                                              ref
                                                      .read(commentId.notifier)
                                                      .state =
                                                  commentsState
                                                      .comments![index].id!;
                                              ref
                                                  .read(commentPostId.notifier)
                                                  .state = widget.id!;
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ReplyCommentsScreen(
                                                    userId: commentsState
                                                        .comments![index]
                                                        .userId,
                                                    imageUrl: commentsState
                                                        .comments![index]
                                                        .userImage,
                                                    name: commentsState
                                                        .comments![index]
                                                        .username,
                                                    date: commentsState
                                                        .comments![index]
                                                        .commentDate,
                                                    commentIndex: index,
                                                    commentData: commentsState
                                                        .comments![index]
                                                        .commentData,
                                                    id: int.parse(commentsState
                                                        .comments![index].id!),
                                                    index: index,
                                                  ),
                                                ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.all(0),
                                            ),
                                            child: Text("text"), //Balu
                                            // child: Text(
                                            //   '${Numeral(int.parse(commentsState.comments![index].replyCount!))} Replies',
                                            //   style: TextStyle(
                                            //     color: Colors.blue,
                                            //     fontSize: 10.sp,
                                            //   ),
                                            // ), //Balu
                                          ),
                                        ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  // Like Button
                                  IconButton(
                                    onPressed: () async {
                                      if (box.containsKey('id') &&
                                          box.get('id') != null) {
                                        await ref
                                            .read(
                                                commentsPaginationControllerProvider
                                                    .notifier)
                                            .likes(
                                              int.parse(commentsState
                                                  .comments![index].id!),
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
                                                      .comments![index].liked ==
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
                                        //       : Numeral(int.parse(commentsState
                                        //               .comments![index].likes!))
                                        //           .value(),
                                        //   style: TextStyle(
                                        //     color: commentsState
                                        //                 .comments![index]
                                        //                 .liked ==
                                        //             '1'
                                        //         ? Colors.blue
                                        //         : disabledColor,
                                        //     fontSize: 11.5.sp,
                                        //   ),
                                        // ),  //Balu
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
                                                commentsPaginationControllerProvider
                                                    .notifier)
                                            .likes(
                                              int.parse(commentsState
                                                  .comments![index].id!),
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
                                                      .comments![index].liked ==
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
                                        //       : Numeral(int.parse(commentsState
                                        //               .comments![index]
                                        //               .dislikes!))
                                        //           .value(),
                                        //   style: TextStyle(
                                        //     color: commentsState
                                        //                 .comments![index]
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
                                    ref.read(commentId.notifier).state =
                                        commentsState.comments![index].id!;
                                    ref.read(commentPostId.notifier).state =
                                        widget.id!;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NewCommentScreen(
                                          index: widget.index!,
                                          commentId: commentsState
                                              .comments![index].id!,
                                          commentIndex: index,
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
                            ],
                          ),
                        ),
                        index == commentsState.comments!.length - 1
                            ? SizedBox.shrink()
                            : Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                ),
                                child: Divider(
                                  indent: 30,
                                  endIndent: 30,
                                ),
                              ),
                      ],
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
