import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_guru_all/src/core/components/appBar/app_bar.dart';
import 'package:local_guru_all/src/core/components/button/custom_button.dart';
import 'package:local_guru_all/src/core/constants/app_colors.dart';
import 'package:local_guru_all/src/features/location/viewmodel/location_provider.dart';
import 'package:provider/provider.dart' hide Consumer;
import 'package:sizer/sizer.dart';

import '../../../../src.dart';

class LocationScreenV2 extends StatefulWidget {
  const LocationScreenV2({Key? key}) : super(key: key);

  @override
  State<LocationScreenV2> createState() => _LocationScreenV2State();
}

class _LocationScreenV2State extends State<LocationScreenV2> {
  Box<String> box = Hive.box('user');

  @override
  void initState() {
    super.initState();
    // Load states on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().loadStates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final locationProvider = context.watch<LocationProvider>();
        ref.watch(postPaginationControllerProvider);

        return Scaffold(
          appBar: const CustomAppBar(
            title: 'మీ ప్రాంతాన్ని ఎంచుకోండి',
            backgroundColor: AppColors.primary,
            iconColor: AppColors.black,
            titleColor: AppColors.black,
          ),
          bottomNavigationBar: ref.watch(locationLandmark).isNotEmpty
              ? Padding(
                  padding: EdgeInsets.fromLTRB(6.h, 0.h, 6.h, 2.h),
                  child: CustomButton(
                    text: 'కొనసాగించండి',
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
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                )
              : const SizedBox.shrink(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: locationProvider.isLoading &&
                        locationProvider.states.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : locationProvider.error != null &&
                            locationProvider.states.isEmpty
                        ? Center(
                            child: Text(
                              'Error: ${locationProvider.error}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.red,
                              ),
                            ),
                          )
                        : ListView(
                            children: [
                              Card(
                                color: AppColors.white,
                                elevation: 2,
                                margin: EdgeInsets.symmetric(vertical: 1.h),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: EdgeInsets.all(2.h),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // States Section
                                      Text(
                                        "State",
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: locationProvider.states
                                            .map((state) {
                                          final selected = locationProvider
                                                  .selectedStateId ==
                                              state.id;
                                          return ChoiceChip(
                                            backgroundColor: Colors.white,
                                            selectedColor: Colors.black,
                                            label: Text(
                                              state.state,
                                              style: TextStyle(
                                                color: selected
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                            selected: selected,
                                            onSelected: (val) async {
                                              if (selected) {
                                                // Deselect
                                                box.put('state', '');
                                                ref
                                                    .read(
                                                        locationState.notifier)
                                                    .state = '';
                                                box.put('district', '');
                                                ref
                                                    .read(locationDistrict
                                                        .notifier)
                                                    .state = '';
                                                box.put('landmark', '');
                                                ref
                                                    .read(locationLandmark
                                                        .notifier)
                                                    .state = '';
                                                locationProvider
                                                    .clearSelection();
                                              } else {
                                                // Select state and load districts
                                                box.put('state', state.id);
                                                box.put('district', '');
                                                box.put('landmark', '');
                                                ref
                                                    .read(
                                                        locationState.notifier)
                                                    .state = state.id;
                                                ref
                                                    .read(locationDistrict
                                                        .notifier)
                                                    .state = '';
                                                ref
                                                    .read(locationLandmark
                                                        .notifier)
                                                    .state = '';
                                                await locationProvider
                                                    .selectState(state.id);
                                              }
                                            },
                                          );
                                        }).toList(),
                                      ),
                                      // Districts Section
                                      if (locationProvider.selectedStateId !=
                                              null &&
                                          locationProvider.districts.isNotEmpty)
                                        Padding(
                                          padding: EdgeInsets.only(top: 2.h),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "District",
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 1.h),
                                              locationProvider.isLoading
                                                  ? const Padding(
                                                      padding:
                                                          EdgeInsets.all(16.0),
                                                      child: Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                    )
                                                  : Wrap(
                                                      spacing: 8,
                                                      runSpacing: 8,
                                                      children: locationProvider
                                                          .districts
                                                          .map((district) {
                                                        final selectedDistrict =
                                                            locationProvider
                                                                    .selectedDistrictId ==
                                                                district
                                                                    .districtId;
                                                        return ChoiceChip(
                                                          backgroundColor:
                                                              Colors.white,
                                                          selectedColor:
                                                              Colors.black,
                                                          label: Text(
                                                            district.district,
                                                            style: TextStyle(
                                                              color:
                                                                  selectedDistrict
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black,
                                                              fontSize: 12.sp,
                                                            ),
                                                          ),
                                                          selected:
                                                              selectedDistrict,
                                                          onSelected:
                                                              (val) async {
                                                            if (selectedDistrict) {
                                                              // Deselect
                                                              ref
                                                                  .read(locationDistrict
                                                                      .notifier)
                                                                  .state = '';
                                                              box.put(
                                                                  'district',
                                                                  '');
                                                              ref
                                                                  .read(locationLandmark
                                                                      .notifier)
                                                                  .state = '';
                                                              box.put(
                                                                  'landmark',
                                                                  '');
                                                              locationProvider
                                                                  .selectDistrict(
                                                                      locationProvider
                                                                          .selectedStateId!,
                                                                      null);
                                                            } else {
                                                              // Select district and load landmarks
                                                              box.put(
                                                                  'district',
                                                                  district
                                                                      .districtId);
                                                              box.put(
                                                                  'landmark',
                                                                  '');
                                                              ref
                                                                      .read(locationDistrict
                                                                          .notifier)
                                                                      .state =
                                                                  district
                                                                      .districtId;
                                                              ref
                                                                  .read(locationLandmark
                                                                      .notifier)
                                                                  .state = '';
                                                              await locationProvider
                                                                  .selectDistrict(
                                                                      locationProvider
                                                                          .selectedStateId!,
                                                                      district
                                                                          .districtId);
                                                            }
                                                          },
                                                        );
                                                      }).toList(),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      // Landmarks Section
                                      if (locationProvider.selectedDistrictId !=
                                              null &&
                                          locationProvider.landmarks.isNotEmpty)
                                        Padding(
                                          padding: EdgeInsets.only(top: 2.h),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Landmark",
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 1.h),
                                              locationProvider.isLoading
                                                  ? const Padding(
                                                      padding:
                                                          EdgeInsets.all(16.0),
                                                      child: Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                    )
                                                  : Wrap(
                                                      spacing: 8,
                                                      runSpacing: 8,
                                                      children: locationProvider
                                                          .landmarks
                                                          .map((landmark) {
                                                        final selectedLandmark =
                                                            locationProvider
                                                                    .selectedLandmarkId ==
                                                                landmark
                                                                    .landmarkId;
                                                        return ChoiceChip(
                                                          backgroundColor:
                                                              Colors.white,
                                                          selectedColor:
                                                              Colors.black,
                                                          label: Text(
                                                            landmark.landmark,
                                                            style: TextStyle(
                                                              color: selectedLandmark
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black87,
                                                              fontSize: 11.sp,
                                                            ),
                                                          ),
                                                          selected:
                                                              selectedLandmark,
                                                          onSelected: (val) {
                                                            if (selectedLandmark) {
                                                              // Deselect
                                                              ref
                                                                  .read(locationLandmark
                                                                      .notifier)
                                                                  .state = '';
                                                              box.put(
                                                                  'landmark',
                                                                  '');
                                                              box.put(
                                                                  'location',
                                                                  '');
                                                              locationProvider
                                                                  .selectLandmark(
                                                                      null);
                                                            } else {
                                                              // Select landmark
                                                              box.put(
                                                                  'landmark',
                                                                  landmark
                                                                      .landmarkId);
                                                              box.put(
                                                                  'location',
                                                                  landmark
                                                                      .landmark);
                                                              ref
                                                                      .read(locationLandmark
                                                                          .notifier)
                                                                      .state =
                                                                  landmark
                                                                      .landmarkId;
                                                              ref
                                                                      .read(selectedLocation
                                                                          .notifier)
                                                                      .state =
                                                                  landmark
                                                                      .landmark;
                                                              locationProvider
                                                                  .selectLandmark(
                                                                      landmark
                                                                          .landmarkId);
                                                            }
                                                          },
                                                        );
                                                      }).toList(),
                                                    ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 3.h),
                            ],
                          ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }
}
