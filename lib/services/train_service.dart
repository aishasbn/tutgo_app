import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../kondektur/services/enhanced_route_service.dart';
import '../kondektur/models/route_models.dart';
import '../models/kereta_model.dart';

class TrainService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Stream controllers for real-time updates - make them non-static
  final StreamController<List<Kereta>> _activeTrainsController = 
      StreamController<List<Kereta>>.broadcast();
  final StreamController<Map<String, dynamic>> _trainUpdateController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Kereta?> _activeTripController = 
      StreamController<Kereta?>.broadcast();

  // Getters for streams
  Stream<List<Kereta>> get activeTrainsStream => _activeTrainsController.stream;
  Stream<Map<String, dynamic>> get trainUpdateStream => _trainUpdateController.stream;
  Stream<Kereta?> get activeTripStream => _activeTripController.stream;

  // User's active trains (local storage)
  final List<String> _userActiveTrainCodes = [];
  Kereta? _currentActiveTrip;
  bool _seatConfirmed = false;
  Timer? _finishTimer;
  bool _isDisposed = false;

  // Singleton pattern
  static TrainService? _instance;
  static TrainService get instance {
    _instance ??= TrainService._internal();
    return _instance!;
  }
  
  TrainService._internal();
  
  factory TrainService() => instance;

  // Get available train codes from conductor service
  Future<List<String>> getAvailableTrainCodes() async {
    try {
      return EnhancedRouteService.getAvailableRouteCodes();
    } catch (e) {
      print('Error getting available codes: $e');
      return ['123456', '789012', '345678', '901234'];
    }
  }

  // Check if train code exists
  Future<bool> isValidTrainCode(String code) async {
    try {
      final routeInfo = EnhancedRouteService.getRouteInfo(code);
      return routeInfo != null;
    } catch (e) {
      print('Error checking train code: $e');
      return false;
    }
  }

  // Validate train code using conductor service (renamed from getTrainByCode)
  Future<Kereta?> getTrainByCode(String code) async {
    return await validateTrainCode(code);
  }

  // Validate train code using conductor service
  Future<Kereta?> validateTrainCode(String code) async {
    if (_isDisposed) {
      print('❌ TrainService is disposed, cannot validate code');
      return null;
    }

    try {
      print('🔍 Validating train code: $code');
      
      // Get route info from conductor service
      final routeInfo = EnhancedRouteService.getRouteInfo(code);
      if (routeInfo == null) {
        print('❌ Train code not found: $code');
        return null;
      }

      // Get detailed route data
      final routeResult = EnhancedRouteService.getRouteDetails(code);
      if (!routeResult.success || routeResult.routeData == null) {
        print('❌ Failed to get route details: $code');
        return null;
      }

      final routeData = routeResult.routeData!;
      
      // Convert to Kereta model for user interface
      final kereta = _convertRouteDataToKereta(routeData);
      
      // Set as active trip
      _currentActiveTrip = kereta;
      _safeAddToStream(_activeTripController, kereta);
      
      // Start finish timer for testing (1 minute)
      _startFinishTimer();
      
      // Add to user's active trains if not already added
      if (!_userActiveTrainCodes.contains(code)) {
        _userActiveTrainCodes.add(code);
        print('✅ Added train $code to user active trains');
      }

      // Notify listeners
      _notifyActiveTrainsUpdate();
      
      return kereta;
    } catch (e) {
      print('❌ Error validating train code: $e');
      return null;
    }
  }

  // Safe method to add to stream
  void _safeAddToStream<T>(StreamController<T> controller, T data) {
    if (!_isDisposed && !controller.isClosed) {
      controller.add(data);
    }
  }

  // Start timer for finish button (testing purpose)
  void _startFinishTimer() {
    _finishTimer?.cancel();
    _finishTimer = Timer(const Duration(minutes: 1), () {
      if (_currentActiveTrip != null && !_isDisposed) {
        // Update status to show finish button
        _currentActiveTrip = _currentActiveTrip!.copyWith(status: KeretaStatus.onRoute);
        _safeAddToStream(_activeTripController, _currentActiveTrip);
        print('🕐 Finish button available after 1 minute');
      }
    });
  }

  // Get current active trip
  Future<Kereta?> getActiveTrip() async {
    try {
      if (_currentActiveTrip != null) {
        // Update with latest data from conductor
        final routeResult = EnhancedRouteService.getRouteDetails(_currentActiveTrip!.kode);
        if (routeResult.success && routeResult.routeData != null) {
          final updatedKereta = _convertRouteDataToKereta(routeResult.routeData!);
          _currentActiveTrip = updatedKereta;
          _safeAddToStream(_activeTripController, _currentActiveTrip);
        }
      }
      return _currentActiveTrip;
    } catch (e) {
      print('❌ Error getting active trip: $e');
      return _currentActiveTrip;
    }
  }

  // Clear active trip
  Future<void> clearActiveTrip() async {
    try {
      if (_currentActiveTrip != null) {
        final code = _currentActiveTrip!.kode;
        _userActiveTrainCodes.remove(code);
        _currentActiveTrip = null;
        _seatConfirmed = false;
        _finishTimer?.cancel();
        _safeAddToStream(_activeTripController, null);
        _notifyActiveTrainsUpdate();
        print('✅ Cleared active trip: $code');
      }
    } catch (e) {
      print('❌ Error clearing active trip: $e');
    }
  }

  // Seat confirmation methods
  bool get isSeatConfirmed => _seatConfirmed;
  
  void confirmSeat() {
    _seatConfirmed = true;
    print('✅ Seat confirmed and saved');
  }

  // Get all active trains for user
  Future<List<Kereta>> getActiveTrains() async {
    try {
      List<Kereta> activeTrains = [];
      
      for (String code in _userActiveTrainCodes) {
        final routeResult = EnhancedRouteService.getRouteDetails(code);
        if (routeResult.success && routeResult.routeData != null) {
          final kereta = _convertRouteDataToKereta(routeResult.routeData!);
          activeTrains.add(kereta);
        }
      }
      
      return activeTrains;
    } catch (e) {
      print('❌ Error getting active trains: $e');
      return [];
    }
  }

  // Get train details by code
  Future<Kereta?> getTrainDetails(String code) async {
    try {
      final routeResult = EnhancedRouteService.getRouteDetails(code);
      if (!routeResult.success || routeResult.routeData == null) {
        return null;
      }

      return _convertRouteDataToKereta(routeResult.routeData!);
    } catch (e) {
      print('❌ Error getting train details: $e');
      return null;
    }
  }

  // Get route progress from conductor
  RouteProgress getRouteProgress(String code) {
    return EnhancedRouteService.getRouteProgress(code);
  }

  // Check if conductor is tracking this route
  bool isConductorTracking(String code) {
    return EnhancedRouteService.activeRouteCode == code && 
           EnhancedRouteService.isTracking;
  }

  // Get conductor's current position (using Map instead of Position)
  Map<String, double>? getConductorPosition() {
    final position = EnhancedRouteService.currentPosition;
    if (position != null) {
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    }
    return null;
  }

  // Listen to conductor updates
  void startListeningToConductorUpdates() {
    if (_isDisposed) return;

    // Listen to route updates from conductor
    EnhancedRouteService.routeUpdateStream.listen((routeUpdate) {
      if (_isDisposed) return;
      
      print('📡 Received route update: ${routeUpdate.routeCode}');
      
      // Update active trip if it matches
      if (_currentActiveTrip != null && _currentActiveTrip!.kode == routeUpdate.routeCode) {
        getActiveTrip(); // This will update the active trip with latest data
      }
      
      // Notify user interface about updates
      _safeAddToStream(_trainUpdateController, {
        'type': 'position_update',
        'routeCode': routeUpdate.routeCode,
        'position': routeUpdate.position,
        'timestamp': routeUpdate.timestamp,
      });
      
      // Update active trains
      _notifyActiveTrainsUpdate();
    });

    // Listen to station detection events
    EnhancedRouteService.stationDetectionStream.listen((stationEvent) {
      if (_isDisposed) return;
      
      print('🚉 Station event: ${stationEvent.eventType} at ${stationEvent.stationName}');
      
      // Notify user interface about station events
      _safeAddToStream(_trainUpdateController, {
        'type': 'station_event',
        'stationId': stationEvent.stationId,
        'stationName': stationEvent.stationName,
        'eventType': stationEvent.eventType.toString(),
      });
    });
  }

  // Convert RouteData to Kereta model
  Kereta _convertRouteDataToKereta(RouteData routeData) {
    // Convert stations to route
    List<StasiunRoute> route = routeData.stations.map((station) {
      return StasiunRoute(
        nama: station.name,
        waktu: station.estimatedDepartureTime ?? station.estimatedArrivalTime ?? '',
        isPassed: station.isPassed,
        isActive: station.id == routeData.currentStationId,
      );
    }).toList();

    // Determine status - always use willArrive for consistency
    KeretaStatus status = KeretaStatus.willArrive;

    // Calculate arrival countdown
    String? arrivalCountdown = '5-10 menit';

    // Create default gerbongs
    List<Gerbong> gerbongs = [
      Gerbong(kode: 'A', tipe: 'Eksekutif', kapasitas: 50, terisi: 35),
      Gerbong(kode: 'B', tipe: 'Ekonomi', kapasitas: 80, terisi: 65),
    ];

    return Kereta(
      kode: routeData.code,
      nama: routeData.routeName,
      fromStasiun: routeData.stations.isNotEmpty ? routeData.stations.first.name : '',
      toStasiun: routeData.stations.isNotEmpty ? routeData.stations.last.name : '',
      jadwal: '${routeData.departureTime} - ${_calculateArrivalTime(routeData)}',
      status: status,
      arrivalCountdown: arrivalCountdown,
      route: route,
      gerbongs: gerbongs,
    );
  }

  // Calculate estimated arrival time
  String _calculateArrivalTime(RouteData routeData) {
    if (routeData.stations.isNotEmpty) {
      final lastStation = routeData.stations.last;
      return lastStation.estimatedArrivalTime ?? 
             lastStation.estimatedDepartureTime ?? 
             'TBA';
    }
    return 'TBA';
  }

  // Notify active trains update
  void _notifyActiveTrainsUpdate() async {
    if (_isDisposed) return;
    
    try {
      final activeTrains = await getActiveTrains();
      _safeAddToStream(_activeTrainsController, activeTrains);
    } catch (e) {
      print('❌ Error notifying active trains update: $e');
    }
  }

  // Remove train from active list
  Future<bool> finishJourney(String code) async {
    try {
      _userActiveTrainCodes.remove(code);
      
      // Clear active trip if it matches
      if (_currentActiveTrip != null && _currentActiveTrip!.kode == code) {
        _currentActiveTrip = null;
        _seatConfirmed = false;
        _finishTimer?.cancel();
        _safeAddToStream(_activeTripController, null);
      }
      
      _notifyActiveTrainsUpdate();
      
      print('✅ Finished journey for train: $code');
      return true;
    } catch (e) {
      print('❌ Error finishing journey: $e');
      return false;
    }
  }

  // Get next station for notification
  Map<String, dynamic>? getNextStation(String code) {
    final progress = getRouteProgress(code);
    if (progress.nextStation != null) {
      return {
        'name': progress.nextStation!.name,
        'time': progress.nextStation!.estimatedArrivalTime ?? 
                progress.nextStation!.estimatedDepartureTime ?? '',
      };
    }
    return null;
  }

  // Debug method to print all train data
  Future<void> debugPrintAllTrains() async {
    try {
      final codes = await getAvailableTrainCodes();
      print('Available train codes: $codes');
      
      for (String code in codes) {
        final routeInfo = EnhancedRouteService.getRouteInfo(code);
        print('Code: $code, Route: ${routeInfo?.routeName ?? "Unknown"}');
      }
    } catch (e) {
      print('Error debugging trains: $e');
    }
  }

  // Dispose resources
  void dispose() {
    if (_isDisposed) return;
    
    _isDisposed = true;
    _finishTimer?.cancel();
    
    if (!_activeTrainsController.isClosed) {
      _activeTrainsController.close();
    }
    if (!_trainUpdateController.isClosed) {
      _trainUpdateController.close();
    }
    if (!_activeTripController.isClosed) {
      _activeTripController.close();
    }
    
    print('✅ TrainService disposed');
  }
}
