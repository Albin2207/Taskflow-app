import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_localization.dart';
import '../../../../domain/entities/api_user_entity.dart';
import '../../../bloc/connectivity/connectivity_bloc.dart';

class UserActionButtonsWidget extends StatelessWidget {
  final ApiUserEntity user;
  final AppLocalizations localizations;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onOfflinePressed;

  const UserActionButtonsWidget({
    super.key,
    required this.user,
    required this.localizations,
    required this.onEditPressed,
    required this.onDeletePressed,
    required this.onOfflinePressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, connectivityState) {
        final isOnline = connectivityState is ConnectivityConnected;

        return Column(
          children: [
            // Edit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isOnline ? onEditPressed : onOfflinePressed,
                icon: const Icon(Icons.edit),
                label: Text(
                  localizations.editUser,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isOnline ? const Color(0xFF1E88E5) : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Delete Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: isOnline ? onDeletePressed : onOfflinePressed,
                icon: const Icon(Icons.delete),
                label: Text(
                  localizations.deleteUser,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isOnline ? Colors.red : Colors.grey,
                  side: BorderSide(color: isOnline ? Colors.red : Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            if (!isOnline) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  // ignore: deprecated_member_use
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localizations.offlineEditDeleteDisabled,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
