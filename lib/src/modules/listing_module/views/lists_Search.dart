import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:sizer/sizer.dart';
import '../../../src.dart';

class ListSearchScreen extends ConsumerStatefulWidget {
  const ListSearchScreen({Key? key}) : super(key: key);

  @override
  _ListSearchScreenState createState() => _ListSearchScreenState();
}

class _ListSearchScreenState extends ConsumerState<ListSearchScreen> {
  _loadMore() {
    ref
        .read(listSearchPaginationControllerProvider.notifier)
        .getPosts(_search.text);
  }

  TextEditingController _search = TextEditingController();
  @override
  Widget build(BuildContext context) {
    ref.watch(listSearchPaginationControllerProvider);
    final listState =
        ref.watch(listSearchPaginationControllerProvider.notifier).state;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              ref
                  .read(listSearchPaginationControllerProvider.notifier)
                  .resetPosts();
              ref.read(listsPaginationControllerProvider.notifier).resetPosts();
              ref.read(listsPaginationControllerProvider.notifier).getPosts();
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.chevron_left_rounded,
              color: Colors.black,
            ),
          ),
          title: TextField(
            autofocus: true,
            decoration: InputDecoration(
              suffixIcon: GestureDetector(
                onTap: () {
                  _search.clear();
                },
                child: Icon(
                  Icons.close,
                  size: 25,
                ),
              ),
              hintText: "Search",
              hintStyle: TextStyle(color: Colors.grey[800]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                gapPadding: 10.0,
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(10),
              filled: true,
              fillColor: Colors.white,
            ),
            controller: _search,
            textInputAction: TextInputAction.search,
            cursorHeight: 20,
            onSubmitted: (v) {
              if (_search.text.isNotEmpty) {
                ref
                    .read(listsPaginationControllerProvider.notifier)
                    .resetPosts();
                ref
                    .refresh(listSearchPaginationControllerProvider.notifier)
                    .getPosts(_search.text);
                FocusScope.of(context).unfocus();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Enter Some Text to Search...!",
                    ),
                  ),
                );
              }
            },
          )),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 15,
              ),
              child: Text(
                _search.text.isEmpty
                    ? ''
                    : 'Search Results:' + " '${_search.text}' ",
              ),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                return LazyLoadScrollView(
                  onEndOfPage: _loadMore,
                  child: RefreshIndicator(
                    onRefresh: () {
                      return ref
                          .read(listSearchPaginationControllerProvider.notifier)
                          .getPosts(_search.text);
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
                                  builder: (context) => ListsDetails(
                                    id: listState.posts![index].id!,
                                    title: listState.posts![index].title!,
                                    description:
                                        listState.posts![index].description,
                                    media: listState.posts![index].media!,
                                    time: listState.posts![index].time!,
                                    customlocation:
                                        listState.posts![index].customlocation!,
                                    contact: listState.posts![index].contact!,
                                    readableTime:
                                        listState.posts![index].readableTime!,
                                    location: listState.posts![index].location!,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 150,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: FancyShimmerImage(
                                          imageUrl:
                                              listState.posts![index].media![0],
                                          boxFit: BoxFit.contain,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                listState.posts![index].title!,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 1,
                                                  wordSpacing: 0.5,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                listState
                                                    .posts![index].description!,
                                                maxLines: 4,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  letterSpacing: 1,
                                                  wordSpacing: 0.5,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                listState
                                                    .posts![index].location!,
                                                maxLines: 4,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  letterSpacing: 1,
                                                  wordSpacing: 0.5,
                                                  color: Colors.grey,
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 1.h,
                                      vertical: 0.5.h,
                                    ),
                                    child: Divider(
                                      thickness: 1.2,
                                    ),
                                  ),
                            index == listState.posts!.length - 1
                                ? SizedBox(
                                    height: MediaQuery.of(context).size.width *
                                        0.93,
                                  )
                                : SizedBox.shrink()
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
