import 'package:flutter/material.dart';

class ComingSoon extends StatelessWidget {
  const ComingSoon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        // mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
