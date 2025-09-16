TaskFlow

TaskFlow is a Flutter application designed to demonstrate a complete solution integrating Google Authentication, Push Notifications, Local Notifications, Localization, API Integration with Offline Support, and more.

✅ Features Implemented
Authentication

Google Authentication using Firebase Authentication

Notifications

Push Notifications using Firebase Cloud Messaging (FCM)

Local Notifications using flutter_local_notifications

Localization

Supports multiple languages using localized JSON files (en.json, hi.json)

Language can be dynamically switched

API Integration

Integrated with REST API using Dio

Error handling with Dartz for functional programming patterns

State management using flutter_bloc

Offline Support

Local caching of data using SQLite (sqflite package)

Connectivity status handled with connectivity_plus

Dependency Injection

Implemented using get_it and injectable

⚙️ Technical Stack
Feature	Package
State Management	flutter_bloc
Dependency Injection	get_it, injectable
HTTP Client	dio
Local Storage	sqflite, path
Firebase Authentication	firebase_auth
Firebase Messaging	firebase_messaging
Local Notifications	flutter_local_notifications
Connectivity Detection	connectivity_plus
Image Caching	cached_network_image
Localization	flutter_localizations
Shared Preferences	shared_preferences
🧱 Project Structure

Core
Localization, constants, utility functions.

Domain
Entities and models representing API data.

Data Layer
API services, database services.

Bloc Layer
All business logic components (AuthBloc, UsersBloc, etc.).

UI Layer
Clean, responsive layouts for mobile, tablet, and desktop views.

✅ Setup Instructions

Clone the repository

git clone <repo-url>


Install dependencies

flutter pub get


Configure Firebase

Add google-services.json for Android and GoogleService-Info.plist for iOS.

Enable Google Sign-In and FCM in Firebase Console.

Run the app

flutter run