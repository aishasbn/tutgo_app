import 'dart:async';
//import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../models/route_models.dart';

class EnhancedRouteService {
  //static const String baseUrl = 'https://your-api-domain.com/api';
  static final Map<String, RouteData> _localRoutes = {};
  
  // GPS Tracking
  static StreamSubscription<Position>? _positionStream;
  static Position? _currentPosition;
  static String? _activeRouteCode;
  static bool _isTracking = false;
  
  // Auto-detection settings
  static const double STATION_DETECTION_RADIUS = 50.0; // Reduced for testing
  static const int STATION_DWELL_TIME = 3; // Reduced for testing
  static Map<String, DateTime> _stationDwellTimes = {};
  
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

  // Predefined routes - Menggunakan angka saja
  static final Map<String, RouteData> _predefinedRoutes = {
    '123456': RouteData(
      code: '123456',
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
    
    '789012': RouteData(
      code: '789012',
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
          name: 'Cikarang',
          sequenceOrder: 4,
          estimatedArrivalTime: '07:45',
          estimatedDepartureTime: '07:50',
          latitude: -6.261111,
          longitude: 107.152778,
        ),
        StationData(
          id: '5',
          name: 'Purwakarta',
          sequenceOrder: 5,
          estimatedArrivalTime: '08:30',
          estimatedDepartureTime: '08:35',
          latitude: -6.556944,
          longitude: 107.434167,
        ),
        StationData(
          id: '6',
          name: 'Bandung',
          sequenceOrder: 6,
          estimatedArrivalTime: '09:15',
          estimatedDepartureTime: null,
          latitude: -6.921389,
          longitude: 107.606944,
        ),
      ],
      status: RouteStatus.pending,
      createdAt: DateTime.now(),
    ),
    
