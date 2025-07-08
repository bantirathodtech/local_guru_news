import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/modules/listing_module/controllers/listsPostPaginationController.dart';
import 'package:sizer/sizer.dart';

import '../../../src.dart';

class ListTopicComponent extends ConsumerWidget {
  final String? id;
  final String? name;
  final String? type;
  const ListTopicComponent({
    Key? key,
    this.id,
    this.name,
    this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final String t = ref.watch(listTopicId);
    return InkWell(
      onTap: () async {
        // context.read(topicId).state = type! + '/' + id!;
        ref.read(listTopicId.notifier).state = id!;
        // context.read(topicType).state = type!;
        ref.refresh(listsPaginationControllerProvider.notifier).resetPosts();
      },
      child: Container(
        decoration: t == id
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.red,
                    style: BorderStyle.solid,
                    width: 5,
                  ),
                ),
              )
            : BoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            name!,
            style: TextStyle(
              color: t == id ? Colors.red : disabledColor,
              fontSize: 10.sp,
            ),
          ),
        ),
      ),
    );
  }
}
