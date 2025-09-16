
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_localization.dart';
import '../../../domain/entities/api_user_entity.dart';
import '../../bloc/connectivity/connectivity_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/userlist/userlist_bloc.dart';
import '../../bloc/userlist/userlist_event.dart';
import '../../bloc/userlist/userlist_state.dart';
import 'widgets/appbar.dart';
import 'widgets/empty_state.dart';
import 'widgets/error_state.dart';
import 'widgets/stats_section.dart';
import 'widgets/user_card.dart';
import 'widgets/userslist_header.dart';
import '../offlinescreen/no_network_screen.dart';
import '../userdetailscreen/user_details_screen.dart';
import '../usersformscreen/users_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<UsersBloc>().add(const LoadUsersEvent());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeNotificationOnFirstLoad();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showWelcomeNotificationOnFirstLoad() {
    final currentState = context.read<UsersBloc>().state;
    if (currentState is UsersInitial) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.read<NotificationBloc>().add(NotificationSendWelcome());
        }
      });
    }
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<UsersBloc>().add(LoadMoreUsersEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.getSafeLocalizations(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    // Responsive padding
    final horizontalPadding =
        isDesktop
            ? 32.0
            : isTablet
            ? 24.0
            : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: ResponsiveAppBar(
        localizations: localizations,
        isTablet: isTablet,
        isDesktop: isDesktop,
        onAddPressed: () => _navigateToUserForm(context),
        onOfflineMessage: _showOfflineMessage,
      ),
      body: BlocListener<ConnectivityBloc, ConnectivityState>(
        listener: (context, connectivityState) {
          if (connectivityState is ConnectivityDisconnected) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const NoNetworkScreen()));
          }
        },
        child: BlocConsumer<UsersBloc, UsersState>(
          listener: (context, state) {
            if (state is UsersError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is UsersOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<UsersBloc>().add(
                  const LoadUsersEvent(isRefresh: true),
                );
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Stats Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(horizontalPadding),
                      child: StatsSectionWidget(
                        state: state,
                        localizations: localizations,
                        isTablet: isTablet,
                        isDesktop: isDesktop,
                      ),
                    ),
                  ),

                  // Users List Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: UsersListHeader(
                        localizations: localizations,
                        isTablet: isTablet,
                        onRefresh:
                            () => context.read<UsersBloc>().add(
                              const LoadUsersEvent(isRefresh: true),
                            ),
                      ),
                    ),
                  ),

                  // Users List
                  if (state is UsersLoading && state is! UsersLoaded)
                    const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                  else if (state is UsersLoaded)
                    _buildResponsiveUsersList(
                      state,
                      localizations,
                      isTablet,
                      isDesktop,
                      horizontalPadding,
                    )
                  else if (state is UsersError)
                    SliverToBoxAdapter(
                      child: ErrorStateWidget(
                        message: state.message,
                        localizations: localizations,
                        onRetry: () {
                          context.read<UsersBloc>().add(const LoadUsersEvent());
                        },
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: EmptyStateWidget(
                        localizations: localizations,
                        onAddUser: () => _navigateToUserForm(context),
                        onOfflineMessage: _showOfflineMessage,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveUsersList(
    UsersLoaded state,
    AppLocalizations localizations,
    bool isTablet,
    bool isDesktop,
    double horizontalPadding,
  ) {
    if (isDesktop) {
      // Desktop: Grid layout
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index >= state.users.length) {
              return const Center(child: CircularProgressIndicator());
            }
            return ResponsiveUserCard(
              user: state.users[index],
              localizations: localizations,
              isTablet: isTablet,
              isDesktop: isDesktop,
              onViewUser: _navigateToUserDetail,
              onEditUser: _navigateToUserForm,
              onDeleteUser: _showDeleteDialog,
              onOfflineMessage: _showOfflineMessage,
              onTap: () => _navigateToUserDetail(context, state.users[index]),
            );
          }, childCount: state.users.length + (state.isLoadingMore ? 1 : 0)),
        ),
      );
    } else {
      // Mobile & Tablet: List layout
      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index >= state.users.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final user = state.users[index];
          return Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              index == 0 ? 8 : 4,
              horizontalPadding,
              index == state.users.length - 1 ? 16 : 4,
            ),
            child: ResponsiveUserCard(
              user: user,
              localizations: localizations,
              isTablet: isTablet,
              isDesktop: isDesktop,
              onViewUser: _navigateToUserDetail,
              onEditUser: _navigateToUserForm,
              onDeleteUser: _showDeleteDialog,
              onOfflineMessage: _showOfflineMessage,
              onTap: () => _navigateToUserDetail(context, user),
            ),
          );
        }, childCount: state.users.length + (state.isLoadingMore ? 1 : 0)),
      );
    }
  }

  void _navigateToUserDetail(BuildContext context, ApiUserEntity user) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => UserDetailScreen(user: user)));
  }

  void _navigateToUserForm(BuildContext context, {ApiUserEntity? user}) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => UserFormScreen(user: user)));
  }

  void _showDeleteDialog(BuildContext context, ApiUserEntity user) {
    final localizations = AppLocalizations.getSafeLocalizations(context);

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
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

  void _showOfflineMessage(BuildContext context) {
    final localizations = AppLocalizations.getSafeLocalizations(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.offlineActionNotAvailable),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
