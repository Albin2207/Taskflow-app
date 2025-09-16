import 'package:flutter/material.dart';
import '../../../../core/app_localization.dart';
import '../../../../domain/entities/api_user_entity.dart';

class UserDetailsCardWidget extends StatelessWidget {
  final ApiUserEntity user;
  final AppLocalizations localizations;

  const UserDetailsCardWidget({
    super.key,
    required this.user,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.details,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          _buildDetailRow(localizations.firstName, user.firstName),
          const SizedBox(height: 12),
          _buildDetailRow(localizations.lastName, user.lastName),
          const SizedBox(height: 12),
          _buildDetailRow(localizations.email, user.email),
          const SizedBox(height: 12),
          _buildDetailRow('User ID', user.id.toString()),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
