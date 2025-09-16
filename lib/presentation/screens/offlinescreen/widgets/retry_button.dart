import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_localization.dart';
import '../../../bloc/connectivity/connectivity_bloc.dart';

class RetryButtonWidget extends StatelessWidget {
  final AppLocalizations localizations;

  const RetryButtonWidget({super.key, required this.localizations});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, state) {
        final isChecking = state is ConnectivityChecking;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed:
                isChecking
                    ? null
                    : () {
                      context.read<ConnectivityBloc>().add(
                        ConnectivityCheckRequested(),
                      );
                    },
            icon:
                isChecking
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(Icons.refresh),
            label: Text(
              isChecking
                  ? localizations.checkingConnection
                  : localizations.tryAgain,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isChecking ? Colors.grey : const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}
