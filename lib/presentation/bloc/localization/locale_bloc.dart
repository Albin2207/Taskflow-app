import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import 'locale_event.dart';
import 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc() : super(LocaleInitial()) {
    on<LocaleLoadRequested>(_onLocaleLoadRequested);
    on<LocaleChanged>(_onLocaleChanged);
  }

  Future<void> _onLocaleLoadRequested(
    LocaleLoadRequested event,
    Emitter<LocaleState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(AppConstants.languageKey) ?? AppConstants.englishCode;
      
      Locale locale;
      if (languageCode == AppConstants.hindiCode) {
        locale = const Locale(AppConstants.hindiCode);
      } else {
        locale = const Locale(AppConstants.englishCode);
      }
      
      emit(LocaleLoaded(locale));
    } catch (e) {
      // Fallback to English if there's an error
      emit(const LocaleLoaded(Locale(AppConstants.englishCode)));
    }
  }

  Future<void> _onLocaleChanged(
    LocaleChanged event,
    Emitter<LocaleState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.languageKey, event.locale.languageCode);
      
      emit(LocaleLoaded(event.locale));
    } catch (e) {
      // If saving fails, still emit the new locale
      emit(LocaleLoaded(event.locale));
    }
  }

  // Helper methods to get available locales
  static const List<Locale> supportedLocales = [
    Locale(AppConstants.englishCode),
    Locale(AppConstants.hindiCode),
  ];

  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case AppConstants.englishCode:
        return 'English';
      case AppConstants.hindiCode:
        return 'हिन्दी';
      default:
        return 'English';
    }
  }
}