import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../../src.dart';

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
    final bool isSelected = t == id;

    return InkWell(
      onTap: () async {
        ref.read(greetingTopicId.notifier).state = id!;
        ref
            .refresh(greetingsPaginationControllerProvider.notifier)
            .resetGreetings();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  )
                ],
        ),
        margin: EdgeInsets.symmetric(
          horizontal: 0.8.h,
          vertical: 6,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 18,
          ),
          child: Text(
            category!,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade800,
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
