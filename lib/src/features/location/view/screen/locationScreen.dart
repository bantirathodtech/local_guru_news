// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:local_guru_all/src/core/components/appBar/app_bar.dart';
// import 'package:local_guru_all/src/core/components/button/custom_button.dart';
// import 'package:local_guru_all/src/core/constants/app_colors.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../src.dart';
//
// class LocationScreen extends StatefulWidget {
//   const LocationScreen({Key? key}) : super(key: key);
//
//   @override
//   _LocationScreenState createState() => _LocationScreenState();
// }
//
// class _LocationScreenState extends State<LocationScreen> {
//   Box<String> box = Hive.box('user');
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Consumer(
//         builder: (context, ref, child) {
//           AsyncValue<List<LocationModel>> location = ref.watch(fetchLocation);
//           ref.watch(postPaginationControllerProvider);
//
//           return Scaffold(
//             appBar: const CustomAppBar(
//               title: 'మీ ప్రాంతాన్ని ఎంచుకోండి',
//               backgroundColor: AppColors.primary,
//               iconColor: AppColors.black,
//               titleColor: AppColors.black,
//             ),
//             bottomNavigationBar: ref.watch(locationLandmark).isNotEmpty
//                 ? Padding(
//                     padding: EdgeInsets.fromLTRB(6.h, 0.h, 6.h, 2.h),
//                     child: CustomButton(
//                       text: 'కొనసాగించండి',
//                       onPressed: () {
//                         ref
//                             .read(postPaginationControllerProvider.notifier)
//                             .resetPosts();
//                         ref
//                             .read(postPaginationControllerProvider.notifier)
//                             .getPosts();
//                         Navigator.of(context, rootNavigator: true)
//                             .pushAndRemoveUntil(
//                                 MaterialPageRoute(
//                                   builder: (context) => DashBoardScreen(),
//                                 ),
//                                 (route) => false);
//                         ref.read(currentIndexProvider.notifier).state = 0;
//                       },
//                       backgroundColor: Colors.black,
//                       foregroundColor: Colors.white,
//                     ),
//                   )
//                 : const SizedBox.shrink(),
//             body: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: location.when(
//                     data: (locationData) {
//                       return ListView(
//                         children: [
//                           Card(
//                             color: AppColors.white,
//                             elevation: 2,
//                             margin: EdgeInsets.symmetric(vertical: 1.h),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16)),
//                             child: Padding(
//                               padding: EdgeInsets.all(2.h),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "State",
//                                     style: TextStyle(
//                                       fontSize: 18.sp,
//                                       fontWeight: FontWeight.w700,
//                                       // color: Colors.red.shade400,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                   SizedBox(height: 1.h),
//                                   Wrap(
//                                     spacing: 8,
//                                     runSpacing: 8,
//                                     children: locationData.map((state) {
//                                       final selected =
//                                           ref.watch(locationState) == state.id;
//                                       return ChoiceChip(
//                                         backgroundColor: Colors.white,
//                                         selectedColor: Colors.black,
//                                         label: Text(
//                                           state.name ?? '',
//                                           style: TextStyle(
//                                             color: selected
//                                                 ? Colors.white
//                                                 : Colors.black,
//                                             fontSize: 12.sp,
//                                           ),
//                                         ),
//                                         selected: selected,
//                                         onSelected: (val) {
//                                           if (selected) {
//                                             box.put('state', '');
//                                             ref
//                                                 .read(locationState.notifier)
//                                                 .state = '';
//                                             box.put('district', '');
//                                             ref
//                                                 .read(locationDistrict.notifier)
//                                                 .state = '';
//                                             box.put('landmark', '');
//                                             ref
//                                                 .read(locationLandmark.notifier)
//                                                 .state = '';
//                                           } else {
//                                             box.put('state', state.id!);
//                                             box.put('district', '');
//                                             box.put('landmark', '');
//                                             ref
//                                                 .read(locationDistrict.notifier)
//                                                 .state = '';
//                                             ref
//                                                 .read(locationLandmark.notifier)
//                                                 .state = '';
//                                             ref
//                                                 .read(locationState.notifier)
//                                                 .state = state.id!;
//                                           }
//                                         },
//                                       );
//                                     }).toList(),
//                                   ),
//                                   // Districts
//                                   ...locationData
//                                       .where((state) =>
//                                           ref.watch(locationState) == state.id)
//                                       .map(
//                                         (state) => Padding(
//                                           padding: EdgeInsets.only(top: 2.h),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 "District",
//                                                 style: TextStyle(
//                                                   fontSize: 18.sp,
//                                                   fontWeight: FontWeight.w700,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                               SizedBox(height: 1.h),
//                                               Wrap(
//                                                 spacing: 8,
//                                                 runSpacing: 8,
//                                                 children: state.districts!
//                                                     .map((district) {
//                                                   final selectedDistrict =
//                                                       ref.watch(
//                                                               locationDistrict) ==
//                                                           district.id;
//                                                   return ChoiceChip(
//                                                     backgroundColor:
//                                                         Colors.white,
//                                                     selectedColor: Colors.black,
//                                                     label: Text(
//                                                       district.name ?? '',
//                                                       style: TextStyle(
//                                                         color: selectedDistrict
//                                                             ? Colors.white
//                                                             : Colors.black,
//                                                         fontSize: 12.sp,
//                                                       ),
//                                                     ),
//                                                     selected: selectedDistrict,
//                                                     onSelected: (val) {
//                                                       if (selectedDistrict) {
//                                                         ref
//                                                             .read(
//                                                                 locationDistrict
//                                                                     .notifier)
//                                                             .state = '';
//                                                         box.put('district', '');
//                                                         ref
//                                                             .read(
//                                                                 locationLandmark
//                                                                     .notifier)
//                                                             .state = '';
//                                                         box.put('landmark', '');
//                                                       } else {
//                                                         box.put('landmark', '');
//                                                         box.put('district',
//                                                             district.id!);
//                                                         ref
//                                                             .read(
//                                                                 locationLandmark
//                                                                     .notifier)
//                                                             .state = '';
//                                                         ref
//                                                             .read(
//                                                                 locationDistrict
//                                                                     .notifier)
//                                                             .state = district.id!;
//                                                       }
//                                                     },
//                                                   );
//                                                 }).toList(),
//                                               ),
//                                               // Landmarks
//                                               ...state.districts!
//                                                   .where((district) =>
//                                                       ref.watch(
//                                                           locationDistrict) ==
//                                                       district.id)
//                                                   .map((district) => Padding(
//                                                         padding:
//                                                             EdgeInsets.only(
//                                                                 top: 2.h),
//                                                         child: Column(
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .start,
//                                                           children: [
//                                                             Text(
//                                                               "Landmark",
//                                                               style: TextStyle(
//                                                                   fontSize:
//                                                                       18.sp,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w700,
//                                                                   color: Colors
//                                                                       .black),
//                                                             ),
//                                                             SizedBox(
//                                                                 height: 1.h),
//                                                             Wrap(
//                                                               spacing: 8,
//                                                               runSpacing: 8,
//                                                               children: district
//                                                                   .landmarks!
//                                                                   .map(
//                                                                       (landmarks) {
//                                                                 final selectedLandmark =
//                                                                     ref.watch(
//                                                                             locationLandmark) ==
//                                                                         landmarks
//                                                                             .id;
//                                                                 return ChoiceChip(
//                                                                   backgroundColor:
//                                                                       Colors
//                                                                           .white,
//                                                                   selectedColor:
//                                                                       Colors
//                                                                           .black,
//                                                                   label: Text(
//                                                                     landmarks
//                                                                             .name ??
//                                                                         '',
//                                                                     style:
//                                                                         TextStyle(
//                                                                       color: selectedLandmark
//                                                                           ? Colors
//                                                                               .white
//                                                                           : Colors
//                                                                               .black87,
//                                                                       fontSize:
//                                                                           11.sp,
//                                                                     ),
//                                                                   ),
//                                                                   selected:
//                                                                       selectedLandmark,
//                                                                   onSelected:
//                                                                       (val) {
//                                                                     if (selectedLandmark) {
//                                                                       ref
//                                                                           .read(
//                                                                               locationLandmark.notifier)
//                                                                           .state = '';
//                                                                       box.put(
//                                                                           'landmark',
//                                                                           '');
//                                                                       box.put(
//                                                                           'location',
//                                                                           '');
//                                                                     } else {
//                                                                       box.put(
//                                                                           'landmark',
//                                                                           landmarks
//                                                                               .id!);
//                                                                       box.put(
//                                                                           'location',
//                                                                           landmarks
//                                                                               .name!);
//
//                                                                       ref.read(locationLandmark.notifier).state =
//                                                                           landmarks
//                                                                               .id!;
//                                                                       ref.read(selectedLocation.notifier).state =
//                                                                           landmarks
//                                                                               .name!;
//                                                                     }
//                                                                   },
//                                                                 );
//                                                               }).toList(),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       )),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 3.h),
//                         ],
//                       );
//                     },
//                     loading: () => Center(
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                       ),
//                     ),
//                     error: (e, s) => Center(
//                       child: Text(
//                         "Error loading locations.",
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 2.h),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
