import 'package:cloud_firestore/cloud_firestore.dart';

// Script untuk update data kereta yang sudah ada
Future<void> updateExistingTrainData() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  try {
    print('🔄 Memperbarui data kereta yang sudah ada...');
    
    // Update kereta SBY-JKT-001 jika sudah ada
    final existingTrain = await firestore
        .collection('trains')
        .doc('SBY-JKT-001')
        .get();
    
    if (existingTrain.exists) {
      await firestore.collection('trains').doc('SBY-JKT-001').update({
        'status': 'onRoute',
        'arrivalCountdown': '2 jam 15 menit',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Data kereta SBY-JKT-001 berhasil diperbarui');
    } else {
      print('⚠️ Kereta SBY-JKT-001 tidak ditemukan, membuat data baru...');
      await createNewTrainData();
    }
    
    // Tambah kereta baru untuk testing
    await createAdditionalTestTrains(firestore);
    
  } catch (e) {
    print('❌ Error memperbarui data kereta: $e');
  }
}

Future<void> createNewTrainData() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  final trainData = {
    'kode': 'SBY-JKT-001',
    'nama': 'Argo Bromo Anggrek',
    'fromStasiun': 'Surabaya Gubeng',
    'toStasiun': 'Jakarta Gambir',
    'jadwal': '08:00',
    'status': 'onRoute',
    'arrivalCountdown': '2 jam 15 menit',
    'route': [
      {
        'nama': 'Surabaya Gubeng',
        'waktu': '08:00',
        'isPassed': true,
        'isActive': false,
      },
      {
        'nama': 'Mojokerto',
        'waktu': '08:45',
        'isPassed': true,
        'isActive': false,
      },
      {
        'nama': 'Kertosono',
        'waktu': '09:30',
        'isPassed': true,
        'isActive': false,
      },
      {
        'nama': 'Madiun',
        'waktu': '10:15',
        'isPassed': false,
        'isActive': true,
      },
      {
        'nama': 'Solo Balapan',
        'waktu': '11:30',
        'isPassed': false,
        'isActive': false,
      },
      {
        'nama': 'Yogyakarta',
        'waktu': '12:15',
        'isPassed': false,
        'isActive': false,
      },
      {
        'nama': 'Purwokerto',
        'waktu': '14:00',
        'isPassed': false,
        'isActive': false,
      },
      {
        'nama': 'Cirebon',
        'waktu': '16:30',
        'isPassed': false,
        'isActive': false,
      },
      {
        'nama': 'Jakarta Gambir',
        'waktu': '19:00',
        'isPassed': false,
        'isActive': false,
      },
    ],
    'gerbongs': [
      {
        'kode': 'EKS-1',
        'tipe': 'Eksekutif',
        'kapasitas': 50,
        'terisi': 35,
      },
      {
        'kode': 'EKS-2',
        'tipe': 'Eksekutif',
        'kapasitas': 50,
        'terisi': 42,
      },
      {
        'kode': 'BIS-1',
        'tipe': 'Bisnis',
        'kapasitas': 64,
        'terisi': 58,
      },
      {
        'kode': 'BIS-2',
        'tipe': 'Bisnis',
        'kapasitas': 64,
        'terisi': 61,
      },
    ],
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  await firestore.collection('trains').doc('SBY-JKT-001').set(trainData);
  print('✅ Data kereta SBY-JKT-001 berhasil dibuat');
}

Future<void> createAdditionalTestTrains(FirebaseFirestore firestore) async {
  // Kereta untuk testing lainnya
  final additionalTrains = [
    {
      'kode': 'JKT-SBY-002',
      'nama': 'Argo Lawu',
      'fromStasiun': 'Jakarta Gambir',
      'toStasiun': 'Surabaya Gubeng',
      'jadwal': '20:30',
      'status': 'willArrive',
      'arrivalCountdown': '45 menit',
      'route': [
        {
          'nama': 'Jakarta Gambir',
          'waktu': '20:30',
          'isPassed': false,
          'isActive': true,
        },
        {
          'nama': 'Cirebon',
          'waktu': '00:15',
          'isPassed': false,
          'isActive': false,
        },
        {
          'nama': 'Purwokerto',
          'waktu': '02:45',
          'isPassed': false,
          'isActive': false,
        },
        {
          'nama': 'Yogyakarta',
          'waktu': '04:30',
          'isPassed': false,
          'isActive': false,
        },
        {
          'nama': 'Solo Balapan',
          'waktu': '05:15',
          'isPassed': false,
          'isActive': false,
        },
        {
          'nama': 'Madiun',
          'waktu': '06:30',
          'isPassed': false,
          'isActive': false,
        },
        {
          'nama': 'Kertosono',
          'waktu': '07:15',
          'isPassed': false,
          'isActive': false,
        },
        {
          'nama': 'Mojokerto',
          'waktu': '08:00',
          'isPassed': false,
          'isActive': false,
        },
        {
          'nama': 'Surabaya Gubeng',
          'waktu': '08:45',
          'isPassed': false,
          'isActive': false,
        },
      ],
      'gerbongs': [
        {
          'kode': 'EKS-1',
          'tipe': 'Eksekutif',
          'kapasitas': 50,
          'terisi': 28,
        },
        {
          'kode': 'BIS-1',
          'tipe': 'Bisnis',
          'kapasitas': 64,
          'terisi': 45,
        },
      ],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'kode': 'MLG-JKT-001',
      'nama': 'Gajayana',
      'fromStasiun': 'Malang',
      'toStasiun': 'Jakarta Gambir',
      'jadwal': '15:30',
      'status': 'finished',
      'arrivalCountdown': null,
      'route': [
        {
          'nama': 'Malang',
          'waktu': '15:30',
          'isPassed': true,
          'isActive': false,
        },
        {
          'nama': 'Blitar',
          'waktu': '16:15',
          'isPassed': true,
          'isActive': false,
        },
        {
          'nama': 'Kediri',
          'waktu': '17:00',
          'isPassed': true,
          'isActive': false,
        },
        {
          'nama': 'Kertosono',
          'waktu': '17:30',
          'isPassed': true,
          'isActive': false,
        },
        {
          'nama': 'Madiun',
          'waktu': '18:15',
          'isPassed': true,
          'isActive': false,
        },
        {
          'nama': 'Solo Balapan',
          'waktu': '19:30',
          'isPassed': true,
          'isActive': false,
        },
        {
          'nama': 'Yogyakarta',
          'waktu': '20:15',
          'isPassed': true,
          'isActive': false,
        },
        {
          'nama': 'Jakarta Gambir',
          'waktu': '05:30',
          'isPassed': true,
          'isActive': false,
        },
      ],
      'gerbongs': [
        {
          'kode': 'EKS-1',
          'tipe': 'Eksekutif',
          'kapasitas': 50,
          'terisi': 50,
        },
        {
          'kode': 'EKS-2',
          'tipe': 'Eksekutif',
          'kapasitas': 50,
          'terisi': 48,
        },
      ],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
  ];

  for (final trainData in additionalTrains) {
    await firestore.collection('trains').doc(trainData['kode'] as String).set(trainData);
    print('✅ Data kereta ${trainData['kode']} berhasil dibuat');
  }
}

// Main function
void main() async {
  print('🚀 Memulai update data kereta...');
  
  await updateExistingTrainData();
  
  print('✅ Update selesai!');
  print('');
  print('📋 Kode kereta yang tersedia untuk testing:');
  print('1. SBY-JKT-001 (Surabaya → Jakarta) - Status: onRoute');
  print('2. JKT-SBY-002 (Jakarta → Surabaya) - Status: willArrive');
  print('3. MLG-JKT-001 (Malang → Jakarta) - Status: finished');
  print('');
  print('💡 Gunakan kode-kode di atas untuk testing aplikasi');
}





//enter_code_screen.dart
import 'package:flutter/material.dart';
import '../widgets/code_input_widget.dart';
import '../widgets/action_button_widget.dart';
import '../services/route_service.dart';

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({Key? key}) : super(key: key);

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  String _currentCode = '';
  bool _isCodeComplete = false;
  bool _isLoading = false;

  void _onCodeCompleted(String code) {
    setState(() {
      _currentCode = code;
      _isCodeComplete = code.length == 6;
    });
  }

  void _onEnterPressed() async {
    if (_isCodeComplete && !_isLoading) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));

      // Validate code using RouteService
      final result = RouteService.validateRouteCode(_currentCode);

      if (result.success) {
        // Code valid, navigate to tracking screen
        Navigator.pushNamed(
          context, 
          '/tracking', 
          arguments: _currentCode,
        );
      } else {
        // Code invalid, show error
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your unique code to manage your train route.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              CodeInputWidget(
                onCompleted: _onCodeCompleted,
                onCodeChanged: (code) {
                  setState(() {
                    _currentCode = code;
                    _isCodeComplete = code.length == 6;
                  });
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xFFD75A9E).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : ActionButtonWidget(
                      text: 'ENTER',
                      onPressed: _isCodeComplete ? _onEnterPressed : null,
                      backgroundColor: _isCodeComplete 
                          ? Color(0xFFD75A9E) 
                          : Colors.grey.shade400,
                    ),
              
              const SizedBox(height: 32),
              
              // Demo section untuk generate code
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo Mode',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD75A9E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Generate a demo route code for testing',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ActionButtonWidget(
                      text: 'Generate Demo Code',
                      onPressed: _generateDemoCode,
                      backgroundColor: Color(0xFFFFBB54),
                      height: 40,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _generateDemoCode() {
    final result = RouteService.generateRouteCode(
      conductorName: 'Aisha Sabina',
      conductorId: '250510',
      departureDate: DateTime.now().toString().split(' ')[0],
      departureTime: '06:30',
    );
    
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Demo code generated: ${result.code}'),
          backgroundColor: Color(0xFF4CAF50),
          action: SnackBarAction(
            label: 'USE',
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                _currentCode = result.code!;
                _isCodeComplete = true;
              });
            },
          ),
        ),
      );
    }
  }
}


