import 'package:carousel_slider/carousel_slider.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ListsDetails extends StatefulWidget {
  final String? id;
  final String? title;
  final String? description;
  final List<String>? media;
  final DateTime? time;
  final String? customlocation;
  final String? contact;
  final String? readableTime;
  final String? location;
  const ListsDetails(
      {Key? key,
      @required this.id,
      @required this.title,
      @required this.description,
      @required this.media,
      @required this.time,
      @required this.customlocation,
      @required this.contact,
      @required this.readableTime,
      @required this.location})
      : super(key: key);

  @override
  _ListsDetailsState createState() => _ListsDetailsState();
}

class _ListsDetailsState extends State<ListsDetails> {
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.chevron_left_rounded,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CarouselSlider(
                  items: widget.media!.map<Widget>((e) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      child: FancyShimmerImage(
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        imageUrl: e,
                        boxFit: BoxFit.contain,
                      ),
                    );
                  }).toList(),
                  options: CarouselOptions(
                      // height: ResponsiveService.isMobile(context)
                      //     ? 250
                      //     : ResponsiveService.isTablet(context)
                      //         ? 400
                      //         : 620,
                      height: 30.h,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      viewportFraction: 1.0,
                      reverse: false,
                      autoPlay: widget.media!.length > 1 ? true : false,
                      autoPlayInterval: Duration(seconds: 5),
                      autoPlayCurve: Curves.ease,
                      scrollDirection: Axis.horizontal,
                      disableCenter: false,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      }),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  widget.title!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                    letterSpacing: 0.5,
                    wordSpacing: 0.2,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  widget.readableTime!,
                  style: TextStyle(
                    fontSize: 10.sp,
                    letterSpacing: 0.5,
                    wordSpacing: 0.2,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  widget.description!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    letterSpacing: 0.5,
                    wordSpacing: 0.2,
                    height: 1.5,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  widget.contact!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    letterSpacing: 0.5,
                    wordSpacing: 0.2,
                    height: 1.5,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  widget.customlocation!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    letterSpacing: 0.5,
                    wordSpacing: 0.2,
                    height: 1.5,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
