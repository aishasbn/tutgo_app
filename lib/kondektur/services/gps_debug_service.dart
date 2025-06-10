import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GPSDebugService {
  static final StreamController<String> _logController = 
      StreamController<String>.broadcast();
  
  static Stream<String> get logStream => _logController.stream;
  
  static void log(String message) {
    print('🔍 GPS Debug: $message');
    _logController.add(message);
  }
  
  static Future<void> checkGPSStatus() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      log('Location services enabled: $serviceEnabled');
      
      if (!serviceEnabled) {
        log('⚠️ Location services are disabled');
        return;
      }
      
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      log('Current permission: $permission');
      
      await checkMockLocationStatus();

      // Get current position with multiple attempts
      try {
        log('Attempting to get current position (high accuracy)...');
        Position? position;
        
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          );
        } catch (e) {
          log('⚠️ High accuracy position failed: $e');
          log('Trying with best accuracy...');
          
          try {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best,
              timeLimit: Duration(seconds: 5),
            );
          } catch (e2) {
            log('⚠️ Best accuracy position failed: $e2');
            log('Trying with low accuracy...');
            
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 10),
            );
          }
        }
        
        log('✅ Current position: ${position.latitude}, ${position.longitude}');
        log('Accuracy: ${position.accuracy} meters');
        log('Altitude: ${position.altitude} meters');
        log('Speed: ${position.speed} m/s');
        log('Heading: ${position.heading}°');
        log('Timestamp: ${position.timestamp}');
        log('Time since epoch: ${position.timestamp.millisecondsSinceEpoch}');
        
        // Check if position is recent
        final now = DateTime.now().millisecondsSinceEpoch;
        final positionTime = position.timestamp.millisecondsSinceEpoch;
        final ageInSeconds = (now - positionTime) / 1000;
        
        log('Position age: ${ageInSeconds.toStringAsFixed(1)} seconds');
        
        if (ageInSeconds > 60) {
          log('⚠️ Warning: Position data is over 1 minute old');
        }
            } catch (e) {
        log('❌ Error getting position: $e');
      }
      
      // Test position stream
      log('Testing position stream...');
      StreamSubscription<Position>? subscription;
      subscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 1,
        ),
      ).listen(
        (Position position) {
          log('📍 Stream position: ${position.latitude}, ${position.longitude}');
          subscription?.cancel();
        },
        onError: (error) {
          log('❌ Stream error: $error');
          subscription?.cancel();
        },
        onDone: () {
          log('Stream completed');
        },
      );
      
      // Cancel after 10 seconds
      Timer(Duration(seconds: 10), () {
        subscription?.cancel();
        log('Stream test completed');
      });
      
    } catch (e) {
      log('❌ Error checking GPS status: $e');
    }
  }

  // Check if mock location is enabled
  static Future<void> checkMockLocationStatus() async {
    try {
      bool isMock = false;
      
      try {
        Position position = await Geolocator.getCurrentPosition();
        isMock = position.isMocked;
        log('Mock location check: ${isMock ? "ENABLED ⚠️" : "DISABLED ✅"}');
      } catch (e) {
        log('❌ Could not check mock location status: $e');
      }
      
      if (isMock) {
        log('⚠️ WARNING: Mock location is enabled. This may affect tracking accuracy.');
        log('⚠️ Please disable mock locations in developer settings for accurate tracking.');
      }
    } catch (e) {
      log('❌ Error checking mock location: $e');
    }
  }
  
  static void dispose() {
    _logController.close();
  }
}

class GPSDebugDialog extends StatefulWidget {
  const GPSDebugDialog({super.key});

  @override
  State<GPSDebugDialog> createState() => _GPSDebugDialogState();
}

class _GPSDebugDialogState extends State<GPSDebugDialog> {
  final List<String> _logs = [];
  
  @override
  void initState() {
    super.initState();
    GPSDebugService.logStream.listen((log) {
      setState(() {
        _logs.add(log);
      });
    });
    
    // Run GPS check
    GPSDebugService.checkGPSStatus();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.maxFinite,
        height: 400,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.gps_fixed, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'GPS Debug',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {
                      _logs.clear();
                    });
                    GPSDebugService.checkGPSStatus();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      log,
                      style: TextStyle(
                        fontSize: 12,
                        color: log.contains('❌') 
                            ? Colors.red 
                            : log.contains('✅') 
                                ? Colors.green 
                                : log.contains('⚠️') 
                                    ? Colors.orange 
                                    : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _logs.clear();
                    });
                    GPSDebugService.checkGPSStatus();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Test GPS'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    await Geolocator.openLocationSettings();
                  },
                  child: Text('Open Settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
