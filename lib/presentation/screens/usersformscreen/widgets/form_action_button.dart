import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_localization.dart';
import '../../../bloc/userlist/userlist_bloc.dart';
import '../../../bloc/userlist/userlist_state.dart';

class FormActionButtonsWidget extends StatelessWidget {
  final AppLocalizations localizations;
  final bool isEditing;
  final bool isOffline;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const FormActionButtonsWidget({
    super.key,
    required this.localizations,
    required this.isEditing,
    required this.isOffline,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, state) {
        final isLoading = state is UsersOperationLoading;

        return Column(
          children: [
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: (isLoading || isOffline) ? null : onSave,
                icon:
                    isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Icon(isEditing ? Icons.save : Icons.add),
                label: Text(
                  isLoading
                      ? (isEditing
                          ? localizations.updating
                          : localizations.creating)
                      : (isEditing
                          ? localizations.updateUser
                          : localizations.createUser),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      (isLoading || isOffline)
                          ? Colors.grey
                          : const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onCancel,
                icon: const Icon(Icons.cancel),
                label: Text(
                  localizations.cancel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
