import 'package:flutter/material.dart';
import 'package:local_guru_all/src/core/components/appBar/app_bar.dart';
import 'package:local_guru_all/src/src.dart';

import '../../../../core/constants/app_colors.dart';

class JobComing extends StatelessWidget {
  const JobComing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Jobs',
        backgroundColor: AppColors.primary,
        iconColor: AppColors.black,
        titleColor: AppColors.black,
      ),
      drawer: const CustomDrawer(),
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/coming_soon.jpg',
                fit: BoxFit.scaleDown,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
                  'assets/images/local_guru.png',
                  fit: BoxFit.scaleDown,
                  color: Colors.white,
                  scale: 7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
