import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../src.dart';

class Followers extends StatefulWidget {
  const Followers({Key? key}) : super(key: key);

  @override
  _FollowersState createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        ref.watch(politiciansControllerProvider); //!Politicians
        final politiciansState =
            ref.watch(politiciansControllerProvider.notifier).state; //!Posts
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'అనుచరులందరూ',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.black,
                ),
              ),
            ),
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '_____ మీరు అనుసరిస్తున్న వ్యక్తులు',
                      style: TextStyle(
                        fontSize: 11.sp,
                      ),
                    ),
                    Wrap(
                      children: politiciansState.politicians!.map((e) {
                        int politicianIndex =
                            politiciansState.politicians!.indexOf(e);
                        if (e.status == '1') {
                          return InkWell(
                            onTap: () {
                              if (box.containsKey('id') &&
                                  box.get('id')!.isNotEmpty) {
                                ref
                                    .read(topicsControllerProvider.notifier)
                                    .newTopic(
                                      politiciansState
                                          .politicians![politicianIndex].id!,
                                      politiciansState
                                          .politicians![politicianIndex].name!,
                                      politiciansState
                                          .politicians![politicianIndex].type!,
                                      politiciansState
                                          .politicians![politicianIndex]
                                          .profile!,
                                    );
                                ref
                                    .read(
                                        politiciansControllerProvider.notifier)
                                    .updateStatus(
                                      e.status!,
                                      politicianIndex,
                                      politiciansState
                                          .politicians![politicianIndex].id!,
                                    );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("You must Login to Follow"),
                                    action: SnackBarAction(
                                      onPressed: () {
                                        print('login');
                                      },
                                      label: 'Login',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: PoliticianLayout(
                              name: e.name,
                              profile: e.profile,
                              status: e.status,
                            ),
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      }).toList(),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Text(
                      '_____ మీరు అనుసరించని వ్యక్తులు',
                      style: TextStyle(
                        fontSize: 11.sp,
                      ),
                    ),
                    Wrap(
                      children: politiciansState.politicians!.map((e) {
                        int politicianIndex =
                            politiciansState.politicians!.indexOf(e);
                        if (e.status == '0') {
                          return InkWell(
                            onTap: () {
                              if (box.containsKey('id') &&
                                  box.get('id')!.isNotEmpty) {
                                ref
                                    .read(topicsControllerProvider.notifier)
                                    .newTopic(
                                      politiciansState
                                          .politicians![politicianIndex].id!,
                                      politiciansState
                                          .politicians![politicianIndex].name!,
                                      politiciansState
                                          .politicians![politicianIndex].type!,
                                      politiciansState
                                          .politicians![politicianIndex]
                                          .profile!,
                                    );
                                ref
                                    .read(
                                        politiciansControllerProvider.notifier)
                                    .updateStatus(
                                      e.status!,
                                      politicianIndex,
                                      politiciansState
                                          .politicians![politicianIndex].id!,
                                    );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("You must Login to Follow"),
                                    action: SnackBarAction(
                                      onPressed: () {
                                        print('login');
                                      },
                                      label: 'Login',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: PoliticianLayout(
                              name: e.name,
                              profile: e.profile,
                              status: e.status,
                            ),
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
