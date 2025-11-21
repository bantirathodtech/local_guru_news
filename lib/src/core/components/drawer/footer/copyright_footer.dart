import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/app_colors.dart';

class CopyrightFooter extends StatelessWidget {
  const CopyrightFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? 
                     (theme.brightness == Brightness.dark 
                      ? Colors.white70 
                      : AppColors.textSecondary);
    
    return Container(
      padding: const EdgeInsets.only(bottom: 16), // 16px space from bottom
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Copyright \u00a9 ${DateTime.now().year} ',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    letterSpacing: 1,
                    fontSize: 12,
                  ),
                ),
                TextSpan(
                  text: 'Suvidha Softwares.',
                  style: TextStyle(
                    color: AppColors.accent,
                    letterSpacing: 1,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
                    color: textColor.withOpacity(0.6),
                    letterSpacing: 1,
                    fontSize: 12,
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
