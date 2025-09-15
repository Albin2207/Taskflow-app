import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/app_localization.dart';
import '../../domain/entities/api_user_entity.dart';
import '../bloc/connectivity/connectivity_bloc.dart';
import '../bloc/userlist/userlist_bloc.dart';
import '../bloc/userlist/userlist_event.dart';
import 'users_form_screen.dart';

class UserDetailScreen extends StatelessWidget {
  final ApiUserEntity user;

  const UserDetailScreen({super.key, required this.user});

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
          localizations.userDetails,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          BlocBuilder<ConnectivityBloc, ConnectivityState>(
            builder: (context, connectivityState) {
              return PopupMenuButton<String>(
                enabled: connectivityState is ConnectivityConnected,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: const Icon(Icons.edit),
                      title: Text(localizations.edit),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: Text(
                        localizations.delete, 
                        style: const TextStyle(color: Colors.red)
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (connectivityState is ConnectivityDisconnected) {
                    _showOfflineMessage(context, localizations);
                    return;
                  }

                  switch (value) {
                    case 'edit':
                      _navigateToEditUser(context);
                      break;
                    case 'delete':
                      _showDeleteDialog(context, localizations);
                      break;
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                children: [
                  // Profile Picture
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1E88E5),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 57,
                      backgroundImage: NetworkImage(user.avatar),
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Name
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Email
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // User ID
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ID: ${user.id}',
                      style: const TextStyle(
                        color: Color(0xFF1E88E5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Details Card
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
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            BlocBuilder<ConnectivityBloc, ConnectivityState>(
              builder: (context, connectivityState) {
                final isOnline = connectivityState is ConnectivityConnected;
                
                return Column(
                  children: [
                    // Edit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: isOnline 
                            ? () => _navigateToEditUser(context)
                            : () => _showOfflineMessage(context, localizations),
                        icon: const Icon(Icons.edit),
                        label: Text(
                          localizations.editUser,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isOnline 
                              ? const Color(0xFF1E88E5)
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Delete Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: isOnline 
                            ? () => _showDeleteDialog(context, localizations)
                            : () => _showOfflineMessage(context, localizations),
                        icon: const Icon(Icons.delete),
                        label: Text(
                          localizations.deleteUser,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isOnline ? Colors.red : Colors.grey,
                          side: BorderSide(
                            color: isOnline ? Colors.red : Colors.grey,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    if (!isOnline) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.wifi_off, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                localizations.offlineEditDeleteDisabled,
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
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

  void _navigateToEditUser(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserFormScreen(user: user),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.deleteUser),
        content: Text(localizations.deleteUserConfirmation(user.fullName)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<UsersBloc>().add(DeleteUserEvent(user.id));
              Navigator.of(context).pop(); // Go back to users list
            },
            child: Text(
              localizations.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showOfflineMessage(BuildContext context, AppLocalizations localizations) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.offlineActionNotAvailable),
        backgroundColor: Colors.orange,
      ),
    );
  }
}