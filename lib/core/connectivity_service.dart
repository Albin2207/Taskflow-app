import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _streamController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isConnected = false;

  Future<bool> get isConnected async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _hasValidConnection(results);
    } catch (e) {
      return false;
    }
  }

  bool get currentConnectionStatus => _isConnected;

  Stream<bool> get onConnectivityChanged {
    _streamController ??= StreamController<bool>.broadcast();

    _subscription ??= _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        final isConnected = _hasValidConnection(results);

        // Only emit if connection status actually changed
        if (_isConnected != isConnected) {
          _isConnected = isConnected;

          // Add slight delay to ensure network is actually available
          if (isConnected) {
            await Future.delayed(const Duration(milliseconds: 500));
            // Double check with actual connectivity test
            final actuallyConnected = await _testActualConnectivity();
            _isConnected = actuallyConnected;
            _streamController?.add(actuallyConnected);
          } else {
            _streamController?.add(false);
          }
        }
      },
      onError: (error) {
        _isConnected = false;
        _streamController?.add(false);
      },
    );

    return _streamController!.stream;
  }

  bool _hasValidConnection(List<ConnectivityResult> results) {
    return results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );
  }

  Future<bool> _testActualConnectivity() async {
    try {
      // Test actual internet connectivity with a simple HTTP request
      final result = await _connectivity.checkConnectivity();
      return _hasValidConnection(result);
    } catch (e) {
      return false;
    }
  }

  Future<void> initialize() async {
    _isConnected = await isConnected;
  }

  void dispose() {
    _subscription?.cancel();
    _streamController?.close();
    _subscription = null;
    _streamController = null;
  }
}
