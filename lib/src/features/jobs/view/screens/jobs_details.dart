import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:sizer/sizer.dart';

class JobDetails extends StatelessWidget {
  final String? title;
  final String? location;
  final String? salary;
  final String? type;
  final String? role;
  final String? qualification;
  final String? description;
  final String? contact;
  final String? customlocation;
  const JobDetails({
    Key? key,
    @required this.title,
    @required this.location,
    @required this.salary,
    @required this.type,
    @required this.role,
    @required this.qualification,
    @required this.description,
    @required this.contact,
    @required this.customlocation,
  }) : super(key: key);
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
              horizontal: 25,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    wordSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  location!,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w200,
                    fontSize: 10.sp,
                    letterSpacing: 0.8,
                    wordSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Job Details',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    wordSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Salary',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    wordSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  salary!,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.8,
                    wordSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Job Type',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    wordSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  type!,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.8,
                    wordSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Qualification',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    wordSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  qualification!,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.8,
                    wordSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Number of hires for this role',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    wordSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  int.parse(role.toString()) < 20
                      ? role! + ' Candidates Required'
                      : 'Hiring Multiple Candidates',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.8,
                    wordSpacing: 0.5,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Text(
                  'Full Job Description',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    wordSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Html(
                  data: description!,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Contact',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    wordSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  contact!,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.8,
                    wordSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Location',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    wordSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  customlocation!,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.8,
                    wordSpacing: 0.5,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
