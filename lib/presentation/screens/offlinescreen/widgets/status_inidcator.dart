import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_localization.dart';
import '../../../bloc/connectivity/connectivity_bloc.dart';

class StatusIndicatorWidget extends StatelessWidget {
  final AppLocalizations localizations;

  const StatusIndicatorWidget({super.key, required this.localizations});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, state) {
        if (state is ConnectivityChecking) {
          return Column(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localizations.checkingConnection,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          );
        } else if (state is ConnectivityRestored) {
          return Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(height: 8),
              Text(
                'Connection restored! Returning to app...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
