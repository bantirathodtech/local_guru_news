import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../src.dart';

class GreetingsTopicListComponent extends ConsumerWidget {
  final String? id;
  final String? category;
  const GreetingsTopicListComponent({
    Key? key,
    this.id,
    this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final String t = ref.watch(greetingTopicId);
    return InkWell(
      onTap: () async {
        ref.read(greetingTopicId.notifier).state = id!;
        ref
            .refresh(greetingsPaginationControllerProvider.notifier)
            .resetGreetings();
      },
      child: Container(
        decoration: BoxDecoration(
          color: t == id ? Colors.red : disabledColor,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: 1.h,
          vertical: 5,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 15,
          ),
          child: Text(
            category!,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.5.sp,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
