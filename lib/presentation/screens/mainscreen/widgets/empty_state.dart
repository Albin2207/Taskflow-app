import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_localization.dart';
import '../../../bloc/connectivity/connectivity_bloc.dart';


class EmptyStateWidget extends StatelessWidget {
  final AppLocalizations localizations;
  final VoidCallback onAddUser;
  final Function(BuildContext) onOfflineMessage;

  const EmptyStateWidget({
    super.key,
    required this.localizations,
    required this.onAddUser,
    required this.onOfflineMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              localizations.noUsersFound,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.addFirstUser,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            BlocBuilder<ConnectivityBloc, ConnectivityState>(
              builder: (context, connectivityState) {
                return ElevatedButton.icon(
                  onPressed:
                      connectivityState is ConnectivityConnected
                          ? onAddUser
                          : () => onOfflineMessage(context),
                  icon: const Icon(Icons.add),
                  label: Text(localizations.addUser),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}