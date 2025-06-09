import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../services/enhanced_route_service.dart';
import '../models/route_models.dart';

class GPSTrackingScreen extends StatefulWidget {
  final String routeCode;

  const GPSTrackingScreen({
    Key? key,
    required this.routeCode,
  }) : super(key: key);

  @override
  State<GPSTrackingScreen> createState() => _GPSTrackingScreenState();
}

class _GPSTrackingScreenState extends State<GPSTrackingScreen> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<StationDetectionEvent>? _stationDetectionSubscription;
  
  RouteData? _routeData;
  RouteProgress? _routeProgress;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isTracking = false;
  String _trackingStatus = 'Initializing...';
  
  // Camera position for PENS area
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-7.280, 112.800), // Center of the route area
    zoom: 15.0,
  );

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    setState(() {
      _trackingStatus = 'Loading route data...';
    });

    // Get route details
    final routeDetailsResult = EnhancedRouteService.getRouteDetails(widget.routeCode);
    if (routeDetailsResult.success) {
      setState(() {
        _routeData = routeDetailsResult.routeData;
        _trackingStatus = 'Starting GPS tracking...';
      });

      // Start GPS tracking
      final trackingResult = await EnhancedRouteService.startConductorTracking(widget.routeCode);
      
      if (trackingResult.success) {
        setState(() {
          _isTracking = true;
          _trackingStatus = 'GPS tracking active';
        });

        // Listen to position updates
        _positionSubscription = EnhancedRouteService.positionStream.listen((position) {
          setState(() {
            _currentPosition = position;
            _updateMapMarkers();
            _updateRouteProgress();
          });
          
          // Move camera to current position
          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(position.latitude, position.longitude),
              ),
            );
          }
        });

        // Listen to station detection events
        _stationDetectionSubscription = EnhancedRouteService.stationDetectionStream.listen((event) {
          _handleStationDetectionEvent(event);
        });

        _updateMapMarkers();
        _updateRouteProgress();
      } else {
        setState(() {
          _trackingStatus = 'Failed to start GPS: ${trackingResult.message}';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(trackingResult.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      setState(() {
        _trackingStatus = 'Route not found';
      });
    }
  }

  void _updateMapMarkers() {
    setState(() {
      _markers.clear();
      
      // Add route station markers
      _markers.addAll(EnhancedRouteService.getRouteMarkers(widget.routeCode));
      
      // Add conductor marker
      final conductorMarker = EnhancedRouteService.getConductorMarker();
      if (conductorMarker != null) {
        _markers.add(conductorMarker);
      }
      
      // Add route polyline
      _polylines.clear();
      final routePolyline = EnhancedRouteService.getRoutePolyline(widget.routeCode);
      if (routePolyline != null) {
        _polylines.add(routePolyline);
      }
    });
  }

  void _updateRouteProgress() {
    setState(() {
      _routeProgress = EnhancedRouteService.getRouteProgress(widget.routeCode);
    });
  }

  void _handleStationDetectionEvent(StationDetectionEvent event) {
    String message = '';
    Color backgroundColor = Colors.blue;
    
    switch (event.eventType) {
      case StationEventType.approaching:
        message = 'Approaching ${event.stationName}';
        backgroundColor = Colors.orange;
        break;
      case StationEventType.arrived:
        message = '✅ Arrived at ${event.stationName}';
        backgroundColor = Colors.green;
        break;
      case StationEventType.departed:
        message = 'Departed from ${event.stationName}';
        backgroundColor = Colors.blue;
        break;
      case StationEventType.routeCompleted:
        message = '🎉 Route completed at ${event.stationName}!';
        backgroundColor = Colors.purple;
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
      ),
    );
    
    _updateRouteProgress();
  }

  void _stopTracking() {
    EnhancedRouteService.stopTracking();
    setState(() {
      _isTracking = false;
      _trackingStatus = 'Tracking stopped';
    });
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _stationDetectionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF5EE),
      appBar: AppBar(
        backgroundColor: Color(0xFFD75A9E),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'GPS Tracking - ${widget.routeCode}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isTracking)
            IconButton(
              icon: Icon(Icons.stop, color: Colors.white),
              onPressed: _stopTracking,
              tooltip: 'Stop Tracking',
            ),
        ],
      ),
      body: Column(
        children: [
          // Status Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFD75A9E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Route Info
                if (_routeData != null) ...[
                  Text(
                    _routeData!.routeName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _routeData!.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 12),
                ],
                
                // Status Row
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isTracking ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isTracking ? Icons.gps_fixed : Icons.gps_off,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            _trackingStatus,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    if (_currentPosition != null)
                      Text(
                        'GPS: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Progress Bar
          if (_routeProgress != null) ...[
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Route Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${_routeProgress!.passedStations}/${_routeProgress!.totalStations} stations',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _routeProgress!.progressPercentage,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD75A9E)),
                    minHeight: 6,
                  ),
                  SizedBox(height: 12),
                  
                  // Current and Next Station Info
                  Row(
                    children: [
                      // Current Station
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _routeProgress!.currentStation?.name ?? 'Not started',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      
                      // Next Station
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _routeProgress!.nextStation?.name ?? 'Route completed',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          
          // Google Map
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GoogleMap(
                  initialCameraPosition: _initialCameraPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                  compassEnabled: true,
                  trafficEnabled: false,
                  buildingsEnabled: true,
                  mapType: MapType.normal,
                ),
              ),
            ),
          ),
          
          // Bottom Info Panel
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Automatic Detection Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Detection Radius',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        Text(
                          '50m',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Dwell Time',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        Text(
                          '3 seconds',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'GPS Accuracy',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        Text(
                          'High',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}