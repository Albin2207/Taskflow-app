import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;
  bool _isLoaded = false;

  AppLocalizations(this.locale);

  // Improved getter with null safety
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Helper method to get localization safely with fallback
  static AppLocalizations getSafeLocalizations(BuildContext context) {
    final localizations = of(context);
    if (localizations != null && localizations._isLoaded) {
      return localizations;
    }

    // Fallback - create English localizations
    final fallback = AppLocalizations(const Locale('en'));
    fallback._initializeFallbackStrings();
    return fallback;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('hi')];

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/i18n/${locale.languageCode}.json',
      );
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });

      _isLoaded = true;
      return true;
    } catch (e) {
      print('Error loading localization file: $e');

      // Try fallback to English if not already English
      if (locale.languageCode != 'en') {
        try {
          String jsonString = await rootBundle.loadString(
            'assets/i18n/en.json',
          );
          Map<String, dynamic> jsonMap = json.decode(jsonString);
          _localizedStrings = jsonMap.map((key, value) {
            return MapEntry(key, value.toString());
          });
          _isLoaded = true;
          return true;
        } catch (e) {
          print('Error loading fallback English localization: $e');
        }
      }

      // Ultimate fallback - initialize with hardcoded English strings
      _initializeFallbackStrings();
      return false;
    }
  }

  // Initialize with hardcoded English strings as ultimate fallback
  void _initializeFallbackStrings() {
    _localizedStrings = {
      'app_name': 'TaskFlow',
      'manage_tasks_efficiently': 'Manage your tasks efficiently',
      'home': 'Home',
      'profile': 'Profile',
      'users': 'Users',
      'welcome': 'Welcome',
      'welcome_back': 'Welcome Back',
      'good_morning': 'Good Morning',
      'add': 'Add',
      'create': 'Create',
      'edit': 'Edit',
      'delete': 'Delete',
      'save': 'Save',
      'cancel': 'Cancel',
      'view': 'View',
      'update': 'Update',
      'refresh': 'Refresh',
      'retry': 'Retry',
      'try_again': 'Try Again',
      'login': 'Login',
      'logout': 'Logout',
      'sign_out': 'Sign Out',
      'continue_with_google': 'Continue with Google',
      'first_name': 'First Name',
      'last_name': 'Last Name',
      'email': 'Email',
      'avatar_url': 'Avatar URL',
      'create_user': 'Create User',
      'edit_user': 'Edit User',
      'update_user': 'Update User',
      'delete_user': 'Delete User',
      'user_details': 'User Details',
      'add_user': 'Add User',
      'total_users': 'Total Users',
      'current_page': 'Current Page',
      'details': 'Details',
      'preview': 'Preview',
      'user_information': 'User Information',
      'edit_profile': 'Edit Profile',
      'notifications': 'Notifications',
      'language': 'Language',
      'help_support': 'Help & Support',
      'about': 'About',
      'no_internet_connection': 'No Internet Connection',
      'check_internet_connection':
          'Please check your internet connection and try again. The app will automatically reload when connection is restored.',
      'offline_action_not_available': 'This action is not available offline',
      'currently_offline':
          'You are currently offline. Please connect to the internet to save changes.',
      'offline_edit_delete_disabled':
          'You are currently offline. Edit and delete actions are disabled.',
      'checking_connection': 'Checking connection...',
      'error_loading_users': 'Error loading users',
      'no_users_found': 'No users found',
      'add_first_user': 'Tap the + button to add your first user',
      'delete_user_confirmation': 'Are you sure you want to delete {userName}?',
      'sign_out_confirmation': 'Are you sure you want to sign out?',
      'user_created_success': 'User created successfully',
      'user_updated_success': 'User updated successfully',
      'user_deleted_success': 'User deleted successfully',
      'please_enter_first_name': 'Please enter first name',
      'please_enter_last_name': 'Please enter last name',
      'please_enter_email': 'Please enter email',
      'please_enter_valid_email': 'Please enter a valid email',
      'please_enter_valid_url': 'Please enter a valid URL',
      'avatar_url_optional': 'Optional: Enter image URL for user avatar',
      'creating': 'Creating...',
      'updating': 'Updating...',
      'welcome_back_message': 'Sign in to continue with your tasks',
      'terms_privacy_message':
          'By continuing, you agree to our Terms of Service and Privacy Policy',
      'update_personal_info': 'Update your personal information',
      'manage_notification_preferences': 'Manage notification preferences',
      'get_help_support': 'Get help and support',
      'learn_more_about_app': 'Learn more about TaskFlow',
      'select_language': 'Select Language',
      'english': 'English',
      'hindi': 'हिन्दी',
      'language_changed': 'Language changed successfully',
      'coming_soon': '{feature} coming soon!',
      'test_notification': 'Test Notification',
      'task_flow': 'TaskFlow',
      'user': 'User',
      'test_notification_tooltip': 'Test Notification',
      'id': 'ID',
    };
    _isLoaded = true;
  }

  String _translate(String key, [Map<String, String>? params]) {
    if (!_isLoaded) {
      return key; // Return key if not loaded yet
    }

    String translation = _localizedStrings[key] ?? key;

    // Handle parameters if provided
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        translation = translation.replaceAll('{$paramKey}', paramValue);
      });
    }

    return translation;
  }

  // App Info
  String get appName => _translate('app_name');
  String get manageTasksEfficiently => _translate('manage_tasks_efficiently');

  // Navigation
  String get home => _translate('home');
  String get profile => _translate('profile');
  String get users => _translate('users');

  // Greetings
  String get welcome => _translate('welcome');
  String get welcomeBack => _translate('welcome_back');
  String get goodMorning => _translate('good_morning');

  // Actions
  String get add => _translate('add');
  String get create => _translate('create');
  String get edit => _translate('edit');
  String get delete => _translate('delete');
  String get save => _translate('save');
  String get cancel => _translate('cancel');
  String get view => _translate('view');
  String get update => _translate('update');
  String get refresh => _translate('refresh');
  String get retry => _translate('retry');
  String get tryAgain => _translate('try_again');

  // Auth
  String get login => _translate('login');
  String get logout => _translate('logout');
  String get signOut => _translate('sign_out');
  String get continueWithGoogle => _translate('continue_with_google');

  // Form Fields
  String get firstName => _translate('first_name');
  String get lastName => _translate('last_name');
  String get email => _translate('email');
  String get avatarUrl => _translate('avatar_url');

  // User Management
  String get createUser => _translate('create_user');
  String get editUser => _translate('edit_user');
  String get updateUser => _translate('update_user');
  String get deleteUser => _translate('delete_user');
  String get userDetails => _translate('user_details');
  String get addUser => _translate('add_user');

  // Stats
  String get totalUsers => _translate('total_users');
  String get currentPage => _translate('current_page');

  // Sections
  String get details => _translate('details');
  String get preview => _translate('preview');
  String get userInformation => _translate('user_information');

  // Profile
  String get editProfile => _translate('edit_profile');
  String get notifications => _translate('notifications');
  String get language => _translate('language');
  String get helpSupport => _translate('help_support');
  String get about => _translate('about');

  // Network
  String get noInternetConnection => _translate('no_internet_connection');
  String get checkInternetConnection => _translate('check_internet_connection');
  String get offlineActionNotAvailable =>
      _translate('offline_action_not_available');
  String get currentlyOffline => _translate('currently_offline');
  String get offlineEditDeleteDisabled =>
      _translate('offline_edit_delete_disabled');
  String get checkingConnection => _translate('checking_connection');

  // Messages
  String get errorLoadingUsers => _translate('error_loading_users');
  String get noUsersFound => _translate('no_users_found');
  String get addFirstUser => _translate('add_first_user');

  // Confirmations
  String deleteUserConfirmation(String userName) =>
      _translate('delete_user_confirmation', {'userName': userName});
  String get signOutConfirmation => _translate('sign_out_confirmation');

  // Success Messages
  String get userCreatedSuccess => _translate('user_created_success');
  String get userUpdatedSuccess => _translate('user_updated_success');
  String get userDeletedSuccess => _translate('user_deleted_success');

  // Validation Messages
  String get pleaseEnterFirstName => _translate('please_enter_first_name');
  String get pleaseEnterLastName => _translate('please_enter_last_name');
  String get pleaseEnterEmail => _translate('please_enter_email');
  String get pleaseEnterValidEmail => _translate('please_enter_valid_email');
  String get pleaseEnterValidUrl => _translate('please_enter_valid_url');
  String get avatarUrlOptional => _translate('avatar_url_optional');

  // Loading States
  String get creating => _translate('creating');
  String get updating => _translate('updating');

  // Login Screen
  String get welcomeBackMessage => _translate('welcome_back_message');
  String get termsPrivacyMessage => _translate('terms_privacy_message');

  // Profile Descriptions
  String get updatePersonalInfo => _translate('update_personal_info');
  String get manageNotificationPreferences =>
      _translate('manage_notification_preferences');
  String get getHelpSupport => _translate('get_help_support');
  String get learnMoreAboutApp => _translate('learn_more_about_app');

  // Language Settings
  String get selectLanguage => _translate('select_language');
  String get english => _translate('english');
  String get hindi => _translate('hindi');
  String get languageChanged => _translate('language_changed');

  // Common
  String comingSoon(String feature) =>
      _translate('coming_soon', {'feature': feature});
  String get testNotification => _translate('test_notification');

  // HomeScreen specific getters
  String get taskFlow => _translate('task_flow');
  String get user => _translate('user');
  String get testNotificationTooltip => _translate('test_notification_tooltip');
  String get id => _translate('id');

  // Helper method to check if a key exists
  bool hasTranslation(String key) {
    return _isLoaded && _localizedStrings.containsKey(key);
  }

  // Get all available keys (useful for debugging)
  List<String> get availableKeys =>
      _isLoaded ? _localizedStrings.keys.toList() : [];
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
  }