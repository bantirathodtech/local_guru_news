import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:sizer/sizer.dart';
import '../../../src.dart';

class JobSearchScreen extends ConsumerStatefulWidget {
  const JobSearchScreen({Key? key}) : super(key: key);

  @override
  _JobSearchScreenState createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends ConsumerState<JobSearchScreen> {
  _loadMore() {
    ref
        .refresh(jobsSearchPaginationControllerProvider.notifier)
        .getJobs(_search.text);
  }

  TextEditingController _search = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final searchTag = ref.watch(jobSearchTag);
    ref.watch(jobsSearchPaginationControllerProvider); //!Jobs
    final jobsState = ref
        .watch(jobsSearchPaginationControllerProvider.notifier)
        .state; //!Jobs
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              ref
                  .read(jobsSearchPaginationControllerProvider.notifier)
                  .restJobs();
              ref.read(jobSearchTag.notifier).state = '';
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
                ref.read(jobSearchTag.notifier).state = _search.text;
                ref
                    .read(jobsSearchPaginationControllerProvider.notifier)
                    .restJobs();
                ref
                    .read(jobsSearchPaginationControllerProvider.notifier)
                    .getJobs(_search.text);
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
                searchTag.isEmpty ? '' : 'Search Results:' + " '$searchTag' ",
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
                          .refresh(
                              jobsSearchPaginationControllerProvider.notifier)
                          .getJobs(searchTag);
                    },
                    child: ListView.builder(
                      itemCount: jobsState.jobs!.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 15,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 1.h,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 0.01,
                                    spreadRadius: 0.01,
                                    offset: Offset(-0.01, 0.5),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => JobDetails(
                                              title:
                                                  jobsState.jobs![index].title!,
                                              location: jobsState
                                                  .jobs![index].location!,
                                              salary: jobsState
                                                  .jobs![index].salary!,
                                              type: jobsState
                                                  .jobs![index].jobType,
                                              role:
                                                  jobsState.jobs![index].hires,
                                              qualification: jobsState
                                                  .jobs![index].qualification,
                                              description: jobsState
                                                  .jobs![index].description,
                                              contact: jobsState
                                                  .jobs![index].contact,
                                              customlocation: jobsState
                                                  .jobs![index].customLocation,
                                            ))),
                                child: JobLayoutComponent(
                                  title: jobsState.jobs![index].title,
                                  description:
                                      jobsState.jobs![index].shorDescription,
                                  hiring: jobsState.jobs![index].hires,
                                  salary: jobsState.jobs![index].salary,
                                  location:
                                      jobsState.jobs![index].customLocation,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
