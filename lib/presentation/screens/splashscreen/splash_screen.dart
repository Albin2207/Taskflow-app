import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_localization.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../loginscreen/login_screen.dart';
import '../mainscreen/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AppLocalizations localizations;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final locale = Localizations.localeOf(context);
    localizations = AppLocalizations(locale);
    await localizations.load();

    // Optional: delay to show splash for at least 1.5 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Check auth state once after delay
    // ignore: use_build_context_synchronously
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _navigateTo(const HomeScreen());
    } else if (authState is AuthUnauthenticated) {
      _navigateTo(const LoginScreen());
    } else {
      // If still loading, listen for changes
      // ignore: use_build_context_synchronously
      context.read<AuthBloc>().stream.listen((state) {
        if (state is AuthAuthenticated) {
          _navigateTo(const HomeScreen());
        } else if (state is AuthUnauthenticated) {
          _navigateTo(const LoginScreen());
        }
      });
    }
  }

  void _navigateTo(Widget screen) {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E88E5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.task_alt, size: 80, color: Colors.white),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
