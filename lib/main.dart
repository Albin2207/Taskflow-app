import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/dependency_injection.dart' as di;
import 'core/dependency_injection.dart';
import 'core/global_nav_handler.dart';
import 'core/theme.dart';
import 'core/app_localization.dart';
import 'firebase_options.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/connectivity/connectivity_bloc.dart';
import 'presentation/bloc/localization/locale_bloc.dart';
import 'presentation/bloc/localization/locale_event.dart';
import 'presentation/bloc/localization/locale_state.dart';
import 'presentation/bloc/notification/notification_bloc.dart';
import 'presentation/bloc/userlist/userlist_bloc.dart';
import 'presentation/bloc/userlist/userlist_event.dart';
import 'presentation/bloc/userprofile/user_bloc.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize dependency injection
  await di.init();

  // Preload default locale
  AppLocalizations localizations = AppLocalizations(const Locale('en'));
  await localizations.load();

  runApp(const MyApp());
}

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set the navigator key for global navigation handler
    GlobalNavigationHandler.setNavigatorKey(_navigatorKey);

    return MultiBlocProvider(
      providers: [
        // Locale BLoC - should be first to provide localization context
        BlocProvider<LocaleBloc>(
          create: (context) => LocaleBloc()..add(LocaleLoadRequested()),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<UserBloc>(create: (context) => di.sl<UserBloc>()),
        BlocProvider<ConnectivityBloc>(
          create:
              (context) =>
                  di.sl<ConnectivityBloc>()..add(ConnectivityStarted()),
        ),
        BlocProvider<NotificationBloc>(
          create:
              (context) =>
                  sl<NotificationBloc>()..add(NotificationInitialize()),
        ),
        BlocProvider<UsersBloc>(
          create: (context) {
            final notificationBloc = BlocProvider.of<NotificationBloc>(context);
            return UsersBloc(
              getUsersUseCase: sl(),
              createUserUseCase: sl(),
              updateUserUseCase: sl(),
              deleteUserUseCase: sl(),
              notificationBloc: notificationBloc,
            );
          },
        ),
      ],
      child: BlocListener<ConnectivityBloc, ConnectivityState>(
        listener: (context, state) {
          // Handle global connectivity changes
          if (state is ConnectivityDisconnected) {
            GlobalNavigationHandler.handleConnectivityChange(false);
          } else if (state is ConnectivityRestored) {
            // Trigger data refresh when connectivity is restored
            context.read<UsersBloc>().add(
              const LoadUsersEvent(isRefresh: true),
            );
            GlobalNavigationHandler.handleConnectivityChange(true);
          }
        },
        child: BlocBuilder<LocaleBloc, LocaleState>(
          builder: (context, localeState) {
            // Default to English if locale is not loaded
            Locale currentLocale = const Locale('en');
            if (localeState is LocaleLoaded) {
              currentLocale = localeState.locale;
            }

            return BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, notificationState) {
                return MaterialApp(
                  title: 'TaskFlow',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  home: const SplashScreen(),
                  navigatorKey: _navigatorKey,

                  // Define named routes
                  routes: {'/home': (context) => const HomeScreen()},

                  // Handle route arguments
                  onGenerateRoute: (settings) {
                    switch (settings.name) {
                      case '/home':
                        final args =
                            settings.arguments as Map<String, dynamic>?;
                        return MaterialPageRoute(
                          builder: (context) {
                            // If shouldRefresh is true, trigger data refresh
                            if (args?['shouldRefresh'] == true) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                context.read<UsersBloc>().add(
                                  const LoadUsersEvent(isRefresh: true),
                                );
                              });
                            }
                            return const HomeScreen();
                          },
                          settings: settings,
                        );
                      default:
                        return null;
                    }
                  },

                  // Locale configuration
                  locale: currentLocale,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: AppLocalizations.supportedLocales,

                  // Fallback for unsupported locales
                  localeResolutionCallback: (locale, supportedLocales) {
                    // If the current locale is supported, use it
                    for (var supportedLocale in supportedLocales) {
                      if (supportedLocale.languageCode ==
                          locale?.languageCode) {
                        return supportedLocale;
                      }
                    }
                    // Fallback to English
                    return const Locale('en');
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class NotificationNavigationHandler {
  static void handleNotificationNavigation(
    String route,
    Map<String, dynamic> data,
  ) {
    final navigator = _navigatorKey.currentState;
    if (navigator != null) {
      switch (route) {
        case '/users':
          navigator.pushNamedAndRemoveUntil('/home', (route) => false);
          break;
        case '/profile':
          navigator.pushNamedAndRemoveUntil('/profile', (route) => false);
          break;
        case '/home':
        default:
          navigator.pushNamedAndRemoveUntil('/home', (route) => false);
          break;
      }
    }
  }
}
