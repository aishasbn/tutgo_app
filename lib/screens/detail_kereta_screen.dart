import 'package:flutter/material.dart';
import '../../models/kereta_model.dart';
import '../../widgets/custom_popup.dart';
import '../../widgets/route_card.dart';
import '../../widgets/schedule_card.dart';
import '../../widgets/route_timeline.dart';
import '../../widgets/carriage_information.dart';
import '../../widgets/finish_button.dart';
import '../services/train_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class DetailKeretaScreen extends StatefulWidget {
  final String? routeCode;
  
  const DetailKeretaScreen({super.key, this.routeCode});

  @override
  _DetailKeretaScreenState createState() => _DetailKeretaScreenState();
}

class _DetailKeretaScreenState extends State<DetailKeretaScreen> {
  late Kereta kereta;
  final TrainService _trainService = TrainService.instance;
  
  // State untuk carriage information
  Map<String, int> carriageOccupancy = {
    'CA': 15,
    'CB': 22,
    'M': 8,
    'AA': 28,
    'AB': 12,
    'AC': 25,
    'CB2': 18,
  };

  // User seat assignment
  String? userCarriage;
  int? userSeatNumber;
  bool hasConfirmedSeat = false;
  bool showFinishButton = false;

  StreamSubscription<DocumentSnapshot>? _realtimeSubscription;
  bool _isTrainLive = false;
  Map<String, dynamic> _realtimeData = {};

  @override
  void initState() {
    super.initState();
    _assignUserSeat();
    _loadSeatConfirmation();
    _startFinishTimer();
  }

  void _assignUserSeat() {
    userCarriage = 'CA';
    userSeatNumber = 8;
  }

  void _loadSeatConfirmation() {
    hasConfirmedSeat = _trainService.isSeatConfirmed;
  }

  void _startFinishTimer() {
    // Show finish button after 1 minute for testing
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        setState(() {
          showFinishButton = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Kereta?;
    kereta = args ?? _getDummyData();
    
    // Start real-time listening if we have a route code
    if (widget.routeCode != null || kereta.kode.isNotEmpty) {
      _startRealtimeListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F4),
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan back button - improved spacing
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Train Details',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          kereta.kode,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Will Arrive status badge at top
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 20,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Will Arrive',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    RouteCard(kereta: kereta),
                    const SizedBox(height: 24),
                    ScheduleCard(kereta: kereta),
                    const SizedBox(height: 24),
                    RouteTimeline(route: kereta.route),
                    const SizedBox(height: 24),
                    CarriageInformation(
                      carriageOccupancy: carriageOccupancy,
                      userCarriage: userCarriage,
                      userSeatNumber: userSeatNumber,
                      hasConfirmedSeat: hasConfirmedSeat,
                      onConfirmSeat: _confirmSeat,
                      onOccupancyChanged: _updateOccupancy,
                    ),
                    const SizedBox(height: 32),
                    if (showFinishButton)
                      FinishButton(
                        kereta: kereta,
                        onPressed: _handleFinish,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // No bottom navigation bar for detail screen
    );
  }

  void _confirmSeat() {
    PopupHelper.showSuccessPopup(
      context: context,
      title: 'Success',
      subtitle: 'Click next to view\nyour train tracking',
      onContinue: () {
        setState(() {
          hasConfirmedSeat = true;
          if (userCarriage != null) {
            carriageOccupancy[userCarriage!] = carriageOccupancy[userCarriage!]! + 1;
          }
        });
        
        // Save confirmation to service
        _trainService.confirmSeat();
        
        Navigator.of(context).pop();
      },
    );
  }

  void _updateOccupancy(String carriage, int change) {
    setState(() {
      carriageOccupancy[carriage] = carriageOccupancy[carriage]! + change;
    });
  }

  void _handleFinish() async {
    // Clear active trip dari service
    await _trainService.clearActiveTrip();
    
    _showFinishPopup();
  }

  void _showFinishPopup() {
    PopupHelper.showFinishPopup(
      context: context,
      onBackToHome: () {
        Navigator.of(context).pop();
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main',
          (route) => false,
        );
      },
    );
  }

  Kereta _getDummyData() {
    return Kereta(
      kode: 'KA001',
      nama: 'KA Argo Wilis',
      fromStasiun: 'Stasiun Mulyosari',
      toStasiun: 'Stasiun Keputih',
      jadwal: '06:30-07:00',
      status: KeretaStatus.willArrive,
      arrivalCountdown: '00:05:00',
      route: [
        StasiunRoute(nama: 'Jombang', waktu: '06:35', isPassed: true),
        StasiunRoute(nama: 'Madiun', waktu: '', isActive: true),
        StasiunRoute(nama: 'Malang', waktu: '30 second'),
        StasiunRoute(nama: 'Jogja Tugu', waktu: '10:30'),
      ],
      gerbongs: const [],
    );
  }

  void _startRealtimeListening() {
    final routeCode = widget.routeCode ?? kereta.kode;
    if (routeCode.isEmpty) return;
    
    print('🎧 Starting real-time listening for: $routeCode');
    
    _realtimeSubscription = FirebaseFirestore.instance
        .collection('active_routes')
        .doc(routeCode)
        .snapshots()
        .listen((snapshot) {
      
      if (snapshot.exists && mounted) {
        final data = snapshot.data() as Map<String, dynamic>;
        
        setState(() {
          _realtimeData = data;
          _isTrainLive = data['status'] == 'active';
        });
        
        print('📡 Real-time update received for $routeCode');
      }
    });
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}
