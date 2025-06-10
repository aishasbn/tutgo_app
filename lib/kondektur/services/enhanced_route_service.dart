import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/route_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnhancedRouteService {
  static final Map<String, RouteData> _localRoutes = {};
  
  // GPS Tracking
  static StreamSubscription<Position>? _positionStream;
  static Position? _currentPosition;
  static String? _activeRouteCode;
  static bool _isTracking = false;
  
  // Auto-detection settings
  static const double STATION_DETECTION_RADIUS = 50.0;
  static const int STATION_DWELL_TIME = 3;
  static final Map<String, DateTime> _stationDwellTimes = {};
  
  // Stream controllers for real-time updates
  static final StreamController<Position> _positionController = 
      StreamController<Position>.broadcast();
  static final StreamController<RouteUpdate> _routeUpdateController = 
      StreamController<RouteUpdate>.broadcast();
  static final StreamController<StationDetectionEvent> _stationDetectionController = 
      StreamController<StationDetectionEvent>.broadcast();
  
  // Getters
  static Stream<Position> get positionStream => _positionController.stream;
  static Stream<RouteUpdate> get routeUpdateStream => _routeUpdateController.stream;
  static Stream<StationDetectionEvent> get stationDetectionStream => _stationDetectionController.stream;
  static Position? get currentPosition => _currentPosition;
  static bool get isTracking => _isTracking;
  static String? get activeRouteCode => _activeRouteCode;

  // Firebase integration
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static Timer? _syncTimer;

  // Real-time sync to Firebase
  static Future<void> _syncToFirebase() async {
    if (_activeRouteCode == null || _currentPosition == null) return;
    
    try {
      final routeData = _localRoutes[_activeRouteCode];
      if (routeData == null) return;

      final routeDoc = {
        'routeCode': _activeRouteCode,
        'routeName': routeData.routeName,
        'description': routeData.description,
        'conductorName': routeData.conductorName,
        'conductorId': routeData.conductorId,
        'status': routeData.status.toString().split('.').last,
        'lastUpdate': FieldValue.serverTimestamp(),
        'currentPosition': {
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
          'accuracy': _currentPosition!.accuracy,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'currentStationIndex': _getCurrentStationIndex(),
        'totalStations': routeData.stations.length,
        'stations': routeData.stations.map((station) => {
          'id': station.id,
          'name': station.name,
          'latitude': station.latitude,
          'longitude': station.longitude,
          'sequenceOrder': station.sequenceOrder,
          'isPassed': station.isPassed,
          'passedAt': station.actualArrivalTime?.toIso8601String(),
          'estimatedTime': station.estimatedArrivalTime ?? station.estimatedDepartureTime,
        }).toList(),
      };

      await _firestore
          .collection('active_routes')
          .doc(_activeRouteCode)
          .set(routeDoc, SetOptions(merge: true));

      print('✅ Synced to Firebase: $_activeRouteCode');
    } catch (e) {
      print('❌ Firebase sync error: $e');
    }
  }

  static int _getCurrentStationIndex() {
    if (_activeRouteCode == null) return 0;
    final routeData = _localRoutes[_activeRouteCode];
    if (routeData == null) return 0;
    
    return routeData.stations.where((s) => s.isPassed).length;
  }

  static void _startFirebaseSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _syncToFirebase();
    });
  }

  static void _stopFirebaseSync() {
    _syncTimer?.cancel();
  }

  // Predefined routes - Fixed route codes
  static final Map<String, RouteData> _predefinedRoutes = {
    'TG001': RouteData(
      code: 'TG001',
      routeKey: 'keputih_pens_route',
      routeName: 'Keputih - PENS Testing Route',
      description: 'Route testing dari Keputih Tegal Timur menuju Kampus PENS',
      conductorName: '',
      conductorId: '',
      departureDate: '',
      departureTime: '08:00',
      stations: [
        StationData(
          id: '1',
          name: 'Keputih Tegal Timur 2 No.14',
          sequenceOrder: 1,
          estimatedArrivalTime: null,
          estimatedDepartureTime: '08:00',
          latitude: -7.290580666587299,
          longitude: 112.80399940180712,
        ),
        StationData(
          id: '2',
          name: 'Jalan Keputih Timur',
          sequenceOrder: 2,
          estimatedArrivalTime: '08:05',
          estimatedDepartureTime: '08:07',
          latitude: -7.286845624734853,
          longitude: 112.80209848624483,
        ),
        StationData(
          id: '3',
          name: 'Jalan Kejawan Putih Tambak',
          sequenceOrder: 3,
          estimatedArrivalTime: '08:12',
          estimatedDepartureTime: '08:14',
          latitude: -7.278872643529261,
          longitude: 112.80238127170834,
        ),
        StationData(
          id: '4',
          name: 'Kampus PENS',
          sequenceOrder: 4,
          estimatedArrivalTime: '08:20',
          estimatedDepartureTime: null,
          latitude: -7.275821242189998,
          longitude: 112.79313757103208,
        ),
      ],
      status: RouteStatus.pending,
      createdAt: DateTime.now(),
    ),
    
    'TG002': RouteData(
      code: 'TG002',
      routeKey: 'jakarta_bandung',
      routeName: 'Jakarta - Bandung Express',
      description: 'Kereta cepat Jakarta menuju Bandung via Bekasi',
      conductorName: '',
      conductorId: '',
      departureDate: '',
      departureTime: '06:30',
      stations: [
        StationData(
          id: '1',
          name: 'Jakarta Kota',
          sequenceOrder: 1,
          estimatedArrivalTime: null,
          estimatedDepartureTime: '06:30',
          latitude: -6.137778,
          longitude: 106.813889,
        ),
        StationData(
          id: '2',
          name: 'Manggarai',
          sequenceOrder: 2,
          estimatedArrivalTime: '06:45',
          estimatedDepartureTime: '06:50',
          latitude: -6.214028,
          longitude: 106.850556,
        ),
        StationData(
          id: '3',
          name: 'Bekasi',
          sequenceOrder: 3,
          estimatedArrivalTime: '07:15',
          estimatedDepartureTime: '07:20',
          latitude: -6.238889,
          longitude: 107.001389,
        ),
        StationData(
          id: '4',
          name: 'Bandung',
          sequenceOrder: 4,
          estimatedArrivalTime: '09:15',
          estimatedDepartureTime: null,
          latitude: -6.921389,
          longitude: 107.606944,
        ),
      ],
      status: RouteStatus.pending,
      createdAt: DateTime.now(),
    ),
    
    'TG003': RouteData(
      code: 'TG003',
      routeKey: 'surabaya_malang',
      routeName: 'Surabaya - Malang Regional',
      description: 'Kereta regional Surabaya menuju Malang via Sidoarjo',
      conductorName: '',
      conductorId: '',
      departureDate: '',
      departureTime: '07:00',
      stations: [
        StationData(
          id: '1',
          name: 'Surabaya Gubeng',
          sequenceOrder: 1,
          estimatedArrivalTime: null,
          estimatedDepartureTime: '07:00',
          latitude: -7.265757,
          longitude: 112.752088,
        ),
        StationData(
          id: '2',
          name: 'Sidoarjo',
          sequenceOrder: 2,
          estimatedArrivalTime: '07:30',
          estimatedDepartureTime: '07:35',
          latitude: -7.448611,
          longitude: 112.718056,
        ),
        StationData(
          id: '3',
          name: 'Malang',
          sequenceOrder: 3,
          estimatedArrivalTime: '09:00',
          estimatedDepartureTime: null,
          latitude: -7.966667,
          longitude: 112.633333,
        ),
      ],
      status: RouteStatus.pending,
      createdAt: DateTime.now(),
    ),
  };

  // Initialize predefined routes
  static void _initializePredefinedRoutes() {
    _localRoutes.clear();
    _localRoutes.addAll(_predefinedRoutes);
    print('🚂 Initialized ${_localRoutes.length} predefined routes');
    print('📋 Available routes: ${_localRoutes.keys.toList()}');
  }

  // Get all available route codes
  static List<String> getAvailableRouteCodes() {
    _initializePredefinedRoutes();
    return _predefinedRoutes.keys.toList();
  }

  // Get route info by code
  static RouteInfo? getRouteInfo(String code) {
    print('🔍 Getting route info for: $code');
    _initializePredefinedRoutes();
    
    if (_predefinedRoutes.containsKey(code)) {
      final route = _predefinedRoutes[code]!;
      print('✅ Found route: ${route.routeName}');
      return RouteInfo(
        code: code,
        routeName: route.routeName,
        description: route.description,
        stationCount: route.stations.length,
        departureTime: route.departureTime,
      );
    }
    print('❌ Route not found: $code');
    return null;
  }

  // Activate route with conductor info
  static RouteCodeResult activateRoute({
    required String routeCode,
    required String conductorName,
    required String conductorId,
    required String departureDate,
  }) {
    print('🚀 Activating route: $routeCode for $conductorName');
    _initializePredefinedRoutes();
    
    if (!_predefinedRoutes.containsKey(routeCode)) {
      print('❌ Route code not found in predefined routes');
      return RouteCodeResult(
        success: false,
        message: 'Route code not found',
      );
    }

    // Create a copy of the predefined route with conductor info
    final originalRoute = _predefinedRoutes[routeCode]!;
    final activatedRoute = RouteData(
      code: originalRoute.code,
      routeKey: originalRoute.routeKey,
      routeName: originalRoute.routeName,
      description: originalRoute.description,
      conductorName: conductorName,
      conductorId: conductorId,
      departureDate: departureDate,
      departureTime: originalRoute.departureTime,
      stations: originalRoute.stations.map((station) => StationData.copy(station)).toList(),
      status: RouteStatus.pending,
      createdAt: DateTime.now(),
    );

    _localRoutes[routeCode] = activatedRoute;
    
    print('✅ Route $routeCode activated for conductor $conductorName');
    
    return RouteCodeResult(
      success: true,
      code: routeCode,
      message: 'Route activated successfully',
    );
  }

  // Initialize GPS tracking
  static Future<LocationResult> initializeGPS() async {
    try {
      print('🔍 Initializing GPS...');
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('📍 Location service enabled: $serviceEnabled');
      
      if (!serviceEnabled) {
        print('❌ Location services disabled');
        return LocationResult(
          success: false,
          message: 'Location services are disabled. Please enable GPS.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      print('📍 Current permission: $permission');
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print('📍 Permission after request: $permission');
        if (permission == LocationPermission.denied) {
          return LocationResult(
            success: false,
            message: 'Location permissions are denied',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          success: false,
          message: 'Location permissions are permanently denied. Please enable in settings.',
        );
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      _currentPosition = position;
      print('✅ GPS initialized at: ${position.latitude}, ${position.longitude}');
      
      return LocationResult(
        success: true,
        message: 'GPS initialized successfully',
        position: position,
      );
    } catch (e) {
      print('❌ GPS initialization error: $e');
      return LocationResult(
        success: false,
        message: 'Failed to initialize GPS: $e',
      );
    }
  }

  // Start conductor tracking
  static Future<TrackingResult> startConductorTracking(String routeCode) async {
    try {
      print('🚂 Starting conductor tracking for route: $routeCode');
      
      final gpsResult = await initializeGPS();
      if (!gpsResult.success) {
        print('❌ GPS initialization failed: ${gpsResult.message}');
        return TrackingResult(
          success: false,
          message: gpsResult.message,
        );
      }

      _activeRouteCode = routeCode;
      _isTracking = true;
      _startFirebaseSync();
      await _syncToFirebase(); // Initial sync
      _stationDwellTimes.clear();

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
        timeLimit: Duration(seconds: 1),
      );

      print('📡 Starting position stream...');
      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          print('📍 New position: ${position.latitude}, ${position.longitude}');
          _currentPosition = position;
          _positionController.add(position);
          _handleLocationUpdate(position);
        },
        onError: (error) {
          print('❌ Location stream error: $error');
          Fluttertoast.showToast(msg: 'GPS tracking error: $error');
        },
      );

      print('✅ GPS tracking started successfully');
      return TrackingResult(
        success: true,
        message: 'Conductor tracking started successfully',
      );
    } catch (e) {
      print('❌ Tracking start error: $e');
      return TrackingResult(
        success: false,
        message: 'Failed to start tracking: $e',
      );
    }
  }

  // Handle location updates
  static void _handleLocationUpdate(Position position) async {
    if (_activeRouteCode == null) return;

    try {
      await _checkStationProximityAutomatic(position);
      
      _routeUpdateController.add(RouteUpdate(
        routeCode: _activeRouteCode!,
        position: position,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      print('❌ Error handling location update: $e');
    }
  }

  static Future<void> _checkStationProximityAutomatic(Position position) async {
    if (_activeRouteCode == null) return;

    final routeData = _localRoutes[_activeRouteCode];
    if (routeData == null) return;

    final nextStation = routeData.stations.firstWhere(
      (station) => !station.isPassed,
      orElse: () => StationData.empty(),
    );

    if (nextStation.id.isEmpty || nextStation.latitude == null || nextStation.longitude == null) {
      return;
    }

    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      nextStation.latitude!,
      nextStation.longitude!,
    );

    print('📏 Distance to ${nextStation.name}: ${distance.toInt()}m');

    if (distance <= STATION_DETECTION_RADIUS) {
      final now = DateTime.now();
      
      if (!_stationDwellTimes.containsKey(nextStation.id)) {
        _stationDwellTimes[nextStation.id] = now;
        print('⏱️ Started dwell timer for ${nextStation.name}');
        
        _stationDetectionController.add(StationDetectionEvent(
          stationId: nextStation.id,
          stationName: nextStation.name,
          distance: distance,
          eventType: StationEventType.approaching,
        ));
      } else {
        final dwellStartTime = _stationDwellTimes[nextStation.id]!;
        final dwellDuration = now.difference(dwellStartTime).inSeconds;
        
        if (dwellDuration >= STATION_DWELL_TIME && !nextStation.isPassed) {
          print('✅ Auto-marking ${nextStation.name} as passed');
          await _markStationPassedAutomatically(nextStation.id);
        }
      }
    }
  }

  static Future<StationUpdateResult> _markStationPassedAutomatically(String stationId) async {
    if (_activeRouteCode == null || _currentPosition == null) {
      return StationUpdateResult(
        success: false,
        message: 'No active route or GPS position',
      );
    }

    try {
      final localResult = _markStationPassedLocally(stationId);
      
      if (localResult.success) {
        _stationDetectionController.add(StationDetectionEvent(
          stationId: stationId,
          stationName: localResult.stationData!.name,
          eventType: StationEventType.arrived,
        ));
      }
      
      await _syncToFirebase();
      return localResult;
    } catch (e) {
      print('❌ Error marking station: $e');
      return StationUpdateResult(
        success: false,
        message: 'Error marking station: $e',
      );
    }
  }

  static StationUpdateResult _markStationPassedLocally(String stationId) {
    if (_activeRouteCode == null) {
      return StationUpdateResult(
        success: false,
        message: 'No active route',
      );
    }

    final routeData = _localRoutes[_activeRouteCode];
    if (routeData == null) {
      return StationUpdateResult(
        success: false,
        message: 'Route data not found',
      );
    }

    final stationIndex = routeData.stations.indexWhere((s) => s.id == stationId);
    if (stationIndex == -1) {
      return StationUpdateResult(
        success: false,
        message: 'Station not found',
      );
    }

    final station = routeData.stations[stationIndex];
    
    station.isPassed = true;
    station.actualArrivalTime = DateTime.now();
    
    routeData.currentStationId = stationId;
    routeData.status = RouteStatus.active;
    routeData.lastUpdate = DateTime.now();
    
    if (stationIndex == routeData.stations.length - 1) {
      routeData.status = RouteStatus.completed;
      routeData.completedAt = DateTime.now();
      
      _stationDetectionController.add(StationDetectionEvent(
        stationId: stationId,
        stationName: station.name,
        eventType: StationEventType.routeCompleted,
      ));
    }
    
    return StationUpdateResult(
      success: true,
      message: 'Station marked as passed successfully',
      stationData: station,
    );
  }

  static Future<void> stopTracking() async {
    print('🛑 Stopping GPS tracking');
    _stopFirebaseSync();
    
    if (_activeRouteCode != null) {
      try {
        await _firestore
            .collection('active_routes')
            .doc(_activeRouteCode)
            .update({
          'status': 'stopped',
          'stoppedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('❌ Error updating stop status: $e');
      }
    }
    
    _positionStream?.cancel();
    _positionStream = null;
    _isTracking = false;
    _activeRouteCode = null;
    _stationDwellTimes.clear();
  }

  // Get route details
  static RouteDetailsResult getRouteDetails(String code) {
    print('📋 Getting route details for: $code');
    _initializePredefinedRoutes();
    
    if (!_localRoutes.containsKey(code)) {
      print('❌ Route details not found for: $code');
      return RouteDetailsResult(
        success: false,
        message: 'Route code not found',
      );
    }
    
    print('✅ Route details found for: $code');
    return RouteDetailsResult(
      success: true,
      message: 'Route details found',
      routeData: _localRoutes[code]!,
    );
  }

  // Get route progress
  static RouteProgress getRouteProgress(String routeCode) {
    if (!_localRoutes.containsKey(routeCode)) {
      return RouteProgress(
        totalStations: 0,
        passedStations: 0,
        currentStation: null,
        nextStation: null,
        isCompleted: false,
      );
    }
    
    final routeData = _localRoutes[routeCode]!;
    final passedStations = routeData.stations.where((s) => s.isPassed).length;
    final currentStation = routeData.stations.where((s) => s.isPassed).isNotEmpty 
        ? routeData.stations.where((s) => s.isPassed).last 
        : null;
    final nextStation = routeData.stations.firstWhere(
      (station) => !station.isPassed,
      orElse: () => StationData.empty(),
    );
    
    return RouteProgress(
      totalStations: routeData.stations.length,
      passedStations: passedStations,
      currentStation: currentStation,
      nextStation: nextStation.id.isNotEmpty ? nextStation : null,
      isCompleted: routeData.status == RouteStatus.completed,
    );
  }

  // Get polyline for route path
  static Polyline? getRoutePolyline(String routeCode) {
    final routeData = _localRoutes[routeCode];
    if (routeData == null) return null;

    final points = routeData.stations
        .where((station) => station.latitude != null && station.longitude != null)
        .map((station) => LatLng(station.latitude!, station.longitude!))
        .toList();

    if (points.length < 2) return null;

    return Polyline(
      polylineId: PolylineId('route_$routeCode'),
      points: points,
      color: Color(0xFFD75A9E),
      width: 4,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
    );
  }

  // Dispose resources
  static void dispose() {
    stopTracking();
    _positionController.close();
    _routeUpdateController.close();
    _stationDetectionController.close();
  }
}

// Data Models
class LocationResult {
  final bool success;
  final String message;
  final Position? position;

  LocationResult({
    required this.success,
    required this.message,
    this.position,
  });
}

class TrackingResult {
  final bool success;
  final String message;

  TrackingResult({
    required this.success,
    required this.message,
  });
}

class RouteUpdate {
  final String routeCode;
  final Position position;
  final DateTime timestamp;

  RouteUpdate({
    required this.routeCode,
    required this.position,
    required this.timestamp,
  });
}

class RouteInfo {
  final String code;
  final String routeName;
  final String description;
  final int stationCount;
  final String departureTime;

  RouteInfo({
    required this.code,
    required this.routeName,
    required this.description,
    required this.stationCount,
    required this.departureTime,
  });
}

class RouteCodeResult {
  final bool success;
  final String message;
  final String? code;

  RouteCodeResult({
    required this.success,
    required this.message,
    this.code,
  });
}

class RouteDetailsResult {
  final bool success;
  final String message;
  final RouteData? routeData;

  RouteDetailsResult({
    required this.success,
    required this.message,
    this.routeData,
  });
}

class StationUpdateResult {
  final bool success;
  final String message;
  final StationData? stationData;

  StationUpdateResult({
    required this.success,
    required this.message,
    this.stationData,
  });
}

class RouteProgress {
  final int totalStations;
  final int passedStations;
  final StationData? currentStation;
  final StationData? nextStation;
  final bool isCompleted;

  RouteProgress({
    required this.totalStations,
    required this.passedStations,
    this.currentStation,
    this.nextStation,
    required this.isCompleted,
  });
}
