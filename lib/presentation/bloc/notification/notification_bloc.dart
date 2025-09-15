import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/database/services/notification_service.dart';

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationInitialize extends NotificationEvent {}

class NotificationSendUserCreated extends NotificationEvent {
  final String userName;

  const NotificationSendUserCreated(this.userName);

  @override
  List<Object?> get props => [userName];
}

class NotificationSendUserUpdated extends NotificationEvent {
  final String userName;

  const NotificationSendUserUpdated(this.userName);

  @override
  List<Object?> get props => [userName];
}

class NotificationSendUserDeleted extends NotificationEvent {
  final String userName;

  const NotificationSendUserDeleted(this.userName);

  @override
  List<Object?> get props => [userName];
}

class NotificationSendWelcome extends NotificationEvent {}

class NotificationSendSync extends NotificationEvent {
  final int userCount;

  const NotificationSendSync(this.userCount);

  @override
  List<Object?> get props => [userCount];
}

class NotificationSendNetworkRestored extends NotificationEvent {}

class NotificationSendTest extends NotificationEvent {}

class NotificationHandleTap extends NotificationEvent {
  final String route;
  final Map<String, dynamic> data;

  const NotificationHandleTap(this.route, this.data);

  @override
  List<Object?> get props => [route, data];
}

// States
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationInitialized extends NotificationState {
  final String? fcmToken;

  const NotificationInitialized({this.fcmToken});

  @override
  List<Object?> get props => [fcmToken];
}

class NotificationSent extends NotificationState {
  final String message;

  const NotificationSent(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationTapped extends NotificationState {
  final String route;
  final Map<String, dynamic> data;

  const NotificationTapped(this.route, this.data);

  @override
  List<Object?> get props => [route, data];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService _notificationService;

  NotificationBloc({required NotificationService notificationService})
      : _notificationService = notificationService,
        super(NotificationInitial()) {
    on<NotificationInitialize>(_onInitialize);
    on<NotificationSendUserCreated>(_onSendUserCreated);
    on<NotificationSendUserUpdated>(_onSendUserUpdated);
    on<NotificationSendUserDeleted>(_onSendUserDeleted);
    on<NotificationSendWelcome>(_onSendWelcome);
    on<NotificationSendSync>(_onSendSync);
    on<NotificationSendNetworkRestored>(_onSendNetworkRestored);
    on<NotificationSendTest>(_onSendTest);
    on<NotificationHandleTap>(_onHandleTap);

    // Set up notification tap callback
    _notificationService.onNotificationTap = (route, data) {
      add(NotificationHandleTap(route, data));
    };
  }

  Future<void> _onInitialize(
    NotificationInitialize event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      print('=== INITIALIZING NOTIFICATION BLOC ===');
      await _notificationService.initialize();
      final token = await _notificationService.getFCMToken();
      print('=== NOTIFICATION BLOC INITIALIZED SUCCESSFULLY ===');
      emit(NotificationInitialized(fcmToken: token));
    } catch (e) {
      print('=== NOTIFICATION BLOC INITIALIZATION ERROR: $e ===');
      emit(NotificationError('Failed to initialize notifications: $e'));
    }
  }

  Future<void> _onSendUserCreated(
    NotificationSendUserCreated event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      print('=== SENDING USER CREATED NOTIFICATION: ${event.userName} ===');
      await _notificationService.showUserCreatedNotification(event.userName);
      emit(const NotificationSent('User created notification sent'));
    } catch (e) {
      print('=== ERROR SENDING USER CREATED NOTIFICATION: $e ===');
      emit(NotificationError('Failed to send user created notification: $e'));
    }
  }

  Future<void> _onSendUserUpdated(
    NotificationSendUserUpdated event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      print('=== SENDING USER UPDATED NOTIFICATION: ${event.userName} ===');
      await _notificationService.showUserUpdatedNotification(event.userName);
      emit(const NotificationSent('User updated notification sent'));
    } catch (e) {
      print('=== ERROR SENDING USER UPDATED NOTIFICATION: $e ===');
      emit(NotificationError('Failed to send user updated notification: $e'));
    }
  }

  Future<void> _onSendUserDeleted(
    NotificationSendUserDeleted event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      print('=== SENDING USER DELETED NOTIFICATION: ${event.userName} ===');
      await _notificationService.showUserDeletedNotification(event.userName);
      emit(const NotificationSent('User deleted notification sent'));
    } catch (e) {
      print('=== ERROR SENDING USER DELETED NOTIFICATION: $e ===');
      emit(NotificationError('Failed to send user deleted notification: $e'));
    }
  }

  Future<void> _onSendWelcome(
    NotificationSendWelcome event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      print('=== SENDING WELCOME NOTIFICATION ===');
      await _notificationService.showWelcomeNotification();
      emit(const NotificationSent('Welcome notification sent'));
    } catch (e) {
      print('=== ERROR SENDING WELCOME NOTIFICATION: $e ===');
      emit(NotificationError('Failed to send welcome notification: $e'));
    }
  }

  Future<void> _onSendSync(
    NotificationSendSync event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      print('=== SENDING SYNC NOTIFICATION: ${event.userCount} users ===');
      await _notificationService.showSyncNotification(event.userCount);
      emit(const NotificationSent('Sync notification sent'));
    } catch (e) {
      print('=== ERROR SENDING SYNC NOTIFICATION: $e ===');
      emit(NotificationError('Failed to send sync notification: $e'));
    }
  }

  Future<void> _onSendNetworkRestored(
    NotificationSendNetworkRestored event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      print('=== SENDING NETWORK RESTORED NOTIFICATION ===');
      await _notificationService.showNetworkRestoredNotification();
      emit(const NotificationSent('Network restored notification sent'));
    } catch (e) {
      print('=== ERROR SENDING NETWORK RESTORED NOTIFICATION: $e ===');
      emit(NotificationError('Failed to send network restored notification: $e'));
    }
  }

  Future<void> _onSendTest(
    NotificationSendTest event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      print('=== SENDING TEST NOTIFICATION ===');
      await _notificationService.showTestNotification();
      emit(const NotificationSent('Test notification sent successfully! 🎉'));
    } catch (e) {
      print('=== ERROR SENDING TEST NOTIFICATION: $e ===');
      emit(NotificationError('Failed to send test notification: $e'));
    }
  }

  void _onHandleTap(
    NotificationHandleTap event,
    Emitter<NotificationState> emit,
  ) {
    print('=== HANDLING NOTIFICATION TAP: ${event.route} ===');
    emit(NotificationTapped(event.route, event.data));
  }
}