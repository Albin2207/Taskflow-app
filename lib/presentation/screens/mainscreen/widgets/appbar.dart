import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_localization.dart';
import '../../../bloc/auth/auth_bloc.dart' show AuthBloc;
import '../../../bloc/auth/auth_state.dart';
import '../../../bloc/connectivity/connectivity_bloc.dart';

class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations localizations;
  final bool isTablet;
  final bool isDesktop;
  final VoidCallback onAddPressed;
  final Function(BuildContext) onOfflineMessage;

  const ResponsiveAppBar({
    super.key,
    required this.localizations,
    required this.isTablet,
    required this.isDesktop,
    required this.onAddPressed,
    required this.onOfflineMessage,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: isTablet ? 72 : 56,
      title: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.welcomeBack,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  state.user.name.isEmpty
                      ? localizations.user
                      : state.user.name.split(' ').first,
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }
          return Text(
            localizations.taskFlow,
            style: TextStyle(fontSize: isTablet ? 22 : 18),
          );
        },
      ),
      actions: [
        BlocBuilder<ConnectivityBloc, ConnectivityState>(
          builder: (context, connectivityState) {
            return IconButton(
              icon: const Icon(Icons.add_circle_outline),
              iconSize: isTablet ? 48 : 40,
              color:
                  connectivityState is ConnectivityConnected
                      ? const Color(0xFF1E88E5)
                      : Colors.grey,
              onPressed:
                  connectivityState is ConnectivityConnected
                      ? onAddPressed
                      : () => onOfflineMessage(context),
            );
          },
        ),
        Container(
          margin: EdgeInsets.only(right: isTablet ? 24 : 16),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final radius = isTablet ? 24.0 : 18.0;
              final iconSize = isTablet ? 24.0 : 18.0;

              if (state is AuthAuthenticated && state.user.photoUrl != null) {
                return CircleAvatar(
                  radius: radius,
                  backgroundImage: NetworkImage(state.user.photoUrl!),
                );
              }
              return CircleAvatar(
                radius: radius,
                backgroundColor: const Color(0xFF1E88E5),
                child: Icon(Icons.person, color: Colors.white, size: iconSize),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(isTablet ? 72 : 56);
}
