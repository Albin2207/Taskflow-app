import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_localization.dart';
import '../../../domain/entities/api_user_entity.dart';
import '../../bloc/connectivity/connectivity_bloc.dart';
import '../../bloc/userlist/userlist_bloc.dart';
import '../../bloc/userlist/userlist_event.dart';
import '../usersformscreen/users_form_screen.dart';
import 'widgets/delete_dialogue.dart';
import 'widgets/user_action_button.dart';
import 'widgets/userdetails_card.dart';
import 'widgets/userprofile_card.dart';

class UserDetailScreen extends StatelessWidget {
  final ApiUserEntity user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(
        body: Center(child: Text('Localization not available')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          localizations.userDetails,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          BlocBuilder<ConnectivityBloc, ConnectivityState>(
            builder: (context, connectivityState) {
              return PopupMenuButton<String>(
                enabled: connectivityState is ConnectivityConnected,
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: const Icon(Icons.edit),
                          title: Text(localizations.edit),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: const Icon(Icons.delete, color: Colors.red),
                          title: Text(
                            localizations.delete,
                            style: const TextStyle(color: Colors.red),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                onSelected: (value) {
                  if (connectivityState is ConnectivityDisconnected) {
                    _showOfflineMessage(context, localizations);
                    return;
                  }

                  switch (value) {
                    case 'edit':
                      _navigateToEditUser(context);
                      break;
                    case 'delete':
                      _showDeleteDialog(context, localizations);
                      break;
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Card
            UserProfileCardWidget(user: user),

            const SizedBox(height: 24),

            // Details Card
            UserDetailsCardWidget(user: user, localizations: localizations),

            const SizedBox(height: 24),

            // Action Buttons
            UserActionButtonsWidget(
              user: user,
              localizations: localizations,
              onEditPressed: () => _navigateToEditUser(context),
              onDeletePressed: () => _showDeleteDialog(context, localizations),
              onOfflinePressed:
                  () => _showOfflineMessage(context, localizations),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditUser(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => UserFormScreen(user: user)));
  }

  void _showDeleteDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => DeleteUserDialogWidget(
            user: user,
            localizations: localizations,
            onConfirm: () {
              Navigator.of(dialogContext).pop();
              context.read<UsersBloc>().add(DeleteUserEvent(user.id));
              Navigator.of(context).pop(); // Go back to users list
            },
          ),
    );
  }

  void _showOfflineMessage(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.offlineActionNotAvailable),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
