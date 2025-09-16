import 'package:flutter/material.dart';
import '../../../../core/app_localization.dart';

class UserPreviewWidget extends StatelessWidget {
  final AppLocalizations localizations;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController avatarController;

  const UserPreviewWidget({
    super.key,
    required this.localizations,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.avatarController,
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
        children: [
          Text(
            localizations.preview,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(avatarController.text),
            backgroundColor: Colors.grey[300],
            onBackgroundImageError: (_, __) {},
          ),
          const SizedBox(height: 8),
          Text(
            '${firstNameController.text} ${lastNameController.text}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            emailController.text,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
