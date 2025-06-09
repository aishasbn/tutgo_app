import 'package:flutter/material.dart';
import '../widgets/code_input_widget.dart';
import '../widgets/action_button_widget.dart';
import '../services/enhanced_route_service.dart';
import 'package:tutgo/kondektur/models/route_models.dart';
import 'gps_tracking_screen.dart';

class EnhancedEnterCodeScreen extends StatefulWidget {
  const EnhancedEnterCodeScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedEnterCodeScreen> createState() => _EnhancedEnterCodeScreenState();
}

class _EnhancedEnterCodeScreenState extends State<EnhancedEnterCodeScreen> {
  String _currentCode = '';
  bool _isCodeComplete = false;
  bool _isLoading = false;
  RouteInfo? _selectedRouteInfo;
  List<String> _availableRouteCodes = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableRoutes();
  }

  void _loadAvailableRoutes() {
    setState(() {
      _availableRouteCodes = EnhancedRouteService.getAvailableRouteCodes();
    });
  }

  void _onCodeCompleted(String code) {
    setState(() {
      _currentCode = code;
      _isCodeComplete = code.length == 6;
      
      // Check if entered code matches any available route
      if (_isCodeComplete) {
        _selectedRouteInfo = EnhancedRouteService.getRouteInfo(code);
      } else {
        _selectedRouteInfo = null;
      }
    });
  }

  void _onEnterPressed() async {
    if (_isCodeComplete && !_isLoading) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(Duration(seconds: 1));

      // Activate route with conductor info
      final result = EnhancedRouteService.activateRoute(
        routeCode: _currentCode,
        conductorName: 'Aisha Sabina',
        conductorId: '250510',
        departureDate: DateTime.now().toString().split(' ')[0],
      );

      if (result.success) {
        // Navigate to GPS tracking screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GPSTrackingScreen(routeCode: _currentCode),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectPredefinedRoute(String routeCode) {
    setState(() {
      _currentCode = routeCode;
      _isCodeComplete = true;
      _selectedRouteInfo = EnhancedRouteService.getRouteInfo(routeCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        title: Text(
          'GPS Conductor Mode',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Route Code',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your route code to start GPS tracking for your train route.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              
              CodeInputWidget(
                onCompleted: _onCodeCompleted,
                onCodeChanged: (code) {
                  setState(() {
                    _currentCode = code;
                    _isCodeComplete = code.length == 6;
                    if (_isCodeComplete) {
                      _selectedRouteInfo = EnhancedRouteService.getRouteInfo(code);
                    } else {
                      _selectedRouteInfo = null;
                    }
                  });
                },
                initialValue: _currentCode,
              ),
              const SizedBox(height: 16),
              
              // Route Info Display
              if (_selectedRouteInfo != null) ...[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
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
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        _selectedRouteInfo!.routeName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _selectedRouteInfo!.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.train, size: 16, color: Colors.grey.shade600),
                          SizedBox(width: 4),
                          Text(
                            '${_selectedRouteInfo!.stationCount} stations',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                          SizedBox(width: 4),
                          Text(
                            'Departure: ${_selectedRouteInfo!.departureTime}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else if (_isCodeComplete) ...[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Route code not found',
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              _isLoading
                  ? Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xFFD75A9E).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : ActionButtonWidget(
                      text: 'START GPS TRACKING',
                      onPressed: (_isCodeComplete && _selectedRouteInfo != null) ? _onEnterPressed : null,
                      backgroundColor: (_isCodeComplete && _selectedRouteInfo != null)
                          ? Color(0xFFD75A9E) 
                          : Colors.grey.shade400,
                      icon: Icons.gps_fixed,
                    ),
              
              const SizedBox(height: 40),
              
              // GPS Info Card
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GPS Tracking Features',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '• Real-time location tracking\n• Automatic station detection\n• Live passenger updates',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Available Routes section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFBB54).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.list_alt,
                            color: Color(0xFFFFBB54),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Available Routes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFBB54),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Select from predefined route codes',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Route Code List
                    ...(_availableRouteCodes.map((routeCode) {
                      final routeInfo = EnhancedRouteService.getRouteInfo(routeCode);
                      if (routeInfo == null) return SizedBox.shrink();
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => _selectPredefinedRoute(routeCode),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _currentCode == routeCode 
                                  ? Color(0xFFFFBB54).withOpacity(0.1)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _currentCode == routeCode 
                                    ? Color(0xFFFFBB54)
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFD75A9E),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    routeCode,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        routeInfo.routeName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${routeInfo.stationCount} stations • ${routeInfo.departureTime}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_currentCode == routeCode)
                                  Icon(
                                    Icons.check_circle,
                                    color: Color(0xFFFFBB54),
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}