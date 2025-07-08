import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:local_guru_all/src/models/requirementsModel.dart';
import 'package:local_guru_all/src/views/requirementsScreen.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../src.dart';

class DrawerComponent extends StatefulWidget {
  const DrawerComponent({Key? key}) : super(key: key);

  @override
  _DrawerComponentState createState() => _DrawerComponentState();
}

class _DrawerComponentState extends State<DrawerComponent> {
  Box<String> box = Hive.box('user');
  String contact = '';

  @override
  void initState() {
    for (int i = 0; i < box.get('contact')!.length; i++) {
      if (i < 4) {
        contact = contact + box.get('contact')![i];
      } else {
        contact = contact + '*';
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = new DateTime.now();
    final String year = DateFormat.y().format(dateTime);
    return Consumer(
      builder: (context, ref, child) {
        AsyncValue<List<LocationModel>> location =
            ref.watch(fetchLocation); //Location
        AsyncValue<List<RequirementsModel>> requirementsMenu =
            ref.watch(fetchRequirementsMenu);
        return Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.close,
                      size: 15.sp,
                    ),
                  ),
                ),
                Container(
                  height: 13.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                        box.get('profile')!,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 1.h,
                  ),
                  child: Text(
                    box.get('name')!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                Text(
                  contact,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.7,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.person_pin_rounded,
                        size: 15.sp,
                      ),
                      label: Text(
                        'ప్రొఫైల్',
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 2.h,
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocationScreen(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.location_pin,
                        size: 15.sp,
                      ),
                      label: Text(
                        'ప్రాంతం',
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 0.2.h,
                    horizontal: 8.h,
                  ),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 1.h,
                  ),
                  child: Container(
                    height: 42.h,
                    child: Column(
                      children: [
                        Text(
                          'సమీప ప్రాంతాలు',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          '[ మీరు ఎంచుకున్న ప్రాంతం ${ref.watch(selectedLocation)}]',
                          style: TextStyle(
                            fontSize: 10.sp,
                          ),
                        ),
                        SizedBox(
                          height: 0.5.h,
                        ),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 1.h,
                              horizontal: 1.5.h,
                            ),
                            color: Colors.grey.withOpacity(0.01),
                            child: location.when(
                              data: (locationData) {
                                List<Landmark> nearbyLocations = [];

                                for (int i = 0; i < locationData.length; i++) {
                                  if (locationData[i].id == box.get('state')) {
                                    for (int j = 0;
                                        j < locationData[i].districts!.length;
                                        j++) {
                                      if (locationData[i].districts![j].id ==
                                          box.get('district')) {
                                        for (int k = 0;
                                            k <
                                                locationData[i]
                                                    .districts![j]
                                                    .landmarks!
                                                    .length;
                                            k++) {
                                          nearbyLocations.add(locationData[i]
                                              .districts![j]
                                              .landmarks![k]);
                                        }
                                      }
                                    }
                                  }
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  itemCount: nearbyLocations.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        box.put('landmark',
                                            nearbyLocations[index].id!);
                                        ref
                                            .read(locationLandmark.notifier)
                                            .state = nearbyLocations[index].id!;
                                        box.put('location',
                                            nearbyLocations[index].name!);
                                        ref
                                                .read(selectedLocation.notifier)
                                                .state =
                                            nearbyLocations[index].name!;
                                        ref
                                            .refresh(topicsControllerProvider)
                                            .resetTopics();
                                        ref
                                            .refresh(topicsControllerProvider
                                                .notifier)
                                            .getTopics();
                                        ref
                                            .refresh(
                                                postPaginationControllerProvider
                                                    .notifier)
                                            .resetPosts();
                                        ref
                                            .refresh(
                                                postPaginationControllerProvider
                                                    .notifier)
                                            .getPosts();
                                        Navigator.of(context).pop();
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 5,
                                        ),
                                        child: Row(
                                          children: [
                                            ref
                                                        .watch(locationLandmark
                                                            .state)
                                                        .state ==
                                                    nearbyLocations[index].id!
                                                ? Icon(
                                                    Icons.location_pin,
                                                    size: 12.sp,
                                                    color: Colors.blue,
                                                  )
                                                : SizedBox.shrink(),
                                            SizedBox(
                                              width: 1.h,
                                            ),
                                            Text(
                                              nearbyLocations[index].name!,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: ref
                                                            .watch(
                                                                locationLandmark
                                                                    .state)
                                                            .state ==
                                                        nearbyLocations[index]
                                                            .id!
                                                    ? Colors.blue
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
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
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.h,
                  ),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 30,
                  ),
                  child: requirementsMenu.when(
                    data: (requirementsMenuData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: requirementsMenuData.length,
                        itemBuilder: (context, index) {
                          return ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RequirementsScreen(
                                    name: requirementsMenuData[index].name,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              requirementsMenuData[index].name!,
                            ),
                          );
                          // return InkWell(
                          //   onTap: () {
                          //     Navigator.pop(context);
                          //     // Navigator.push(
                          //     //   context,
                          //     //   MaterialPageRoute(
                          //     //     builder: (context) => RequirementsScreen(
                          //     //       name: requirementsMenuData[index].name,
                          //     //     ),
                          //     //   ),
                          //     // );
                          //   },
                          //   child: DawerMenuComponent(
                          //     title: requirementsMenuData[index].name,
                          //     val: false,
                          //     hasIcon: false,
                          //   ),
                          // );
                        },
                      );
                    },
                    loading: () {
                      return Center(
                        child: Text(
                          "Loading....",
                          style: TextStyle(
                            color: primaryColor,
                          ),
                        ),
                      );
                    },
                    error: (e, stack) => null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 50,
                  ),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Container(
                  height: 8.h,
                  padding: EdgeInsets.symmetric(
                    horizontal: 1.h,
                    vertical: 1.h,
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            letterSpacing: 1,
                            fontSize: 12.sp,
                          ),
                          text: "Copyright \u00a9 " + year + " ",
                        ),
                        TextSpan(
                          style: TextStyle(
                            color: Colors.blue,
                            letterSpacing: 1,
                            fontSize: 12.sp,
                          ),
                          text: "Suvidha Softwares.",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              final url = 'https://suvidhasoft.com/';
                              if (await canLaunch(url)) {
                                await launch(
                                  url,
                                  forceSafariVC: false,
                                );
                              }
                            },
                        ),
                        TextSpan(
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.4),
                            letterSpacing: 1,
                            fontSize: 12.sp,
                          ),
                          text: "All rights reserved",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DawerMenuComponent extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Function? tap;
  final bool? val;
  final bool? hasIcon;

  const DawerMenuComponent({
    this.title,
    this.icon,
    this.tap,
    this.val,
    this.hasIcon,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 10,
      ),
      child: InkWell(
        onTap: () => tap,
        child: Card(
          color: val! ? Colors.grey.withOpacity(0.2) : primaryColor,
          elevation: 0,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: val! ? Colors.transparent : primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                hasIcon!
                    ? FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Icon(
                          icon,
                          size: 25,
                          color: val! ? primaryColor : Colors.white,
                        ),
                      )
                    : SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title!,
                      style: TextStyle(
                        letterSpacing: 1.2,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: val! ? primaryColor : Colors.white,
                      ),
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
