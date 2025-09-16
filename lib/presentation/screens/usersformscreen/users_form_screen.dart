import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_localization.dart' show AppLocalizations;
import '../../../domain/entities/api_user_entity.dart';
import '../../bloc/connectivity/connectivity_bloc.dart';
import '../../bloc/userlist/userlist_bloc.dart';
import '../../bloc/userlist/userlist_event.dart';
import '../../bloc/userlist/userlist_state.dart';
import 'widgets/form_action_button.dart';
import 'widgets/offlinewarning_widget.dart';
import 'widgets/user_form.dart';
import 'widgets/user_preview.dart';

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
                      OfflineWarningWidget(localizations: localizations),
                      const SizedBox(height: 16),
                    ],

                    // Form Card
                    UserFormWidget(
                      localizations: localizations,
                      firstNameController: _firstNameController,
                      lastNameController: _lastNameController,
                      emailController: _emailController,
                      avatarController: _avatarController,
                    ),

                    const SizedBox(height: 24),

                    // Preview Card (if avatar URL is provided)
                    if (_avatarController.text.isNotEmpty) ...[
                      UserPreviewWidget(
                        localizations: localizations,
                        firstNameController: _firstNameController,
                        lastNameController: _lastNameController,
                        emailController: _emailController,
                        avatarController: _avatarController,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Action Buttons
                    FormActionButtonsWidget(
                      localizations: localizations,
                      isEditing: isEditing,
                      isOffline: isOffline,
                      onSave: _saveUser,
                      onCancel: () => Navigator.of(context).pop(),
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
