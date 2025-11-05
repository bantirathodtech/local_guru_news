import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ErrorBody extends StatelessWidget {
  final String? message;
  final double? textSize;

  const ErrorBody({
    Key? key,
    @required this.message,
    this.textSize = 16.0, // Default larger text size
  })  : assert(message != null, 'A non-null String must be provided'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 40.0,
              color: Colors.red.shade600,
            ),
            SizedBox(height: 16.0),
            Text(
              message!,
              style: TextStyle(
                fontSize: textSize?.sp ?? 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            // ElevatedButton(
            //   onPressed: () =>
            //       context.refresh(postPaginationControllerProvider).getPosts(),
            //   style: ElevatedButton.styleFrom(
            //     padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            //     textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            //   ),
            //   child: Text("Try Again"),
            // ),
          ],
        ),
      ),
    );
  }
}
