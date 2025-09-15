import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/app_localization.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(
        body: Center(child: Text('Localization not available')),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    final isLandscape = screenWidth > screenHeight;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E88E5), Color(0xFF1565C0), Color(0xFF0D47A1)],
            ),
          ),
          child: SafeArea(
            child: _buildResponsiveLayout(
              localizations,
              isTablet,
              isDesktop,
              isLandscape,
              screenWidth,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(
    AppLocalizations localizations,
    bool isTablet,
    bool isDesktop,
    bool isLandscape,
    double screenWidth,
  ) {
    if (isDesktop || (isLandscape && screenWidth > 800)) {
      return _buildDesktopLayout(localizations, screenWidth);
    } else {
      return _buildMobileLayout(localizations, isTablet);
    }
  }

  Widget _buildDesktopLayout(
    AppLocalizations localizations,
    double screenWidth,
  ) {
    return Row(
      children: [
        // Left side - Hero section
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.task_alt,
                  size: 120,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 32),
                Text(
                  localizations.appName,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  localizations.manageTasksEfficiently,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Streamline your workflow with our comprehensive task management solution designed for modern teams.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right side - Login form
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    localizations.welcomeBack,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localizations.welcomeBackMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 48),
                  _buildGoogleSignInButton(localizations, isLarge: true),
                  const SizedBox(height: 32),
                  Text(
                    localizations.termsPrivacyMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AppLocalizations localizations, bool isTablet) {
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
          _buildGoogleSignInButton(localizations, isLarge: isTablet),

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

  Widget _buildGoogleSignInButton(
    AppLocalizations localizations, {
    required bool isLarge,
  }) {
    final buttonHeight = isLarge ? 64.0 : 56.0;
    final iconSize = isLarge ? 28.0 : 24.0;
    final fontSize = isLarge ? 18.0 : 16.0;
    final horizontalPadding = isLarge ? 24.0 : 20.0;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return Container(
            height: buttonHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
              ),
            ),
          );
        }

        return Container(
          height: buttonHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.read<AuthBloc>().add(AuthSignInRequested());
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize - 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isLarge ? 20 : 16),
                    Text(
                      localizations.continueWithGoogle,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF424242),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
