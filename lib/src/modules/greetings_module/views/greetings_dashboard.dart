// import 'dart:io';
//
// import 'package:delayed_display/delayed_display.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:sizer/sizer.dart';
// import '../../../src.dart';
//
// class GreetingsDashboard extends ConsumerStatefulWidget {
//   const GreetingsDashboard({Key? key}) : super(key: key);
//
//   @override
//   _GreetingsDashboardState createState() => _GreetingsDashboardState();
// }
//
// class _GreetingsDashboardState extends ConsumerState<GreetingsDashboard> {
//   _loadMore() {
//     ref.read(greetingsPaginationControllerProvider.notifier).getGreetings();
//   }
//
//   ScreenshotController screenshotController = ScreenshotController();
//   Box<String> box = Hive.box('user');
//   bool _loading = false;
//
//   @override
//   Widget build(BuildContext context) {
//     ref.watch(topicsGreetingsControllerProvider); //!Topics
//     final topicsState =
//         ref.watch(topicsGreetingsControllerProvider.notifier).state; //!Topics
//     ref.watch(greetingsPaginationControllerProvider);
//     final greetingsState =
//         ref.watch(greetingsPaginationControllerProvider.notifier).state;
//     return SafeArea(
//       child: Scaffold(
//         body: Stack(
//           children: [
//             SizedBox(
//               height: MediaQuery.of(context).size.height,
//               child: Column(
//                 children: [
//                   Container(
//                     margin: EdgeInsets.symmetric(
//                       vertical: 8,
//                     ),
//                     padding: EdgeInsets.symmetric(
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       border: Border(
//                         bottom: BorderSide(
//                           color: Colors.black.withOpacity(0.3),
//                           width: 0.5,
//                         ),
//                       ),
//                     ),
//                     height: 65,
//                     child: Builder(
//                       builder: (context) {
//                         if (topicsState.refreshError) {
//                           return ErrorBody(
//                             message: topicsState.errorMessage,
//                           );
//                         } else if (topicsState.topics!.isEmpty) {
//                           return ListView.builder(
//                               scrollDirection: Axis.horizontal,
//                               shrinkWrap: true,
//                               itemCount: 10,
//                               itemBuilder: (context, snapshot) {
//                                 return SizedBox(
//                                   width: 100.0,
//                                   height: 80.0,
//                                   child: Shimmer.fromColors(
//                                     baseColor: Colors.grey.shade300,
//                                     highlightColor: Colors.grey.shade100,
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(15),
//                                       ),
//                                       margin: EdgeInsets.all(3),
//                                     ),
//                                   ),
//                                 );
//                               });
//                         } else {
//                           return ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             shrinkWrap: true,
//                             physics: BouncingScrollPhysics(),
//                             itemCount: topicsState.topics!.length,
//                             itemBuilder: (context, index) {
//                               return GreetingsTopicListComponent(
//                                 id: topicsState.topics![index].id,
//                                 category: topicsState.topics![index].category,
//                               );
//                             },
//                           );
//                         }
//                       },
//                     ),
//                   ),
//                   Expanded(
//                     child: Builder(
//                       builder: (context) {
//                         if (greetingsState.refreshError) {
//                           return ErrorBody(
//                             message: greetingsState.errorMessage,
//                           );
//                         } else if (greetingsState.greetings!.isEmpty) {
//                           return DelayedDisplay(
//                             // delay: Duration(seconds: 10),
//                             child: Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     FontAwesomeIcons.grinBeam,
//                                     size: 30,
//                                   ),
//                                   SizedBox(
//                                     height: 5,
//                                   ),
//                                   Text(
//                                     'Fetching Greetings',
//                                     style: TextStyle(
//                                       fontSize: 8.sp,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         } else {
//                           return LazyLoadScrollView(
//                             onEndOfPage: _loadMore,
//                             child: RefreshIndicator(
//                               onRefresh: () {
//                                 ref
//                                     .read(greetingsPaginationControllerProvider
//                                         .notifier)
//                                     .resetGreetings();
//                                 return ref
//                                     .read(greetingsPaginationControllerProvider
//                                         .notifier)
//                                     .getGreetings();
//                               },
//                               child: ListView.builder(
//                                 shrinkWrap: true,
//                                 itemCount: greetingsState.greetings!.length,
//                                 physics: BouncingScrollPhysics(),
//                                 itemBuilder: (context, index) {
//                                   return ListTile(
//                                     title: Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Stack(
//                                         children: [
//                                           Container(
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                               image: DecorationImage(
//                                                 fit: BoxFit.fill,
//                                                 image: NetworkImage(
//                                                   greetingsState
//                                                       .greetings![index].image!,
//                                                 ),
//                                               ),
//                                             ),
//                                             height: 300,
//                                             width: MediaQuery.of(context)
//                                                 .size
//                                                 .width,
//                                           ),
//                                           Positioned(
//                                             left: 0,
//                                             right: 0,
//                                             top: 0,
//                                             bottom: 0,
//                                             child: Opacity(
//                                               opacity: 0.25,
//                                               child: Image.asset(
//                                                 'assets/images/local_guru.png',
//                                                 fit: BoxFit.scaleDown,
//                                                 scale: 5,
//                                               ),
//                                             ),
//                                           ),
//                                           Positioned(
//                                             top: 0,
//                                             right: 0,
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: Container(
//                                                 width: 40,
//                                                 height: 40,
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.grey
//                                                       .withOpacity(0.8),
//                                                   borderRadius:
//                                                       BorderRadius.circular(10),
//                                                 ),
//                                                 child: IconButton(
//                                                   onPressed: () async {
//                                                     if (box.containsKey('id') &&
//                                                         box
//                                                             .get('id')!
//                                                             .isNotEmpty) {
//                                                       setState(() {
//                                                         _loading = true;
//                                                       });
//                                                       screenshotController
//                                                           .captureFromWidget(
//                                                         Stack(
//                                                           children: [
//                                                             Container(
//                                                               decoration:
//                                                                   BoxDecoration(
//                                                                 borderRadius:
//                                                                     BorderRadius
//                                                                         .circular(
//                                                                             15),
//                                                                 image:
//                                                                     DecorationImage(
//                                                                   fit: BoxFit
//                                                                       .fill,
//                                                                   image:
//                                                                       NetworkImage(
//                                                                     greetingsState
//                                                                         .greetings![
//                                                                             index]
//                                                                         .image!,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               height: 540,
//                                                               width:
//                                                                   MediaQuery.of(
//                                                                           context)
//                                                                       .size
//                                                                       .width,
//                                                             ),
//                                                             Positioned(
//                                                               bottom: 0,
//                                                               right: 0,
//                                                               child: Container(
//                                                                 padding: EdgeInsets
//                                                                     .symmetric(
//                                                                   vertical: 5,
//                                                                   horizontal:
//                                                                       10,
//                                                                 ),
//                                                                 height: 50,
//                                                                 decoration:
//                                                                     BoxDecoration(
//                                                                         color: Colors
//                                                                             .white,
//                                                                         borderRadius:
//                                                                             BorderRadius.only(
//                                                                           bottomRight:
//                                                                               Radius.circular(15),
//                                                                           topLeft:
//                                                                               Radius.circular(15),
//                                                                         ),
//                                                                         boxShadow: []),
//                                                                 child: Row(
//                                                                   children: [
//                                                                     Container(
//                                                                       decoration: BoxDecoration(
//                                                                           shape: BoxShape.circle,
//                                                                           image: DecorationImage(
//                                                                             image:
//                                                                                 NetworkImage(
//                                                                               box.get('profile')!,
//                                                                             ),
//                                                                           ),
//                                                                           boxShadow: [
//                                                                             BoxShadow(
//                                                                               color: Colors.black,
//                                                                               blurRadius: 1,
//                                                                             )
//                                                                           ]),
//                                                                       width: 35,
//                                                                       height:
//                                                                           35,
//                                                                     ),
//                                                                     SizedBox(
//                                                                       width: 5,
//                                                                     ),
//                                                                     Text(
//                                                                       box.get(
//                                                                           'name')!,
//                                                                       style:
//                                                                           TextStyle(
//                                                                         color: Colors
//                                                                             .black,
//                                                                         fontSize:
//                                                                             15,
//                                                                         fontWeight:
//                                                                             FontWeight.w800,
//                                                                         letterSpacing:
//                                                                             1.0,
//                                                                         wordSpacing:
//                                                                             0.5,
//                                                                         shadows: <
//                                                                             Shadow>[
//                                                                           Shadow(
//                                                                             blurRadius:
//                                                                                 1,
//                                                                             color:
//                                                                                 Colors.black,
//                                                                           ),
//                                                                         ],
//                                                                       ),
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             Positioned(
//                                                               top: 0,
//                                                               bottom: 0,
//                                                               right: 0,
//                                                               left: 0,
//                                                               child: Padding(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                             .all(
//                                                                         8.0),
//                                                                 child: Opacity(
//                                                                   opacity: 0.25,
//                                                                   child: Image
//                                                                       .asset(
//                                                                     'assets/images/local_guru.png',
//                                                                     fit: BoxFit
//                                                                         .scaleDown,
//                                                                     scale: 2.8,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         pixelRatio: 5,
//                                                       )
//                                                           .then((image) async {
//                                                         if (image.isNotEmpty) {
//                                                           final temp =
//                                                               await getTemporaryDirectory();
//                                                           final path =
//                                                               '${temp.path}/image.jpg';
//                                                           File(path)
//                                                               .writeAsBytesSync(
//                                                                   image);
//
//                                                           // await Share
//                                                           //     .shareFiles(
//                                                           //         [path]);
//                                                           // setState(() {
//                                                           //   _loading = false;
//                                                           // });  //Balu
//                                                         }
//                                                       });
//                                                     } else {
//                                                       ScaffoldMessenger.of(
//                                                               context)
//                                                           .showSnackBar(
//                                                         SnackBar(
//                                                           content: Text(
//                                                             'Login to share',
//                                                           ),
//                                                         ),
//                                                       );
//                                                     }
//                                                   },
//                                                   icon: Icon(
//                                                     FontAwesomeIcons
//                                                         .shareSquare,
//                                                     color: Colors.white,
//                                                     size: 20,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           );
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             _loading
//                 ? Container(
//                     width: MediaQuery.of(context).size.width,
//                     height: MediaQuery.of(context).size.height,
//                     color: Colors.white.withOpacity(0.9),
//                     child: Padding(
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             height: 70.sp,
//                             child: Image.asset(
//                               'assets/images/local_guru.png',
//                               fit: BoxFit.scaleDown,
//                             ),
//                           ),
//                           Padding(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 25.sp,
//                               vertical: 10,
//                             ),
//                             child: CircularProgressIndicator(),
//                           ),
//                           Text(
//                             'Please wait we are generating your image to share...',
//                             style: TextStyle(
//                               fontSize: 10.sp,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 : SizedBox.shrink(),
//           ],
//         ),
//       ),
//     );
//   }
// }




//////////////////



import 'dart:io';

import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import '../../../src.dart';

class GreetingsDashboard extends ConsumerStatefulWidget {
  const GreetingsDashboard({Key? key}) : super(key: key);

  @override
  _GreetingsDashboardState createState() => _GreetingsDashboardState();
}

class _GreetingsDashboardState extends ConsumerState<GreetingsDashboard> {
  _loadMore() {
    ref.read(greetingsPaginationControllerProvider.notifier).getGreetings();
  }

  ScreenshotController screenshotController = ScreenshotController();
  Box<String> box = Hive.box('user');
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(topicsGreetingsControllerProvider);
    final topicsState =
        ref.watch(topicsGreetingsControllerProvider.notifier).state;
    ref.watch(greetingsPaginationControllerProvider);
    final greetingsState =
        ref.watch(greetingsPaginationControllerProvider.notifier).state;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                    ),
                    height: 65,
                    child: Builder(
                      builder: (context) {
                        if (topicsState.refreshError) {
                          return ErrorBody(
                            message: topicsState.errorMessage,
                          );
                        } else if (topicsState.topics!.isEmpty) {
                          return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: 10,
                              itemBuilder: (context, snapshot) {
                                return SizedBox(
                                  width: 100.0,
                                  height: 80.0,
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      margin: EdgeInsets.all(3),
                                    ),
                                  ),
                                );
                              });
                        } else {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: topicsState.topics!.length,
                            itemBuilder: (context, index) {
                              return GreetingsTopicListComponent(
                                id: topicsState.topics![index].id,
                                category: topicsState.topics![index].category,
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),


                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (greetingsState.refreshError) {
                          return ErrorBody(
                            message: greetingsState.errorMessage,
                          );
                        } else if (greetingsState.greetings!.isEmpty) {
                          return DelayedDisplay(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.grinBeam,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Fetching Greetings',
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
                                    .read(greetingsPaginationControllerProvider
                                    .notifier)
                                    .resetGreetings();
                                return ref
                                    .read(greetingsPaginationControllerProvider
                                    .notifier)
                                    .getGreetings();
                              },
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: greetingsState.greetings!.length,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(15),
                                              image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: NetworkImage(
                                                  greetingsState
                                                      .greetings![index].image!,
                                                ),
                                              ),
                                            ),
                                            height: 300,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                          ),
                                          Positioned(
                                            left: 0,
                                            right: 0,
                                            top: 0,
                                            bottom: 0,
                                            child: Opacity(
                                              opacity: 0.25,
                                              child: Image.asset(
                                                'assets/images/local_guru.png',
                                                fit: BoxFit.scaleDown,
                                                scale: 5,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(8.0),
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(0.8),
                                                  borderRadius:
                                                  BorderRadius.circular(10),
                                                ),
                                                child: IconButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      _loading = true;
                                                    });
                                                    screenshotController
                                                        .captureFromWidget(
                                                      Stack(
                                                        children: [
                                                          Container(
                                                            decoration:
                                                            BoxDecoration(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  15),
                                                              image:
                                                              DecorationImage(
                                                                fit: BoxFit
                                                                    .fill,
                                                                image:
                                                                NetworkImage(
                                                                  greetingsState
                                                                      .greetings![
                                                                  index]
                                                                      .image!,
                                                                ),
                                                              ),
                                                            ),
                                                            height: 540,
                                                            width: MediaQuery.of(
                                                                context)
                                                                .size
                                                                .width,
                                                          ),
                                                          Positioned(
                                                            top: 0,
                                                            bottom: 0,
                                                            right: 0,
                                                            left: 0,
                                                            child: Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .all(
                                                                  8.0),
                                                              child: Opacity(
                                                                opacity: 0.25,
                                                                child: Image
                                                                    .asset(
                                                                  'assets/images/local_guru.png',
                                                                  fit: BoxFit
                                                                      .scaleDown,
                                                                  scale: 2.8,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      pixelRatio: 5,
                                                    )
                                                        .then((image) async {

                                                      if (image.isNotEmpty) {
                                                        final temp = await getTemporaryDirectory();
                                                        final path = '${temp.path}/image.jpg';
                                                        File(path).writeAsBytesSync(image);

                                                        XFile file = XFile(path); // Create XFile from file path
                                                        await Share.shareXFiles([file]);

                                                        setState(() {
                                                          _loading = false;
                                                        });
                                                      }
                                                    });
                                                  },
                                                  icon: Icon(
                                                    FontAwesomeIcons
                                                        .shareSquare,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
            _loading
                ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 70.sp,
                      child: Image.asset(
                        'assets/images/local_guru.png',
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25.sp,
                        vertical: 10,
                      ),
                      child: CircularProgressIndicator(),
                    ),
                    Text(
                      'Please wait we are generating your image to share...',
                      style: TextStyle(
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}