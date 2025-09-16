import 'package:flutter/material.dart';
import '../../../../core/app_localization.dart';
import 'google_signin_button.dart';

class MobileLayoutWidget extends StatelessWidget {
  final AppLocalizations localizations;
  final bool isTablet;

  const MobileLayoutWidget({
    super.key,
    required this.localizations,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = isTablet ? 100.0 : 80.0;
    final titleFontSize = isTablet ? 40.0 : 32.0;
    final subtitleFontSize = isTablet ? 20.0 : 16.0;
    final welcomeFontSize = isTablet ? 32.0 : 28.0;
    final messageFontSize = isTablet ? 18.0 : 16.0;
    final padding = isTablet ? 32.0 : 24.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),

          // App Icon and Title
          Icon(Icons.task_alt, size: iconSize, color: Colors.white),
          SizedBox(height: isTablet ? 32 : 24),
          Text(
            localizations.appName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            localizations.manageTasksEfficiently,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: subtitleFontSize, color: Colors.white70),
          ),
          SizedBox(height: isTablet ? 80 : 60),

          // Welcome Text
          Text(
            localizations.welcomeBack,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: welcomeFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            localizations.welcomeBackMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: messageFontSize, color: Colors.white70),
          ),
          SizedBox(height: isTablet ? 48 : 40),

          // Google Sign In Button
          GoogleSignInButtonWidget(
            localizations: localizations,
            isLarge: isTablet,
          ),

          const Spacer(),

          // Terms and Privacy
          Text(
            localizations.termsPrivacyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
