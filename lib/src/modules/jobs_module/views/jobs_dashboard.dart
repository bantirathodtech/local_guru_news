import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:local_guru_all/src/modules/jobs_module/controllers/jobsPaginationController.dart';
import 'package:sizer/sizer.dart';

import '../../../src.dart';

class JobsDashboard extends ConsumerStatefulWidget {
  const JobsDashboard({Key? key}) : super(key: key);

  @override
  _JobsDashboardState createState() => _JobsDashboardState();
}

class _JobsDashboardState extends ConsumerState<JobsDashboard> {
  _loadMore() {
    ref.read(jobsPaginationControllerProvider.notifier).getJobs();
  }

  Box<String> box = Hive.box('user');

  @override
  Widget build(BuildContext context) {
    ref.watch(jobsPaginationControllerProvider); //!Jobs

    final jobsState =
        ref.watch(jobsPaginationControllerProvider.notifier).state; //!Jobs
        
    return SafeArea(
      child: Scaffold(
        floatingActionButton: (box.containsKey('id') && box.get('id') != null)
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                          builder: (context) => NewJobForm())),
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              )
            : SizedBox.shrink(),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              InkWell(
                onTap: () => Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (context) => JobSearchScreen())),
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
                        'Find a job',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: LazyLoadScrollView(
                  onEndOfPage: _loadMore,
                  child: RefreshIndicator(
                    onRefresh: () {
                      ref
                          .read(jobsPaginationControllerProvider.notifier)
                          .restJobs();
                      return ref
                          .read(jobsPaginationControllerProvider.notifier)
                          .getJobs();
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
                                                title: jobsState
                                                    .jobs![index].title!,
                                                location: jobsState
                                                    .jobs![index].location!,
                                                salary: jobsState
                                                    .jobs![index].salary!,
                                                type: jobsState
                                                    .jobs![index].jobType,
                                                role: jobsState
                                                    .jobs![index].hires,
                                                qualification: jobsState
                                                    .jobs![index].qualification,
                                                description: jobsState
                                                    .jobs![index].description,
                                                contact: jobsState
                                                    .jobs![index].contact,
                                                customlocation: jobsState
                                                    .jobs![index]
                                                    .customLocation,
                                              ))),
                                  child: JobLayoutComponent(
                                    title: jobsState.jobs![index].title,
                                    description:
                                        jobsState.jobs![index].shorDescription,
                                    hiring: jobsState.jobs![index].hires,
                                    salary: jobsState.jobs![index].salary,
                                    location:
                                        jobsState.jobs![index].customLocation,
                                  )),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
