import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../../src.dart';

class TopicListComponent extends ConsumerWidget {
  final String? id;
  final String? name;
  final String? type;

  const TopicListComponent({
    Key? key,
    this.id,
    this.name,
    this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String selectedTopic = ref.watch(topic);
    final bool isSelected = selectedTopic == name;

    return GestureDetector(
      onTap: () {
        if (id != null && name != null && type != null) {
          ref.read(topicId.notifier).state = '$type/$id';
          ref.read(topic.notifier).state = name!;
          ref.read(topicType.notifier).state = type!;
          ref.refresh(postPaginationControllerProvider.notifier).resetPosts();
          ref.read(postPaginationControllerProvider.notifier).getPosts();
        } else {
          developer.log('Invalid topic data: id=$id, name=$name, type=$type');
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.grey : Colors.grey,
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Text(
          name ?? 'Unknown',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade900,
            letterSpacing: 0.8,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
