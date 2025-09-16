import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/presentation/bloc/localization/locale_state.dart'
    show LocaleLoaded, LocaleState;
import '../../../../core/app_localization.dart';
import '../../../../core/constants.dart';
import '../../../bloc/localization/locale_bloc.dart';
import '../../../bloc/localization/locale_event.dart';

class LanguageDialogWidget extends StatelessWidget {
  const LanguageDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

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
                      Navigator.of(context).pop();
                    }
                  },
                ),
                title: Text(localizations.english),
                subtitle: const Text('English'),
                onTap: () {
                  context.read<LocaleBloc>().add(
                    const LocaleChanged(Locale(AppConstants.englishCode)),
                  );
                  Navigator.of(context).pop();
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
                      Navigator.of(context).pop();
                    }
                  },
                ),
                title: Text(localizations.hindi),
                subtitle: const Text('हिन्दी'),
                onTap: () {
                  context.read<LocaleBloc>().add(
                    const LocaleChanged(Locale(AppConstants.hindiCode)),
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
          ],
        );
      },
    );
  }
}
