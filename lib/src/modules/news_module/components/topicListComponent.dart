import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../src.dart';

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
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.green.withOpacity(0.2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: isSelected ? 1 : 1,
          ),
        ),
        child: Text(
          name ?? 'Unknown',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.black87,
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../src.dart';
//
// class TopicListComponent extends ConsumerWidget {
//   final String? id;
//   final String? name;
//   final String? type;
//   const TopicListComponent({
//     Key? key,
//     this.id,
//     this.name,
//     this.type,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, ref) {
//     final String t = ref.watch(topic);
//     return InkWell(
//       onTap: () async {
//         ref.read(topicId.notifier).state = type! + '/' + id!;
//         ref.read(topic.notifier).state = name!;
//         ref.read(topicType.notifier).state = type!;
//         ref.refresh(postPaginationControllerProvider.notifier).resetPosts();
//       },
//       child: Container(
//         decoration: t == name
//             ? BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(
//                     color: Colors.red,
//                     style: BorderStyle.solid,
//                     width: 3,
//                   ),
//                 ),
//               )
//             : BoxDecoration(),
//         child: Padding(
//           padding: EdgeInsets.all(8),
//           child: Text(
//             name!,
//             style: TextStyle(
//               color: t == name ? Colors.red : disabledColor,
//               fontSize: 16.sp,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
