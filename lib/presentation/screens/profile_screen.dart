import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/localization/locale_bloc.dart';
import '../bloc/localization/locale_event.dart';
import '../bloc/localization/locale_state.dart';
import '../bloc/userprofile/user_bloc.dart';
import '../bloc/userprofile/user_event.dart';
import '../bloc/userprofile/user_state.dart';
import '../../core/app_localization.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load user data when screen initializes
    context.read<UserBloc>().add(UserLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          localizations.profile,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            onPressed: () => _showSignOutDialog(context),
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
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
        child: BlocListener<LocaleBloc, LocaleState>(
          listener: (context, localeState) {
            if (localeState is LocaleLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.languageChanged),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: BlocBuilder<UserBloc, UserState>(
                    builder: (context, userState) {
                      return BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          if (userState is UserLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          String name = 'Unknown User';
                          String email = 'No email';
                          String? photoUrl;

                          if (userState is UserLoaded) {
                            name = userState.user.name;
                            email = userState.user.email;
                            photoUrl = userState.user.photoUrl;
                          } else if (authState is AuthAuthenticated) {
                            name = authState.user.name;
                            email = authState.user.email;
                            photoUrl = authState.user.photoUrl;
                          }

                          return Column(
                            children: [
                              // Profile Picture
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF1E88E5),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 47,
                                  backgroundColor: const Color(0xFF1E88E5),
                                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                                      ? NetworkImage(photoUrl)
                                      : null,
                                  child: photoUrl == null || photoUrl.isEmpty
                                      ? Text(
                                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Name
                              Text(
                                name.isEmpty ? 'Unknown User' : name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Email
                              Text(
                                email.isEmpty ? 'No email' : email,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Profile Options
                _buildProfileOption(
                  context: context,
                  icon: Icons.person_outline,
                  title: localizations.editProfile,
                  subtitle: localizations.updatePersonalInfo,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizations.comingSoon(localizations.editProfile))),
                    );
                  },
                ),
                
                const SizedBox(height: 12),
                
                _buildProfileOption(
                  context: context,
                  icon: Icons.notifications_outlined,
                  title: localizations.notifications,
                  subtitle: localizations.manageNotificationPreferences,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizations.comingSoon(localizations.notifications))),
                    );
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Language Setting with actual functionality
                _buildLanguageOption(context),
                
                const SizedBox(height: 12),
                
                _buildProfileOption(
                  context: context,
                  icon: Icons.help_outline,
                  title: localizations.helpSupport,
                  subtitle: localizations.getHelpSupport,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizations.comingSoon(localizations.helpSupport))),
                    );
                  },
                ),
                
                const SizedBox(height: 12),
                
                _buildProfileOption(
                  context: context,
                  icon: Icons.info_outline,
                  title: localizations.about,
                  subtitle: localizations.learnMoreAboutApp,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizations.comingSoon(localizations.about))),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is AuthLoading 
                            ? null 
                            : () => _showSignOutDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: state is AuthLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.logout),
                                  const SizedBox(width: 8),
                                  Text(
                                    localizations.signOut,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1E88E5),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, localeState) {
        String currentLanguage = localizations.english;
        if (localeState is LocaleLoaded) {
          currentLanguage = localeState.locale.languageCode == AppConstants.hindiCode 
              ? localizations.hindi 
              : localizations.english;
        }
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.language,
                color: Color(0xFF1E88E5),
                size: 20,
              ),
            ),
            title: Text(
              localizations.language,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              currentLanguage,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () => _showLanguageDialog(context),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocBuilder<LocaleBloc, LocaleState>(
          builder: (context, localeState) {
            String currentLanguageCode = AppConstants.englishCode;
            if (localeState is LocaleLoaded) {
              currentLanguageCode = localeState.locale.languageCode;
            }
            
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(localizations.selectLanguage),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Radio<String>(
                      value: AppConstants.englishCode,
                      groupValue: currentLanguageCode,
                      onChanged: (String? value) {
                        if (value != null) {
                          context.read<LocaleBloc>().add(
                            LocaleChanged(Locale(value)),
                          );
                          Navigator.of(dialogContext).pop();
                        }
                      },
                    ),
                    title: Text(localizations.english),
                    subtitle: const Text('English'),
                    onTap: () {
                      context.read<LocaleBloc>().add(
                        const LocaleChanged(Locale(AppConstants.englishCode)),
                      );
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                  ListTile(
                    leading: Radio<String>(
                      value: AppConstants.hindiCode,
                      groupValue: currentLanguageCode,
                      onChanged: (String? value) {
                        if (value != null) {
                          context.read<LocaleBloc>().add(
                            LocaleChanged(Locale(value)),
                          );
                          Navigator.of(dialogContext).pop();
                        }
                      },
                    ),
                    title: Text(localizations.hindi),
                    subtitle: const Text('हिन्दी'),
                    onTap: () {
                      context.read<LocaleBloc>().add(
                        const LocaleChanged(Locale(AppConstants.hindiCode)),
                      );
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(localizations.cancel),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(localizations.signOut),
          content: Text(localizations.signOutConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(AuthSignOutRequested());
              },
              child: Text(
                localizations.signOut,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}