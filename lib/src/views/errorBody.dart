import 'package:flutter/material.dart';

class ErrorBody extends StatelessWidget {
  final String? message;
  const ErrorBody({
    Key? key,
    @required this.message,
  })  : assert(message != null, 'A non-null String must be provided'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message!),
          // ElevatedButton(
          //   onPressed: () =>
          //       context.refresh(postPaginationControllerProvider).getPosts(),
          //   child: Text("Try again"),
          // ),
        ],
      ),
    );
  }
}