//home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/welcome_header_widget.dart';
import '../widgets/action_button_widget.dart';
import '../widgets/bottom_navigation_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    if (index == 1) {
      // Navigate to Profile
      Navigator.pushNamed(context, '/profile');
    }
  }

  void _onEnterCodePressed() {
    // Navigate to Enter Code screen
    Navigator.pushNamed(context, '/enter-code');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF5EE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              WelcomeHeaderWidget(name: 'Aisha'),
              const SizedBox(height: 32),
              ActionButtonWidget(
                text: 'Enter Your Code',
                onPressed: _onEnterCodePressed,
                icon: Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}


//profile_screen.dart
import 'package:flutter/material.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_info_item_widget.dart';
import '../widgets/bottom_navigation_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 1; // Profile tab is selected

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    if (index == 0) {
      // Navigate back to Home
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/home', 
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                ProfileHeaderWidget(
                  name: 'Aisha Sabina',
                  role: 'Kondektur 1',
                ),
                const SizedBox(height: 16),
                ProfileInfoItemWidget(
                  label: 'Email Address',
                  value: 'aishasabina@gmail.com',
                ),
                ProfileInfoItemWidget(
                  label: 'Username',
                  value: 'Aisha Sabina',
                ),
                ProfileInfoItemWidget(
                  label: 'ID Kondektur',
                  value: '250510',
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}


//tracking_screen.dart
import 'package:flutter/material.dart';
import '../widgets/station_status_widget.dart';
import '../widgets/action_button_widget.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../services/route_service.dart';

class TrackingScreen extends StatefulWidget {
  final String routeCode;
  
  const TrackingScreen({
    Key? key,
    required this.routeCode,
  }) : super(key: key);

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  int _currentIndex = 0;
  RouteData? _routeData;
  RouteProgress? _routeProgress;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadRouteData();
  }
  
  void _loadRouteData() {
    final result = RouteService.getRouteDetails(widget.routeCode);
    if (result.success && result.routeData != null) {
      setState(() {
        _routeData = result.routeData;
        _routeProgress = RouteService.getRouteProgress(widget.routeCode);
      });
    }
  }
  
  void _markStationPassed() async {
    if (_routeProgress?.nextStation == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final result = RouteService.markStationPassed(
      widget.routeCode, 
      _routeProgress!.nextStation!.id
    );
    
    if (result.success) {
      // Refresh data
      _loadRouteData();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Passed ${result.stationData?.name}',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Check if route is completed
      if (_routeProgress?.isCompleted == true) {
        _showRouteCompletedDialog();
      }
    } else {
      // Show error message
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
  
  void _showRouteCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Text('Route Completed!'),
            ],
          ),
          content: Text(
            'Congratulations! You have successfully completed the ${_routeData?.routeName} route.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/home', 
                  (route) => false,
                ); // Go to home
              },
              child: Text('Back to Home'),
            ),
          ],
        );
      },
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/home', 
        (route) => false,
      );
    } else if (index == 1) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF5EE),
      appBar: AppBar(
        title: Text(
          'Route Tracking',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route Info Card
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Route Code: ${widget.routeCode}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_routeData != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _routeData!.routeName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  'Conductor: ${_routeData!.conductorName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    if (_routeProgress != null) ...[
                      const SizedBox(height: 16),
                      
                      // Progress Bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${_routeProgress!.passedStations}/${_routeProgress!.totalStations}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _routeProgress!.progressPercentage,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD75A9E)),
                            minHeight: 6,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(_routeProgress!.progressPercentage * 100).toInt()}% Complete',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    if (_routeData?.lastUpdate != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Last Update: ${_formatTime(_routeData!.lastUpdate!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Next Station Card (if not completed)
              if (_routeProgress?.nextStation != null && !_routeProgress!.isCompleted) ...[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8D7E6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFFD75A9E).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Color(0xFFD75A9E),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Next Station',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFD75A9E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _routeProgress!.nextStation!.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (_routeProgress!.nextStation!.estimatedArrivalTime != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'ETA: ${_routeProgress!.nextStation!.estimatedArrivalTime}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Station Status Header
              Text(
                'Station Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Stations List
              Expanded(
                child: _routeData != null 
                    ? ListView.builder(
                        itemCount: _routeData!.stations.length,
                        itemBuilder: (context, index) {
                          final station = _routeData!.stations[index];
                          final isNext = _routeProgress?.nextStation?.id == station.id;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: StationStatusWidget(
                              stationName: station.name,
                              isPassed: station.isPassed,
                              isCurrent: isNext,
                              arrivalTime: station.estimatedArrivalTime,
                              departureTime: station.estimatedDepartureTime,
                              actualArrivalTime: station.actualArrivalTime,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD75A9E)),
                        ),
                      ),
              ),
              
              // Action Button
              if (_routeProgress?.nextStation != null && !_routeProgress!.isCompleted)
                _isLoading
                    ? Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFFD75A9E).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : ActionButtonWidget(
                        text: 'Mark "${_routeProgress!.nextStation!.name}" as Passed',
                        onPressed: _markStationPassed,
                        backgroundColor: Color(0xFF4CAF50),
                        icon: Icons.check,
                      )
              else if (_routeProgress?.isCompleted == true)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Route Completed!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
  
  Color _getStatusColor() {
    if (_routeData == null) return Colors.grey;
    
    switch (_routeData!.status) {
      case RouteStatus.pending:
        return Colors.orange;
      case RouteStatus.active:
        return Color(0xFF4CAF50);
      case RouteStatus.completed:
        return Color(0xFF2196F3);
      case RouteStatus.cancelled:
        return Colors.red;
    }
  }
  
  String _getStatusText() {
    if (_routeData == null) return 'UNKNOWN';
    
    switch (_routeData!.status) {
      case RouteStatus.pending:
        return 'PENDING';
      case RouteStatus.active:
        return 'ACTIVE';
      case RouteStatus.completed:
        return 'COMPLETED';
      case RouteStatus.cancelled:
        return 'CANCELLED';
    }
  }
  
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

tapi ini tracking screen belum yang otomatis masih manual pencet mark as passed, jadi disesuaikan aja ya sehingga otomatis