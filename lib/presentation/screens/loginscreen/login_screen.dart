import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_localization.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../mainscreen/home_screen.dart';
import 'widgets/desktop_layout.dart';
import 'widgets/mobile_layout.dart';

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
      return DesktopLayoutWidget(
        localizations: localizations,
        screenWidth: screenWidth,
      );
    } else {
      return MobileLayoutWidget(
        localizations: localizations,
        isTablet: isTablet,
      );
    }
  }
}
