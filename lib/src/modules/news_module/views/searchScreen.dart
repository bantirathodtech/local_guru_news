import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../src.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.chevron_left,
            color: Colors.black,
          ),
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          ref.watch(topicsControllerProvider);
          final topicsState =
              ref.watch(topicsControllerProvider.notifier).state;
          return Container(
            child: Builder(
              builder: (context) {
                if (topicsState.refreshError) {
                  return ErrorBody(
                    message: topicsState.errorMessage,
                  );
                } else if (topicsState.topics!.isEmpty) {
                  return DelayedDisplay(
                    // delay: Duration(seconds: 10),
                    child: Center(
                      child: Text(
                        'Fetching Posts',
                        style: TextStyle(
                          fontSize: 8.sp,
                        ),
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: topicsState.topics!.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          ref.read(topicId.notifier).state =
                              topicsState.topics![index].type! +
                                  '/' +
                                  topicsState.topics![index].id!;
                          ref.read(topic.notifier).state =
                              topicsState.topics![index].name!;
                          ref.read(topicType.notifier).state =
                              topicsState.topics![index].type!;
                          ref
                              .refresh(
                                  postPaginationControllerProvider.notifier)
                              .resetPosts();
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 4.h,
                                height: 4.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      topicsState.topics![index].icon!,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 7,
                              ),
                              Text(
                                topicsState.topics![index].name!,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
