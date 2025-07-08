import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hashtagable/hashtagable.dart';//Balu
import '../../../src.dart';

class NewCommentScreen extends ConsumerStatefulWidget {
  final int? index;
  final int? commentIndex;
  final String? postId;
  final String? commentId;
  final String? replyUserId;
  final String? replyUserName;
  final String? commentType;
  const NewCommentScreen({
    Key? key,
    this.index,
    this.commentIndex,
    this.postId,
    this.commentId,
    this.replyUserId,
    this.replyUserName,
    this.commentType,
  }) : super(key: key);

  @override
  _NewCommentScreenState createState() => _NewCommentScreenState();
}

class _NewCommentScreenState extends ConsumerState<NewCommentScreen> {
  TextEditingController _message = TextEditingController();

  @override
  void initState() {
    super.initState();
    print(widget.replyUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.chevron_left_rounded,
            color: Colors.black,
          ),
        ),
        title: Text(
          'Add Comment',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        elevation: 0.7,
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () {
          switch (widget.commentType) {
            case 'new':
              ref
                  .read(commentsPaginationControllerProvider.notifier)
                  .newComment(
                    _message.text,
                  )
                  .then(
                (value) {
                  ref
                      .read(postPaginationControllerProvider.notifier)
                      .commentsCount(widget.index!);
                  Navigator.pop(context);
                },
              );

              break;
            case 'reply':
              ref
                  .read(replyCommentsPaginationControllerProvider.notifier)
                  .replyComment(
                    int.parse(widget.commentId!),
                    0,
                    _message.text,
                  )
                  .then(
                (value) {
                  ref
                      .read(commentsPaginationControllerProvider.notifier)
                      .commentsCount(widget.commentIndex!);
                  ref
                      .read(postPaginationControllerProvider.notifier)
                      .commentsCount(widget.index!);
                  Navigator.pop(context);
                },
              );
              break;
            case 'replyreply':
              ref
                  .read(replyCommentsPaginationControllerProvider.notifier)
                  .replyComment(
                    int.parse(widget.commentId!),
                    int.parse(widget.replyUserId!),
                    _message.text,
                  )
                  .then(
                (value) {
                  ref
                      .read(commentsPaginationControllerProvider.notifier)
                      .commentsCount(widget.commentIndex!);
                  ref
                      .read(postPaginationControllerProvider.notifier)
                      .commentsCount(widget.index!);
                  Navigator.pop(context);
                },
              );
              break;
          }
        },
        child: Text(
          "Add Comment",
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.04),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (widget.commentType == 'replyreply' && widget.replyUserName != '')
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      '@${widget.replyUserName}',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        letterSpacing: 0.1,
                        wordSpacing: 0.5,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
            Expanded(
              child: TextFormField(
                controller: _message,
                autofocus: true,
                expands: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10, right: 5, top: 10),
                  border: InputBorder.none,
                  hintText: 'Enter Text',
                  // prefixText:
                  //     widget.replyUserName == null ? '' : ,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 0.1,
                  wordSpacing: 0.5,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
