import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/app_localization.dart';
import '../../domain/entities/api_user_entity.dart';
import '../bloc/connectivity/connectivity_bloc.dart';
import '../bloc/userlist/userlist_bloc.dart';
import '../bloc/userlist/userlist_event.dart';
import '../bloc/userlist/userlist_state.dart';

class UserFormScreen extends StatefulWidget {
  final ApiUserEntity? user; // null for create, user for edit

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _avatarController = TextEditingController();

  bool get isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _firstNameController.text = widget.user!.firstName;
      _lastNameController.text = widget.user!.lastName;
      _emailController.text = widget.user!.email;
      _avatarController.text = widget.user!.avatar;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

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
          isEditing ? localizations.editUser : localizations.createUser,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocListener<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is UsersOperationSuccess) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is UsersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
          builder: (context, connectivityState) {
            final isOffline = connectivityState is ConnectivityDisconnected;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (isOffline) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.wifi_off,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                localizations.currentlyOffline,
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Form Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
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
                            controller: _firstNameController,
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
                            controller: _lastNameController,
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
                            controller: _emailController,
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
                            controller: _avatarController,
                            decoration: InputDecoration(
                              labelText: localizations.avatarUrl,
                              prefixIcon: const Icon(Icons.image_outlined),
                              helperText: localizations.avatarUrlOptional,
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!Uri.tryParse(value)!.hasAbsolutePath ==
                                    true) {
                                  return localizations.pleaseEnterValidUrl;
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Preview Card (if avatar URL is provided)
                    if (_avatarController.text.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
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
                              backgroundImage: NetworkImage(
                                _avatarController.text,
                              ),
                              backgroundColor: Colors.grey[300],
                              onBackgroundImageError: (_, __) {},
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_firstNameController.text} ${_lastNameController.text}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _emailController.text,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Action Buttons
                    BlocBuilder<UsersBloc, UsersState>(
                      builder: (context, state) {
                        final isLoading = state is UsersOperationLoading;

                        return Column(
                          children: [
                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed:
                                    (isLoading || isOffline) ? null : _saveUser,
                                icon:
                                    isLoading
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                        : Icon(
                                          isEditing ? Icons.save : Icons.add,
                                        ),
                                label: Text(
                                  isLoading
                                      ? (isEditing
                                          ? localizations.updating
                                          : localizations.creating)
                                      : (isEditing
                                          ? localizations.updateUser
                                          : localizations.createUser),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      (isLoading || isOffline)
                                          ? Colors.grey
                                          : const Color(0xFF1E88E5),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Cancel Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton.icon(
                                onPressed:
                                    isLoading
                                        ? null
                                        : () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.cancel),
                                label: Text(
                                  localizations.cancel,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey,
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _saveUser() {
    if (_formKey.currentState?.validate() ?? false) {
      final user = ApiUserEntity(
        id: isEditing ? widget.user!.id : 0,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        avatar:
            _avatarController.text.trim().isEmpty
                ? 'https://via.placeholder.com/150'
                : _avatarController.text.trim(),
      );

      if (isEditing) {
        context.read<UsersBloc>().add(UpdateUserEvent(user));
      } else {
        context.read<UsersBloc>().add(CreateUserEvent(user));
      }
    }
  }
}
