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

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'routeKey': routeKey,
      'routeName': routeName,
      'description': description,
      'conductorName': conductorName,
      'conductorId': conductorId,
      'departureDate': departureDate,
      'departureTime': departureTime,
      'stations': stations.map((station) => station.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'currentStationId': currentStationId,
      'lastUpdate': lastUpdate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // Create from Map (Firestore)
  factory RouteData.fromMap(Map<String, dynamic> map) {
    return RouteData(
      code: map['code'] ?? '',
      routeKey: map['routeKey'] ?? '',
      routeName: map['routeName'] ?? '',
      description: map['description'] ?? '',
      conductorName: map['conductorName'] ?? '',
      conductorId: map['conductorId'] ?? '',
      departureDate: map['departureDate'] ?? '',
      departureTime: map['departureTime'] ?? '',
      stations: (map['stations'] as List<dynamic>?)
          ?.map((station) => StationData.fromMap(station as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      status: RouteStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => RouteStatus.pending,
      ),
      currentStationId: map['currentStationId'],
      lastUpdate: map['lastUpdate'] != null ? DateTime.parse(map['lastUpdate']) : null,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    );
  }
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

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sequenceOrder': sequenceOrder,
      'estimatedArrivalTime': estimatedArrivalTime,
      'estimatedDepartureTime': estimatedDepartureTime,
      'latitude': latitude,
      'longitude': longitude,
      'isPassed': isPassed,
      'actualArrivalTime': actualArrivalTime?.toIso8601String(),
      'actualDepartureTime': actualDepartureTime?.toIso8601String(),
    };
  }

  // Create from Map (Firestore)
  factory StationData.fromMap(Map<String, dynamic> map) {
    return StationData(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      sequenceOrder: map['sequenceOrder'] ?? 0,
      estimatedArrivalTime: map['estimatedArrivalTime'],
      estimatedDepartureTime: map['estimatedDepartureTime'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      isPassed: map['isPassed'] ?? false,
      actualArrivalTime: map['actualArrivalTime'] != null 
          ? DateTime.parse(map['actualArrivalTime']) 
          : null,
      actualDepartureTime: map['actualDepartureTime'] != null 
          ? DateTime.parse(map['actualDepartureTime']) 
          : null,
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

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'totalStations': totalStations,
      'passedStations': passedStations,
      'currentStation': currentStation?.toMap(),
      'nextStation': nextStation?.toMap(),
      'isCompleted': isCompleted,
      'progressPercentage': progressPercentage,
    };
  }

  // Create from Map
  factory RouteProgress.fromMap(Map<String, dynamic> map) {
    return RouteProgress(
      totalStations: map['totalStations'] ?? 0,
      passedStations: map['passedStations'] ?? 0,
      currentStation: map['currentStation'] != null 
          ? StationData.fromMap(map['currentStation']) 
          : null,
      nextStation: map['nextStation'] != null 
          ? StationData.fromMap(map['nextStation']) 
          : null,
      isCompleted: map['isCompleted'] ?? false,
    );
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

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'displayName': displayName,
      'stationCount': stationCount,
    };
  }

  // Create from Map
  factory RouteOption.fromMap(Map<String, dynamic> map) {
    return RouteOption(
      key: map['key'] ?? '',
      displayName: map['displayName'] ?? '',
      stationCount: map['stationCount'] ?? 0,
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'code': code,
      'message': message,
    };
  }
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

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'routeData': routeData?.toMap(),
      'message': message,
    };
  }
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

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'stationData': stationData?.toMap(),
    };
  }
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

  Map<String, dynamic> toMap() {
    return {
      'stationId': stationId,
      'stationName': stationName,
      'distance': distance,
      'eventType': eventType.toString().split('.').last,
    };
  }

  factory StationDetectionEvent.fromMap(Map<String, dynamic> map) {
    return StationDetectionEvent(
      stationId: map['stationId'] ?? '',
      stationName: map['stationName'] ?? '',
      distance: map['distance']?.toDouble(),
      eventType: StationEventType.values.firstWhere(
        (e) => e.toString().split('.').last == map['eventType'],
        orElse: () => StationEventType.approaching,
      ),
    );
  }
}
