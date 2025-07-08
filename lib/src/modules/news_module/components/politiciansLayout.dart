import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PoliticianLayout extends StatelessWidget {
  final String? name;
  final String? profile;
  final String? status;
  const PoliticianLayout({
    this.name,
    this.profile,
    this.status,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 10,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        width: 110,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 6.h,
                width: 10.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(profile!),
                  ),
                ),
              ),
              SizedBox(
                height: 1.h,
              ),
              Text(
                name!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 1.h,
              ),
              Container(
                margin: EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    status! == '0' ? 'Follow' : 'Unfollow',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.blue,
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
