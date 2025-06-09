import 'package:flutter/material.dart';
import '../../models/kereta_model.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/custom_popup.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/route_card.dart';
import '../../widgets/schedule_card.dart';
import '../../widgets/route_timeline.dart';
import '../../widgets/carriage_information.dart';
import '../../widgets/finish_button.dart';

class DetailKeretaScreen extends StatefulWidget {
  const DetailKeretaScreen({super.key});

  @override
  _DetailKeretaScreenState createState() => _DetailKeretaScreenState();
}

class _DetailKeretaScreenState extends State<DetailKeretaScreen> {
  late Kereta kereta;
  
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

  @override
  void initState() {
    super.initState();
    _assignUserSeat();
  }

  void _assignUserSeat() {
    userCarriage = 'CA';
    userSeatNumber = 8;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Kereta?;
    kereta = args ?? _getDummyData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F4F4),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  Text(
                    '12:00',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.signal_cellular_4_bar, size: 16, color: Colors.black),
                      SizedBox(width: 4),
                      Icon(Icons.wifi, size: 16, color: Colors.black),
                      SizedBox(width: 4),
                      Icon(Icons.battery_full, size: 16, color: Colors.black),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusBadge(status: kereta.status),
                    SizedBox(height: 16),
                    RouteCard(kereta: kereta),
                    SizedBox(height: 16),
                    ScheduleCard(kereta: kereta),
                    SizedBox(height: 16),
                    RouteTimeline(route: kereta.route),
                    SizedBox(height: 16),
                    CarriageInformation(
                      carriageOccupancy: carriageOccupancy,
                      userCarriage: userCarriage,
                      userSeatNumber: userSeatNumber,
                      hasConfirmedSeat: hasConfirmedSeat,
                      onConfirmSeat: _confirmSeat,
                      onOccupancyChanged: _updateOccupancy,
                    ),
                    SizedBox(height: 20),
                    if (kereta.status == KeretaStatus.onRoute)
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
      bottomNavigationBar: CustomNavBar(
        onItemSelected: (index) {
          // Handle navigation if needed
        },
        selectedIndex: 1,
      ),
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
        Navigator.of(context).pop();
      },
    );
  }

  void _updateOccupancy(String carriage, int change) {
    setState(() {
      carriageOccupancy[carriage] = carriageOccupancy[carriage]! + change;
    });
  }

  void _handleFinish() {
    setState(() {
      kereta = kereta.copyWith(status: KeretaStatus.finished);
    });
    _showFinishPopup();
  }

  void _showFinishPopup() {
    PopupHelper.showFinishPopup(
      context: context,
      onBackToHome: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
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
      status: KeretaStatus.onRoute,
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
}
