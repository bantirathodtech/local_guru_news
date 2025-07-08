import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';
import '../src.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Box<String> box = Hive.box('user');
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer(
        builder: (context, ref, child) {
          AsyncValue<List<LocationModel>> location =
              ref.watch(fetchLocation); //Location
          ref.watch(postPaginationControllerProvider);
          return Scaffold(
            bottomNavigationBar: ref.watch(locationLandmark).isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(postPaginationControllerProvider.notifier)
                            .resetPosts();
                        ref
                            .read(postPaginationControllerProvider.notifier)
                            .getPosts();

                        Navigator.of(context, rootNavigator: true)
                            .pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => DashBoardScreen(),
                                ),
                                (route) => false);

                        ref.read(currentIndexProvider.notifier).state = 0;
                      },
                      child: Text(
                        'కొనసాగించండి',
                        style: TextStyle(
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 15.sp,
                  ),
                  child: Text(
                    'మీ ప్రాంతాన్ని ఎంచుకోండి',
                    style: TextStyle(
                      fontSize: 18.sp,
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: location.when(
                      data: (locationData) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            children: locationData.map((state) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  children: [
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        if (ref
                                                .read(locationState.notifier)
                                                .state ==
                                            state.id!) {
                                          box.put('state', '');
                                          ref
                                              .read(locationState.notifier)
                                              .state = '';
                                          box.put('district', '');
                                          ref
                                              .read(locationDistrict.notifier)
                                              .state = '';
                                          box.put('landmark', '');
                                          ref
                                              .read(locationLandmark.notifier)
                                              .state = '';
                                        } else {
                                          box.put('state', state.id!);
                                          box.put('district', '');
                                          box.put('landmark', '');
                                          ref
                                              .read(locationDistrict.notifier)
                                              .state = '';
                                          ref
                                              .read(locationLandmark.notifier)
                                              .state = '';
                                          ref
                                              .read(locationState.notifier)
                                              .state = state.id!;
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 1.h,
                                          horizontal: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ref.watch(locationState) ==
                                                  state.id
                                              ? Colors.red
                                              : Colors.grey.withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          state.name!,
                                          style: TextStyle(
                                            color: ref.watch(locationState) ==
                                                    state.id
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 10.sp,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // -----------------------District---------------
                                    ref.watch(locationState) == state.id
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 15.sp,
                                              vertical: 5.sp,
                                            ),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Wrap(
                                                children: state.districts!
                                                    .map((district) {
                                                  return Wrap(
                                                    children: [
                                                      InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        onTap: () {
                                                          if (ref
                                                                  .read(locationDistrict
                                                                      .notifier)
                                                                  .state ==
                                                              district.id!) {
                                                            ref
                                                                .read(locationDistrict
                                                                    .notifier)
                                                                .state = '';
                                                            box.put(
                                                                'district', '');
                                                            ref
                                                                .read(locationLandmark
                                                                    .notifier)
                                                                .state = '';
                                                            box.put(
                                                                'landmark', '');
                                                          } else {
                                                            box.put(
                                                                'landmark', '');
                                                            box.put('district',
                                                                district.id!);
                                                            ref
                                                                .read(locationLandmark
                                                                    .notifier)
                                                                .state = '';
                                                            ref
                                                                .read(locationDistrict
                                                                    .notifier)
                                                                .state = district.id!;
                                                          }
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              vertical: 1.h,
                                                              horizontal: 2.h,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: ref.watch(
                                                                          locationDistrict) ==
                                                                      district
                                                                          .id
                                                                  ? Colors.red
                                                                  : Colors.grey
                                                                      .withOpacity(
                                                                          0.5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child: Text(
                                                              district.name!,
                                                              style: TextStyle(
                                                                color: ref.watch(
                                                                            locationDistrict) ==
                                                                        district
                                                                            .id
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                                fontSize: 10.sp,
                                                                letterSpacing:
                                                                    1,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      // ---------------LandMark ------------
                                                      ref.watch(locationDistrict) ==
                                                              district.id
                                                          ? Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal:
                                                                    15.sp,
                                                                vertical: 5.sp,
                                                              ),
                                                              child: Container(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                child: Wrap(
                                                                  children: district
                                                                      .landmarks!
                                                                      .map(
                                                                          (landmarks) {
                                                                    return Wrap(
                                                                      children: [
                                                                        InkWell(
                                                                          splashColor:
                                                                              Colors.transparent,
                                                                          onTap:
                                                                              () {
                                                                            if (ref.read(locationLandmark.notifier).state ==
                                                                                landmarks.id!) {
                                                                              ref.read(locationLandmark.notifier).state = '';
                                                                              box.put('landmark', '');
                                                                              box.put('location', '');
                                                                            } else {
                                                                              box.put('landmark', landmarks.id!);
                                                                              box.put('location', landmarks.name!);

                                                                              ref.read(locationLandmark.notifier).state = landmarks.id!;
                                                                              ref.read(selectedLocation.notifier).state = landmarks.name!;
                                                                            }
                                                                          },
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Container(
                                                                              padding: EdgeInsets.symmetric(
                                                                                vertical: 1.h,
                                                                                horizontal: 2.h,
                                                                              ),
                                                                              decoration: BoxDecoration(
                                                                                color: ref.watch(locationLandmark) == landmarks.id ? Colors.red : Colors.grey.withOpacity(0.5),
                                                                                borderRadius: BorderRadius.circular(20),
                                                                              ),
                                                                              child: Text(
                                                                                landmarks.name!,
                                                                                style: TextStyle(
                                                                                  color: ref.watch(locationLandmark) == landmarks.id ? Colors.white : Colors.black,
                                                                                  fontSize: 10.sp,
                                                                                  letterSpacing: 1,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  }).toList(),
                                                                ),
                                                              ),
                                                            )
                                                          : SizedBox.shrink(),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                      loading: () => Text(
                        "Fetching Locations...",
                        style: TextStyle(
                          fontSize: 8.sp,
                        ),
                      ),
                      error: (e, s) => Text(
                        "Error",
                        style: TextStyle(
                          fontSize: 8.sp,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
