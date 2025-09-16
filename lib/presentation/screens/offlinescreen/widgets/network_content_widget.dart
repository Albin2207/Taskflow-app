import 'package:flutter/material.dart';
import '../../../../core/app_localization.dart';
import 'network_icon.dart';
import 'network_info_widget.dart';
import 'retry_button.dart';
import 'status_inidcator.dart';

class NetworkContentWidget extends StatelessWidget {
  final AppLocalizations localizations;

  const NetworkContentWidget({super.key, required this.localizations});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // No Internet Icon with pulsing effect
        NetworkIconWidget(),

        const SizedBox(height: 32),

        // Title
        Text(
          localizations.noInternetConnection,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Description
        Text(
          localizations.checkInternetConnection,
          style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Additional info
        NetworkInfoWidget(),

        const SizedBox(height: 40),

        // Retry Button
        RetryButtonWidget(localizations: localizations),

        const SizedBox(height: 24),

        // Status indicator
        StatusIndicatorWidget(localizations: localizations),
      ],
    );
  }
}
