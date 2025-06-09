import 'package:google_maps_flutter/google_maps_flutter.dart';

// Route Data Model
class RouteData {
  final String code;
  final String routeKey;
  final String routeName;
  final String description;
  final String conductorName;
  final String conductorId;
  final String departureDate;
  final String departureTime;
  final List<StationData> stations;
  final DateTime createdAt;
  
  RouteStatus status;
  String? currentStationId;
  DateTime? lastUpdate;
  DateTime? completedAt;
  
  RouteData({
    required this.code,
    required this.routeKey,
    required this.routeName,
    required this.description,
    required this.conductorName,
    required this.conductorId,
    required this.departureDate,
    required this.departureTime,
    required this.stations,
    required this.createdAt,
    this.status = RouteStatus.pending,
    this.currentStationId,
    this.lastUpdate,
    this.completedAt,
  });
}

// Station Data Model
class StationData {
  final String id;
  final String name;
  final int sequenceOrder;
  final String? estimatedArrivalTime;
  final String? estimatedDepartureTime;
  final double? latitude;
  final double? longitude;
  
  bool isPassed;
  DateTime? actualArrivalTime;
  DateTime? actualDepartureTime;
  
  StationData({
    required this.id,
    required this.name,
    required this.sequenceOrder,
    this.estimatedArrivalTime,
    this.estimatedDepartureTime,
    this.latitude,
    this.longitude,
    this.isPassed = false,
    this.actualArrivalTime,
    this.actualDepartureTime,
  });
  
  factory StationData.copy(StationData original) {
    return StationData(
      id: original.id,
      name: original.name,
      sequenceOrder: original.sequenceOrder,
      estimatedArrivalTime: original.estimatedArrivalTime,
      estimatedDepartureTime: original.estimatedDepartureTime,
      latitude: original.latitude,
      longitude: original.longitude,
      isPassed: false,
      actualArrivalTime: null,
      actualDepartureTime: null,
    );
  }
  
  factory StationData.empty() {
    return StationData(
      id: '',
      name: '',
      sequenceOrder: 0,
    );
  }
  
  // bool get isCurrent {
  //   return isPassed;
  // }
}

// Route Status Enum
enum RouteStatus { pending, active, completed, cancelled }

// Route Progress Model
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
  
  double get progressPercentage {
    if (totalStations == 0) return 0.0;
    return passedStations / totalStations;
  }
}

// Route Option Model
class RouteOption {
  final String key;
  final String displayName;
  final int stationCount;
  
  RouteOption({
    required this.key,
    required this.displayName,
    required this.stationCount,
  });
}

// Result Classes
class RouteCodeResult {
  final bool success;
  final String? code;
  final String message;
  
  RouteCodeResult({
    required this.success,
    this.code,
    required this.message,
  });
}

class RouteDetailsResult {
  final bool success;
  final RouteData? routeData;
  final String? message;
  
  RouteDetailsResult({
    required this.success,
    this.routeData,
    this.message,
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

// Station Detection Event Types
enum StationEventType {
  approaching,
  arrived,
  departed,
  routeCompleted
}

// Station Detection Event
class StationDetectionEvent {
  final String stationId;
  final String stationName;
  final double? distance;
  final StationEventType eventType;

  StationDetectionEvent({
    required this.stationId,
    required this.stationName,
    this.distance,
    required this.eventType,
  });
}