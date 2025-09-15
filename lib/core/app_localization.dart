import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
  ];

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle
          .loadString('assets/i18n/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });

      return true;
    } catch (e) {
      print('Error loading localization file: $e');
      // Load default English strings as fallback
      if (locale.languageCode != 'en') {
        try {
          String jsonString = await rootBundle.loadString('assets/i18n/en.json');
          Map<String, dynamic> jsonMap = json.decode(jsonString);
          _localizedStrings = jsonMap.map((key, value) {
            return MapEntry(key, value.toString());
          });
          return true;
        } catch (e) {
          print('Error loading fallback English localization: $e');
        }
      }
      return false;
    }
  }

  String _translate(String key, [Map<String, String>? params]) {
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
  String get offlineActionNotAvailable => _translate('offline_action_not_available');
  String get currentlyOffline => _translate('currently_offline');
  String get offlineEditDeleteDisabled => _translate('offline_edit_delete_disabled');
  String get checkingConnection => _translate('checking_connection');

  // Messages
  String get errorLoadingUsers => _translate('error_loading_users');
  String get noUsersFound => _translate('no_users_found');
  String get addFirstUser => _translate('add_first_user');

  // Confirmations
  String deleteUserConfirmation(String userName) => _translate('delete_user_confirmation', {'userName': userName});
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
  String get manageNotificationPreferences => _translate('manage_notification_preferences');
  String get getHelpSupport => _translate('get_help_support');
  String get learnMoreAboutApp => _translate('learn_more_about_app');

  // Language Settings
  String get selectLanguage => _translate('select_language');
  String get english => _translate('english');
  String get hindi => _translate('hindi');
  String get languageChanged => _translate('language_changed');

  // Common
  String comingSoon(String feature) => _translate('coming_soon', {'feature': feature});
  String get testNotification => _translate('test_notification');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
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