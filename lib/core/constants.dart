class AppConstants {
  // App Info
  static const String appName = 'TaskFlow';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'taskflow_app.db';
  static const int databaseVersion = 1;
  
  // Table names
  static const String usersTable = 'users';
  
  // API
  static const String baseUrl = 'https://reqres.in/api';
  
  // Preferences keys
  static const String firstLaunchKey = 'first_launch';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  
  // Supported Languages
  static const String englishCode = 'en';
  static const String hindiCode = 'hi';
  
  // Routes
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String usersRoute = '/users';
  static const String loginRoute = '/login';
}

// Localization Keys Class - for better organization
class LocalizationKeys {
  // App Info
  static const String appName = 'app_name';
  static const String manageTasksEfficiently = 'manage_tasks_efficiently';

  // Navigation
  static const String home = 'home';
  static const String profile = 'profile';
  static const String users = 'users';

  // Greetings
  static const String welcome = 'welcome';
  static const String welcomeBack = 'welcome_back';
  static const String goodMorning = 'good_morning';

  // Actions
  static const String add = 'add';
  static const String create = 'create';
  static const String edit = 'edit';
  static const String delete = 'delete';
  static const String save = 'save';
  static const String cancel = 'cancel';
  static const String view = 'view';
  static const String update = 'update';
  static const String refresh = 'refresh';
  static const String retry = 'retry';
  static const String tryAgain = 'try_again';

  // Auth
  static const String login = 'login';
  static const String logout = 'logout';
  static const String signOut = 'sign_out';
  static const String continueWithGoogle = 'continue_with_google';

  // Form Fields
  static const String firstName = 'first_name';
  static const String lastName = 'last_name';
  static const String email = 'email';
  static const String avatarUrl = 'avatar_url';

  // User Management
  static const String createUser = 'create_user';
  static const String editUser = 'edit_user';
  static const String updateUser = 'update_user';
  static const String deleteUser = 'delete_user';
  static const String userDetails = 'user_details';
  static const String addUser = 'add_user';

  // Stats
  static const String totalUsers = 'total_users';
  static const String currentPage = 'current_page';

  // Sections
  static const String details = 'details';
  static const String preview = 'preview';
  static const String userInformation = 'user_information';

  // Profile
  static const String editProfile = 'edit_profile';
  static const String notifications = 'notifications';
  static const String language = 'language';
  static const String helpSupport = 'help_support';
  static const String about = 'about';

  // Network
  static const String noInternetConnection = 'no_internet_connection';
  static const String checkInternetConnection = 'check_internet_connection';
  static const String offlineActionNotAvailable = 'offline_action_not_available';
  static const String currentlyOffline = 'currently_offline';
  static const String offlineEditDeleteDisabled = 'offline_edit_delete_disabled';
  static const String checkingConnection = 'checking_connection';

  // Messages
  static const String errorLoadingUsers = 'error_loading_users';
  static const String noUsersFound = 'no_users_found';
  static const String addFirstUser = 'add_first_user';

  // Confirmations
  static const String deleteUserConfirmation = 'delete_user_confirmation';
  static const String signOutConfirmation = 'sign_out_confirmation';

  // Success Messages
  static const String userCreatedSuccess = 'user_created_success';
  static const String userUpdatedSuccess = 'user_updated_success';
  static const String userDeletedSuccess = 'user_deleted_success';

  // Validation Messages
  static const String pleaseEnterFirstName = 'please_enter_first_name';
  static const String pleaseEnterLastName = 'please_enter_last_name';
  static const String pleaseEnterEmail = 'please_enter_email';
  static const String pleaseEnterValidEmail = 'please_enter_valid_email';
  static const String pleaseEnterValidUrl = 'please_enter_valid_url';
  static const String avatarUrlOptional = 'avatar_url_optional';

  // Loading States
  static const String creating = 'creating';
  static const String updating = 'updating';

  // Login Screen
  static const String welcomeBackMessage = 'welcome_back_message';
  static const String termsPrivacyMessage = 'terms_privacy_message';

  // Profile Descriptions
  static const String updatePersonalInfo = 'update_personal_info';
  static const String manageNotificationPreferences = 'manage_notification_preferences';
  static const String getHelpSupport = 'get_help_support';
  static const String learnMoreAboutApp = 'learn_more_about_app';

  // Language Settings
  static const String selectLanguage = 'select_language';
  static const String english = 'english';
  static const String hindi = 'hindi';
  static const String languageChanged = 'language_changed';

  // Common
  static const String comingSoon = 'coming_soon';
  static const String testNotification = 'test_notification';
}