    '345678': RouteData(
      code: '345678',
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
          name: 'Bangil',
          sequenceOrder: 3,
          estimatedArrivalTime: '08:15',
          estimatedDepartureTime: '08:20',
          latitude: -7.599167,
          longitude: 112.818889,
        ),
        StationData(
          id: '4',
          name: 'Malang',
          sequenceOrder: 4,
          estimatedArrivalTime: '09:00',
          estimatedDepartureTime: null,
          latitude: -7.966667,
          longitude: 112.633333,
        ),
      ],
      status: RouteStatus.pending,
      createdAt: DateTime.now(),
    ),
    
    '901234': RouteData(
      code: '901234',
      routeKey: 'yogyakarta_solo',
      routeName: 'Yogyakarta - Solo Ekspres',
      description: 'Kereta ekspres Yogyakarta menuju Solo',
      conductorName: '',
      conductorId: '',
      departureDate: '',
      departureTime: '08:00',
      stations: [
        StationData(
          id: '1',
          name: 'Yogyakarta Tugu',
          sequenceOrder: 1,
          estimatedArrivalTime: null,
          estimatedDepartureTime: '08:00',
          latitude: -7.789056,
          longitude: 110.363611,
        ),
        StationData(
          id: '2',
          name: 'Klaten',
          sequenceOrder: 2,
          estimatedArrivalTime: '08:45',
          estimatedDepartureTime: '08:50',
          latitude: -7.705833,
          longitude: 110.606111,
        ),
        StationData(
          id: '3',
          name: 'Solo Balapan',
          sequenceOrder: 3,
          estimatedArrivalTime: '09:30',
          estimatedDepartureTime: null,
          latitude: -7.556111,
          longitude: 110.824167,
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
  }

  // Get all available route codes
  static List<String> getAvailableRouteCodes() {
    _initializePredefinedRoutes();
    return _predefinedRoutes.keys.toList();
  }

  // Get route info by code
  static RouteInfo? getRouteInfo(String code) {
    if (_predefinedRoutes.containsKey(code)) {
      final route = _predefinedRoutes[code]!;
      return RouteInfo(
        code: code,
        routeName: route.routeName,
        description: route.description,
        stationCount: route.stations.length,
        departureTime: route.departureTime,
      );
    }
    return null;
  }

  // Activate route with conductor info
  static RouteCodeResult activateRoute({
    required String routeCode,
    required String conductorName,
    required String conductorId,
    required String departureDate,
  }) {
    if (!_predefinedRoutes.containsKey(routeCode)) {
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
        return TrackingResult(
          success: false,
          message: gpsResult.message,
        );
      }

      _activeRouteCode = routeCode;
      _isTracking = true;
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

      // Check if we're already near the first station
      if (_localRoutes.containsKey(routeCode)) {
        final routeData = _localRoutes[routeCode]!;
        if (routeData.stations.isNotEmpty) {
          final firstStation = routeData.stations.first;
          if (firstStation.latitude != null && firstStation.longitude != null) {
            final distance = Geolocator.distanceBetween(
              gpsResult.position!.latitude,
              gpsResult.position!.longitude,
              firstStation.latitude!,
              firstStation.longitude!,
            );
            
            print('📏 Distance to first station ${firstStation.name}: ${distance.toInt()}m');
            
            if (distance < STATION_DETECTION_RADIUS) {
              print('✅ Auto-marking first station as passed');
              _markStationPassedAutomatically(firstStation.id);
            }
          }
        }
      }

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
      await _sendLocationToServer(position);
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

  static Future<void> _sendLocationToServer(Position position) async {
    try {
      print('📤 Would send location to server: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('❌ Error sending location to server: $e');
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

    print('📏 Distance to ${nextStation.name}: ${distance.toInt()}m (threshold: ${STATION_DETECTION_RADIUS.toInt()}m)');

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
        
        Fluttertoast.showToast(
          msg: 'Approaching ${nextStation.name} (${distance.toInt()}m)',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.blue,
        );
      } else {
        final dwellStartTime = _stationDwellTimes[nextStation.id]!;
        final dwellDuration = now.difference(dwellStartTime).inSeconds;
        
        print('⏱️ Dwell time at ${nextStation.name}: ${dwellDuration}s (threshold: ${STATION_DWELL_TIME}s)');
        
        if (dwellDuration >= STATION_DWELL_TIME && !nextStation.isPassed) {
          print('✅ Auto-marking ${nextStation.name} as passed');
          await _markStationPassedAutomatically(nextStation.id);
        }
      }
    } else {
      if (_stationDwellTimes.containsKey(nextStation.id)) {
        print('🔄 Reset dwell timer for ${nextStation.name} (moved away)');
        _stationDwellTimes.remove(nextStation.id);
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
      print('🎯 Marking station $stationId as passed automatically');
      
      final localResult = _markStationPassedLocally(stationId);
      
      if (localResult.success) {
        _stationDetectionController.add(StationDetectionEvent(
          stationId: stationId,
          stationName: localResult.stationData!.name,
          eventType: StationEventType.arrived,
        ));
        
        Fluttertoast.showToast(
          msg: '✅ Arrived at ${localResult.stationData!.name}',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.green,
        );
        
        print('✅ Successfully marked ${localResult.stationData!.name} as passed');
      }
      
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
    
    print('📊 Station ${station.name} marked as passed. Progress: ${stationIndex + 1}/${routeData.stations.length}');
    
    if (stationIndex == routeData.stations.length - 1) {
      routeData.status = RouteStatus.completed;
      routeData.completedAt = DateTime.now();
      
      print('🏁 Route completed!');
      
      _stationDetectionController.add(StationDetectionEvent(
        stationId: stationId,
        stationName: station.name,
        eventType: StationEventType.routeCompleted,
      ));
      
      Future.delayed(Duration(seconds: 3), () {
        stopTracking();
      });
    }
    
    return StationUpdateResult(
      success: true,
      message: 'Station marked as passed successfully',
      stationData: station,
    );
  }

  static void stopTracking() {
    print('🛑 Stopping GPS tracking');
    _positionStream?.cancel();
    _positionStream = null;
    _isTracking = false;
    _activeRouteCode = null;
    _stationDwellTimes.clear();
    
    Fluttertoast.showToast(msg: 'GPS tracking stopped');
  }

  // Get route details
  static RouteDetailsResult getRouteDetails(String code) {
    if (!_localRoutes.containsKey(code)) {
      return RouteDetailsResult(
        success: false,
        message: 'Route code not found',
      );
    }
    
    return RouteDetailsResult(
      success: true,
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

  // Get markers for Google Maps
  static Set<Marker> getRouteMarkers(String routeCode) {
    final routeData = _localRoutes[routeCode];
    if (routeData == null) return {};

    return routeData.stations.map((station) {
      return Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.latitude!, station.longitude!),
        infoWindow: InfoWindow(
          title: station.name,
          snippet: station.isPassed ? 'Passed ✅' : 'Upcoming 📍',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          station.isPassed 
            ? BitmapDescriptor.hueGreen 
            : BitmapDescriptor.hueRed,
        ),
      );
    }).toSet();
  }

  // Get conductor marker
  static Marker? getConductorMarker() {
    if (_currentPosition == null) return null;

    return Marker(
      markerId: MarkerId('conductor'),
      position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      infoWindow: InfoWindow(
        title: '🚂 Conductor Location',
        snippet: 'Last updated: ${DateTime.now().toString().substring(11, 19)}',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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

// Additional Data Models
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

// Route Info Model
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