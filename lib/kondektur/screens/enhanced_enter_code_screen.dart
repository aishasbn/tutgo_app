import 'package:flutter/material.dart';
import '../services/enhanced_route_service.dart';
import '../services/gps_debug_service.dart' as debug_service;
import '../widgets/code_input_widget.dart';
import 'gps_tracking_screen.dart';

class EnhancedEnterCodeScreen extends StatefulWidget {
  final String conductorName;
  final String conductorId;

  const EnhancedEnterCodeScreen({
    super.key,
    required this.conductorName,
    required this.conductorId,
  });

  @override
  State<EnhancedEnterCodeScreen> createState() => _EnhancedEnterCodeScreenState();
}

class _EnhancedEnterCodeScreenState extends State<EnhancedEnterCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  RouteInfo? _routeInfo;

  @override
  void initState() {
    super.initState();
    print('🎯 EnhancedEnterCodeScreen initialized');
    print('👤 Conductor: ${widget.conductorName} (${widget.conductorId})');
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _checkRouteCode(String code) {
    print('🔍 Checking route code: $code');
    
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a route code';
        _routeInfo = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Get route info
    final routeInfo = EnhancedRouteService.getRouteInfo(code);
    print('📋 Route info result: $routeInfo');

    setState(() {
      _isLoading = false;
      _routeInfo = routeInfo;
      if (routeInfo == null) {
        _errorMessage = 'Invalid route code';
      }
    });
  }

  void _activateRoute() async {
    print('🚀 Activating route: ${_codeController.text}');
    
    if (_routeInfo == null || _codeController.text.isEmpty) {
      print('❌ Cannot activate route - missing info');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Activate route
      final result = EnhancedRouteService.activateRoute(
        routeCode: _codeController.text,
        conductorName: widget.conductorName,
        conductorId: widget.conductorId,
        departureDate: DateTime.now().toString().substring(0, 10),
      );

      print('✅ Route activation result: ${result.success} - ${result.message}');

      setState(() {
        _isLoading = false;
      });

      if (result.success) {
        print('🎯 Navigating to GPS tracking screen');
        
        // Navigate to GPS tracking screen using direct navigation
        final route = MaterialPageRoute(
          builder: (context) => GPSTrackingScreen(
            routeCode: _codeController.text,
            conductorName: widget.conductorName,
            conductorId: widget.conductorId,
          ),
        );
        
        Navigator.push(context, route).then((value) {
          print('🔙 Returned from GPS tracking screen');
        });
        
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      print('❌ Error activating route: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  void _showDebugDialog() {
    showDialog(
      context: context,
      builder: (context) => debug_service.GPSDebugDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Route Code'),
        backgroundColor: const Color(0xFFD75A9E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: _showDebugDialog,
            tooltip: 'GPS Debug',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.blue.shade700),
                      SizedBox(width: 8),
                      Text(
                        'Kondektur: ${widget.conductorName}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'ID: ${widget.conductorId}',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            Text(
              'Enter Route Code',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please enter the route code to start tracking',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 24),
            
            // Code Input
            CodeInputWidget(
              onCompleted: (code) {
                print('📝 Code completed: $code');
                _codeController.text = code;
                _checkRouteCode(code);
              },
              onCodeChanged: (code) {
                print('📝 Code changed: $code');
                _codeController.text = code;
                if (code.length == 6) {
                  _checkRouteCode(code);
                } else {
                  setState(() {
                    _errorMessage = null;
                    _routeInfo = null;
                  });
                }
              },
              initialValue: _codeController.text,
            ),
            
            SizedBox(height: 16),
            
            // Error Message
            if (_errorMessage != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            
            SizedBox(height: 16),
            
            // Route Info
            if (_routeInfo != null)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Route Found!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      _routeInfo!.routeName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(_routeInfo!.description),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Stations: ${_routeInfo!.stationCount}'),
                        Text('Departure: ${_routeInfo!.departureTime}'),
                      ],
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _activateRoute,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD75A9E),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Starting...'),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.gps_fixed),
                                  SizedBox(width: 8),
                                  Text('Start GPS Tracking'),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            
            Spacer(),
            
            // Available route codes for testing
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Route Codes for Testing:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: EnhancedRouteService.getAvailableRouteCodes()
                        .map((code) => ActionChip(
                              label: Text(code),
                              onPressed: () {
                                print('🎯 Selected route code: $code');
                                _codeController.text = code;
                                _checkRouteCode(code);
                              },
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
