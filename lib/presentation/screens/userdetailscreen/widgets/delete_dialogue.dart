import 'package:flutter/material.dart';
import '../../../../core/app_localization.dart';
import '../../../../domain/entities/api_user_entity.dart';

class DeleteUserDialogWidget extends StatelessWidget {
  final ApiUserEntity user;
  final AppLocalizations localizations;
  final VoidCallback onConfirm;

  const DeleteUserDialogWidget({
    super.key,
    required this.user,
    required this.localizations,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(localizations.deleteUser),
      content: Text(localizations.deleteUserConfirmation(user.fullName)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            localizations.delete,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
