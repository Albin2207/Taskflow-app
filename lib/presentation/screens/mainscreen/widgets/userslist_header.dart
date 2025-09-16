import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_localization.dart';
import '../../../bloc/connectivity/connectivity_bloc.dart';

class UsersListHeader extends StatelessWidget {
  final AppLocalizations localizations;
  final bool isTablet;
  final VoidCallback onRefresh;

  const UsersListHeader({
    super.key,
    required this.localizations,
    required this.isTablet,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          localizations.users,
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        BlocBuilder<ConnectivityBloc, ConnectivityState>(
          builder: (context, connectivityState) {
            return TextButton.icon(
              onPressed:
                  connectivityState is ConnectivityConnected ? onRefresh : null,
              icon: Icon(Icons.refresh, size: isTablet ? 20 : 18),
              label: Text(
                localizations.refresh,
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
            );
          },
        ),
      ],
    );
  }
}
