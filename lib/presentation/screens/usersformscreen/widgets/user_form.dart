import 'package:flutter/material.dart';
import '../../../../core/app_localization.dart';

class UserFormWidget extends StatelessWidget {
  final AppLocalizations localizations;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController avatarController;

  const UserFormWidget({
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.userInformation,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 24),

          // First Name
          TextFormField(
            controller: firstNameController,
            decoration: InputDecoration(
              labelText: localizations.firstName,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return localizations.pleaseEnterFirstName;
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Last Name
          TextFormField(
            controller: lastNameController,
            decoration: InputDecoration(
              labelText: localizations.lastName,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return localizations.pleaseEnterLastName;
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: localizations.email,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return localizations.pleaseEnterEmail;
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return localizations.pleaseEnterValidEmail;
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          // Avatar URL
          TextFormField(
            controller: avatarController,
            decoration: InputDecoration(
              labelText: localizations.avatarUrl,
              prefixIcon: const Icon(Icons.image_outlined),
              helperText: localizations.avatarUrlOptional,
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!Uri.tryParse(value)!.hasAbsolutePath == true) {
                  return localizations.pleaseEnterValidUrl;
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
