import 'package:delayed_display/delayed_display.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:sizer/sizer.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../../src.dart';

class ListsDashboard extends ConsumerStatefulWidget {
  const ListsDashboard({Key? key}) : super(key: key);

  @override
  _ListsDashboardState createState() => _ListsDashboardState();
}

class _ListsDashboardState extends ConsumerState<ListsDashboard> {
  _loadMore() {
    ref.read(listsPaginationControllerProvider.notifier).getPosts();
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<ListsTopics>> topics = ref.watch(fetchListTopics); //Topics

    ref.watch(listsPaginationControllerProvider); //!Posts
    final listState =
        ref.watch(listsPaginationControllerProvider.notifier).state; //!Posts
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                InkWell(
                  onTap: () => Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                          builder: (context) => ListSearchScreen())),
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 1.h,
                      horizontal: 2.6.h,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        Text(
                          'Search',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                StickyHeader(
                  header: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(
                      top: 5,
                    ),
                    margin: EdgeInsets.only(
                      bottom: 10,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey,
                          style: BorderStyle.solid,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Builder(
                      builder: (context) {
                        return topics.when(data: (topicsData) {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: topicsData.length,
                            itemBuilder: (context, index) {
                              return ListTopicComponent(
                                id: topicsData[index].id,
                                name: topicsData[index].category,
                              );
                            },
                          );
                        }, loading: () {
                          return Text('Loading');
                        }, error: (e, s) {
                          return Text(s.toString());
                        });
                      },
                    ),
                  ),
                  content: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    padding: EdgeInsets.only(
                      bottom: 100,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              if (listState.refreshError) {
                                return ErrorBody(
                                  message: listState.errorMessage,
                                );
                              } else if (listState.posts!.isEmpty) {
                                return DelayedDisplay(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.featured_play_list_rounded,
                                          size: 30,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Fetching Posts',
                                          style: TextStyle(
                                            fontSize: 8.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return LazyLoadScrollView(
                                  onEndOfPage: _loadMore,
                                  child: RefreshIndicator(
                                    onRefresh: () {
                                      ref
                                          .read(
                                              listsPaginationControllerProvider
                                                  .notifier)
                                          .resetPosts();
                                      return ref
                                          .read(
                                              listsPaginationControllerProvider
                                                  .notifier)
                                          .getPosts();
                                    },
                                    child: ListView.builder(
                                      itemCount: listState.posts!.length,
                                      physics: BouncingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            InkWell(
                                              onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ListsDetails(
                                                    id: listState
                                                        .posts![index].id!,
                                                    title: listState
                                                        .posts![index].title!,
                                                    description: listState
                                                        .posts![index]
                                                        .description,
                                                    media: listState
                                                        .posts![index].media!,
                                                    time: listState
                                                        .posts![index].time!,
                                                    customlocation: listState
                                                        .posts![index]
                                                        .customlocation!,
                                                    contact: listState
                                                        .posts![index].contact!,
                                                    readableTime: listState
                                                        .posts![index]
                                                        .readableTime!,
                                                    location: listState
                                                        .posts![index]
                                                        .location!,
                                                  ),
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 150,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child:
                                                            FancyShimmerImage(
                                                          imageUrl: listState
                                                              .posts![index]
                                                              .media![0],
                                                          boxFit:
                                                              BoxFit.contain,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                listState
                                                                    .posts![
                                                                        index]
                                                                    .title!,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      12.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  letterSpacing:
                                                                      1,
                                                                  wordSpacing:
                                                                      0.5,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Text(
                                                                listState
                                                                    .posts![
                                                                        index]
                                                                    .description!,
                                                                maxLines: 4,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      10.sp,
                                                                  letterSpacing:
                                                                      1,
                                                                  wordSpacing:
                                                                      0.5,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                listState
                                                                    .posts![
                                                                        index]
                                                                    .location!,
                                                                maxLines: 4,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      10.sp,
                                                                  letterSpacing:
                                                                      1,
                                                                  wordSpacing:
                                                                      0.5,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            index == listState.posts!.length - 1
                                                ? SizedBox.shrink()
                                                : Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 1.h,
                                                      vertical: 0.5.h,
                                                    ),
                                                    child: Divider(
                                                      thickness: 1.2,
                                                    ),
                                                  ),
                                            index == listState.posts!.length - 1
                                                ? SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.93,
                                                  )
                                                : SizedBox.shrink()
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
