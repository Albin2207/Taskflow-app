import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_localization.dart';
import '../../../../domain/entities/api_user_entity.dart';
import '../../../bloc/connectivity/connectivity_bloc.dart';

class ResponsiveUserCard extends StatelessWidget {
  final ApiUserEntity user;
  final AppLocalizations localizations;
  final bool isTablet;
  final bool isDesktop;
  final Function(BuildContext, ApiUserEntity) onViewUser;
  final Function(BuildContext, {ApiUserEntity? user}) onEditUser;
  final Function(BuildContext, ApiUserEntity) onDeleteUser;
  final Function(BuildContext) onOfflineMessage;
  final VoidCallback onTap;

  const ResponsiveUserCard({
    super.key,
    required this.user,
    required this.localizations,
    required this.isTablet,
    required this.isDesktop,
    required this.onViewUser,
    required this.onEditUser,
    required this.onDeleteUser,
    required this.onOfflineMessage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardPadding =
        isDesktop
            ? 20.0
            : isTablet
            ? 18.0
            : 16.0;
    final avatarRadius =
        isDesktop
            ? 35.0
            : isTablet
            ? 32.0
            : 30.0;
    final titleFontSize =
        isDesktop
            ? 18.0
            : isTablet
            ? 17.0
            : 16.0;
    final subtitleFontSize =
        isDesktop
            ? 15.0
            : isTablet
            ? 14.0
            : 14.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(cardPadding),
        leading: CircleAvatar(
          radius: avatarRadius,
          backgroundImage: NetworkImage(user.avatar),
          backgroundColor: Colors.grey[300],
        ),
        title: Text(
          user.fullName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: titleFontSize,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: isTablet ? 6 : 4),
            Text(
              user.email,
              style: TextStyle(color: Colors.grey, fontSize: subtitleFontSize),
            ),
            SizedBox(height: isTablet ? 6 : 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: const Color(0xFF1E88E5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${localizations.id}: ${user.id}',
                style: TextStyle(
                  color: const Color(0xFF1E88E5),
                  fontSize: isTablet ? 13 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: BlocBuilder<ConnectivityBloc, ConnectivityState>(
          builder: (context, connectivityState) {
            return PopupMenuButton<String>(
              enabled: connectivityState is ConnectivityConnected,
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'view',
                      child: ListTile(
                        leading: const Icon(Icons.visibility),
                        title: Text(localizations.view),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
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
                  onOfflineMessage(context);
                  return;
                }

                switch (value) {
                  case 'view':
                    onViewUser(context, user);
                    break;
                  case 'edit':
                    onEditUser(context, user: user);
                    break;
                  case 'delete':
                    onDeleteUser(context, user);
                    break;
                }
              },
            );
          },
        ),
        onTap: onTap,
      ),
    );
  }
}
