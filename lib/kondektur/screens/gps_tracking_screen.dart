import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../services/enhanced_route_service.dart';
import '../models/route_models.dart';

class GPSTrackingScreen extends StatefulWidget {
  final String routeCode;
  final String conductorName;
  final String conductorId;

  const GPSTrackingScreen({
    Key? key,
    required this.routeCode,
    required this.conductorName,
    required this.conductorId,
  }) : super(key: key);

  @override
  State<GPSTrackingScreen> createState() => _GPSTrackingScreenState();
}

class _GPSTrackingScreenState extends State<GPSTrackingScreen> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<StationDetectionEvent>? _stationSubscription;
  
  RouteData? _routeData;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isTracking = false;
  String _trackingStatus = 'Initializing...';
  int _passedStations = 0;
  int _totalStations = 0;
  String _currentStationName = '';
  String _nextStationName = '';
  
  // For UI updates
  Timer? _uiUpdateTimer;
  
  @override
  void initState() {
    super.initState();
    print('🎯 GPSTrackingScreen initialized');
    print('🚂 Route: ${widget.routeCode}');
    print('👤 Conductor: ${widget.conductorName} (${widget.conductorId})');
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    print('🚀 Initializing GPS tracking...');
    
    setState(() {
      _trackingStatus = 'Loading route data...';
    });

    try {
      // Get route details
      final routeDetailsResult = EnhancedRouteService.getRouteDetails(widget.routeCode);
      print('📋 Route details result: ${routeDetailsResult.success}');
      
      if (routeDetailsResult.success) {
        setState(() {
          _routeData = routeDetailsResult.routeData;
          _totalStations = _routeData!.stations.length;
          _trackingStatus = 'Starting GPS tracking...';
        });

        print('📍 Route has ${_totalStations} stations');

        // Start tracking
        final trackingResult = await EnhancedRouteService.startConductorTracking(widget.routeCode);
        print('🎯 Tracking start result: ${trackingResult.success} - ${trackingResult.message}');
        
        if (trackingResult.success) {
          setState(() {
            _isTracking = true;
            _trackingStatus = 'GPS tracking active';
          });

          // Listen to position updates with more robust handling
          _positionSubscription = EnhancedRouteService.positionStream.listen(
            (position) {
              print('📱 UI received position update: ${position.latitude}, ${position.longitude}');
              if (mounted) {
                setState(() {
                  _currentPosition = position;
                  _updateMapMarkers();
                  _updateRouteProgress(); // Update progress on each position change
                });
                
                // Force camera update on significant position changes
                if (_mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(position.latitude, position.longitude),
                      16.0,
                    ),
                  );
                }
              }
            },
            onError: (error) {
              print('❌ Position stream error: $error');
              // Try to recover from errors
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('GPS error: $error'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
          );

          // Listen to station detection events
          _stationSubscription = EnhancedRouteService.stationDetectionStream.listen((event) {
            print('📱 UI received station event: ${event.eventType} - ${event.stationName}');
            if (mounted) {
              _handleStationEvent(event);
            }
          });

          // Start UI update timer
          _uiUpdateTimer = Timer.periodic(Duration(seconds: 2), (timer) {
            if (mounted) {
              _updateRouteProgress();
            }
          });

          _updateMapMarkers();
          _updateRouteProgress();

          // Start periodic position refresh
          _startPeriodicPositionRefresh();
          
        } else {
          setState(() {
            _trackingStatus = 'Failed to start GPS tracking: ${trackingResult.message}';
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to start tracking: ${trackingResult.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        setState(() {
          _trackingStatus = 'Route not found';
        });
        print('❌ Route not found: ${widget.routeCode}');
      }
    } catch (e) {
      print('❌ Error initializing tracking: $e');
      setState(() {
        _trackingStatus = 'Error: $e';
      });
    }
  }

  // Force position refresh periodically
void _startPeriodicPositionRefresh() {
  Timer.periodic(Duration(seconds: 10), (timer) {
    if (!mounted || !_isTracking) {
      timer.cancel();
      return;
    }
    
    print('🔄 Forcing position refresh');
    // Use getCurrentPosition instead of requestPositionUpdate
    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      forceAndroidLocationManager: true,
    ).then((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _updateMapMarkers();
          _updateRouteProgress();
        });
      }
    }).catchError((error) {
      print('⚠️ Forced position refresh error: $error');
    });
  });
}

  void _updateMapMarkers() {
    if (!mounted) return;
  
    print('🗺️ Updating map markers');
  
    try {
      setState(() {
        _markers.clear();
        
        // Add route station markers
        if (_routeData != null) {
          int validStations = 0;
          for (final station in _routeData!.stations) {
            if (station.latitude != null && station.longitude != null) {
              validStations++;
              _markers.add(
                Marker(
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
                ),
              );
            }
          }
          print('🗺️ Added $validStations station markers');
        }
        
        // Add conductor marker
        if (_currentPosition != null) {
          _markers.add(
            Marker(
              markerId: MarkerId('conductor'),
              position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              infoWindow: InfoWindow(
                title: '🚂 ${widget.conductorName}',
                snippet: 'Last updated: ${DateTime.now().toString().substring(11, 19)}',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              zIndex: 2,
            ),
          );
          print('🗺️ Added conductor marker at ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
          
          // Move camera to current position if available
          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                16.0,
              ),
            );
          }
        } else {
          print('⚠️ No current position available for conductor marker');
        }
        
        // Add route polyline
        if (_routeData != null) {
          final polyline = EnhancedRouteService.getRoutePolyline(widget.routeCode);
          if (polyline != null) {
            _polylines.clear();
            _polylines.add(polyline);
            print('🗺️ Added route polyline');
          } else {
            print('⚠️ No polyline available for route ${widget.routeCode}');
          }
        }
      });
    } catch (e) {
      print('❌ Error updating map markers: $e');
    }
  }

  void _updateRouteProgress() {
    if (!mounted || _routeData == null) return;
    
    final progress = EnhancedRouteService.getRouteProgress(widget.routeCode);
    
    setState(() {
      _passedStations = progress.passedStations;
      _currentStationName = progress.currentStation?.name ?? 'Starting Point';
      _nextStationName = progress.nextStation?.name ?? 'Route Completed';
    });
  }

  void _handleStationEvent(StationDetectionEvent event) {
    if (!mounted) return;
    
    String message = '';
    Color backgroundColor = Colors.blue;
    
    switch (event.eventType) {
      case StationEventType.approaching:
        message = 'Approaching ${event.stationName}';
        backgroundColor = Colors.blue;
        break;
      case StationEventType.arrived:
        message = 'Arrived at ${event.stationName}';
        backgroundColor = Colors.green;
        setState(() {
          _passedStations++;
        });
        break;
      case StationEventType.departed:
        message = 'Departed from ${event.stationName}';
        backgroundColor = Colors.orange;
        break;
      case StationEventType.routeCompleted:
        message = 'Route completed!';
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
    
    _updateMapMarkers();
    _updateRouteProgress();
  }

  void _stopTracking() async {
    print('🛑 Stopping GPS tracking...');
    
    try {
      await EnhancedRouteService.stopTracking();
      setState(() {
        _isTracking = false;
        _trackingStatus = 'GPS tracking stopped';
      });
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('❌ Error stopping tracking: $e');
    }
  }

  @override
  void dispose() {
    print('🗑️ Disposing GPSTrackingScreen');
    _positionSubscription?.cancel();
    _stationSubscription?.cancel();
    _uiUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPS Tracking - ${widget.routeCode}'),
        backgroundColor: const Color(0xFFD75A9E),
        foregroundColor: Colors.white,
        actions: [
          // GPS Debug button
          IconButton(
            icon: Icon(Icons.gps_fixed),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => GPSDebugDialog(),
              );
            },
            tooltip: 'GPS Debug',
          ),
          if (_isTracking)
            IconButton(
              icon: Icon(Icons.stop),
              onPressed: _stopTracking,
              tooltip: 'Stop Tracking',
            ),
        ],
      ),
      body: Column(
        children: [
          // Status Panel
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: _isTracking ? Colors.green.shade50 : Colors.red.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isTracking ? Icons.gps_fixed : Icons.gps_off,
                      color: _isTracking ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _trackingStatus,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_isTracking)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wifi, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                
                SizedBox(height: 8),
                
                // Conductor info
                Text(
                  'Kondektur: ${widget.conductorName} (${widget.conductorId})',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                
                if (_currentPosition != null) ...[
                  SizedBox(height: 4),
                  Text(
                    'GPS: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)}m • Updated: ${DateTime.fromMillisecondsSinceEpoch(_currentPosition!.timestamp.millisecondsSinceEpoch).toString().substring(11, 19)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                
                SizedBox(height: 8),
                
                // Progress bar
                LinearProgressIndicator(
                  value: _totalStations > 0 ? _passedStations / _totalStations : 0,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isTracking ? Colors.green : Colors.red,
                  ),
                ),
                
                SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress: $_passedStations/$_totalStations stations',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Next: $_nextStationName',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Google Map
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(-7.280, 112.800), // Default position (Surabaya)
                zoom: 14.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                print('🗺️ Google Map created');
                _mapController = controller;
                
                // If we already have a position, move camera there
                if (_currentPosition != null) {
                  controller.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      16.0,
                    ),
                  );
                }
              },
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              compassEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}

class GPSDebugDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('GPS Debug Information'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This dialog is a placeholder for GPS debug information.'),
          Text('You can add more detailed information here, such as:'),
          SizedBox(height: 8),
          Text('- GPS status (enabled/disabled)'),
          Text('- Last known location'),
          Text('- Accuracy of the location'),
          Text('- Time since last update'),
          Text('- Permissions status'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}
