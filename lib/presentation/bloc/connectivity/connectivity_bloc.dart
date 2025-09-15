import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/connectivity_service.dart';

// Events
abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object> get props => [];
}

class ConnectivityStarted extends ConnectivityEvent {}

class ConnectivityChanged extends ConnectivityEvent {
  final bool isConnected;

  const ConnectivityChanged(this.isConnected);

  @override
  List<Object> get props => [isConnected];
}

class ConnectivityCheckRequested extends ConnectivityEvent {}

// States
abstract class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object> get props => [];
}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivityChecking extends ConnectivityState {}

class ConnectivityConnected extends ConnectivityState {}

class ConnectivityDisconnected extends ConnectivityState {}

class ConnectivityRestored extends ConnectivityState {}

// BLoC
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityService _connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _wasDisconnected = false;

  ConnectivityBloc({required ConnectivityService connectivityService})
    : _connectivityService = connectivityService,
      super(ConnectivityInitial()) {
    on<ConnectivityStarted>(_onConnectivityStarted);
    on<ConnectivityChanged>(_onConnectivityChanged);
    on<ConnectivityCheckRequested>(_onConnectivityCheckRequested);
  }

  Future<void> _onConnectivityStarted(
    ConnectivityStarted event,
    Emitter<ConnectivityState> emit,
  ) async {
    emit(ConnectivityChecking());

    try {
      // Initialize the service first
      await _connectivityService.initialize();

      // Check initial connectivity
      final isConnected = await _connectivityService.isConnected;

      if (isConnected) {
        emit(ConnectivityConnected());
      } else {
        _wasDisconnected = true;
        emit(ConnectivityDisconnected());
      }

      // Listen to connectivity changes
      await _connectivitySubscription?.cancel();
      _connectivitySubscription = _connectivityService.onConnectivityChanged
          .listen((isConnected) => add(ConnectivityChanged(isConnected)));
    } catch (e) {
      _wasDisconnected = true;
      emit(ConnectivityDisconnected());
    }
  }

  Future<void> _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<ConnectivityState> emit,
  ) async {
    if (event.isConnected) {
      if (_wasDisconnected) {
        // Network was restored after being disconnected
        emit(ConnectivityRestored());
        _wasDisconnected = false;

        // After a brief moment, emit normal connected state
        await Future.delayed(const Duration(milliseconds: 500));
        emit(ConnectivityConnected());
      } else {
        // Just connected normally
        emit(ConnectivityConnected());
      }
    } else {
      // Lost connection
      _wasDisconnected = true;
      emit(ConnectivityDisconnected());
    }
  }

  Future<void> _onConnectivityCheckRequested(
    ConnectivityCheckRequested event,
    Emitter<ConnectivityState> emit,
  ) async {
    emit(ConnectivityChecking());

    final isConnected = await _connectivityService.isConnected;

    if (isConnected) {
      if (_wasDisconnected) {
        emit(ConnectivityRestored());
        _wasDisconnected = false;

        await Future.delayed(const Duration(milliseconds: 500));
        emit(ConnectivityConnected());
      } else {
        emit(ConnectivityConnected());
      }
    } else {
      _wasDisconnected = true;
      emit(ConnectivityDisconnected());
    }
  }

  bool get isConnected => state is ConnectivityConnected;
  bool get isDisconnected => state is ConnectivityDisconnected;

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _connectivityService.dispose();
    return super.close();
  }
}
