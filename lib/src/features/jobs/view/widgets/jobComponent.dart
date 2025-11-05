import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class JobLayoutComponent extends StatelessWidget {
  final String? title;
  final String? description;
  final String? salary;
  final String? hiring;
  final String? location;
  const JobLayoutComponent({
    Key? key,
    @required this.title,
    @required this.description,
    @required this.salary,
    @required this.hiring,
    @required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 1.7.h,
        vertical: 1.5.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    wordSpacing: 0.1,
                    fontSize: 12.5.sp,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  description!,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      salary!,
                      style: TextStyle(
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.phoneAlt,
                      size: 10.sp,
                      color: Colors.blue,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Apply From your Phone',
                      style: TextStyle(
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.users,
                      size: 10.sp,
                      color: Colors.orange,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      int.parse(hiring.toString()) < 20
                          ? hiring! + ' Candidates Required'
                          : 'Hiring Multiple Candidates',
                      style: TextStyle(
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                RichText(
                  text: TextSpan(
                    text: 'Hiring ongoing • From  ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 9.sp,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: location!,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 9.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(
          //   width: 17,
          // ),
          // Expanded(
          //   child: Column(
          //     children: [
          //       Icon(
          //         FontAwesomeIcons.heart,
          //         size: 18,
          //       ),
          //       SizedBox(
          //         height: 13,
          //       ),
          //       Icon(
          //         FontAwesomeIcons.ban,
          //         size: 18,
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
