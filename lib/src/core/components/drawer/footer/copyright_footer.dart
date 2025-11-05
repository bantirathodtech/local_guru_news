import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/app_colors.dart';

class CopyrightFooter extends StatelessWidget {
  const CopyrightFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16), // 16px space from bottom
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Copyright \u00a9 ${DateTime.now().year} ',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    letterSpacing: 1,
                  ),
                ),
                TextSpan(
                  text: 'Suvidha Softwares.',
                  style: const TextStyle(
                    color: AppColors.primary,
                    letterSpacing: 1,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      const url = 'https://suvidhasoft.com/';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                ),
                TextSpan(
                  text: ' All rights reserved',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    letterSpacing: 1,
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
