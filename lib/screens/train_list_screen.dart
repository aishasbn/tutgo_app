import 'package:flutter/material.dart';
import '../models/kereta_model.dart';

class TrainListScreen extends StatelessWidget {
  final List<Kereta> daftarKereta = const [
    Kereta(
      kode: 'KA001',
      nama: 'Argo Wilis',
      fromStasiun: 'Stasiun Mulyosari',
      toStasiun: 'Stasiun Keputih',
      jadwal: '06:30-07:00',
      status: KeretaStatus.onRoute,
      arrivalCountdown: '00:05:00',
      route: [
        StasiunRoute(nama: 'Jombang', waktu: '06:35', isPassed: true),
        StasiunRoute(nama: 'Madiun', waktu: '07:30', isActive: true),
        StasiunRoute(nama: 'Malang', waktu: '8:45'),
        StasiunRoute(nama: 'Jogja Tugu', waktu: '10:35'),
      ],
      gerbongs: [],
    ),
    Kereta(
      kode: 'KA002',
      nama: 'KA Bima',
      fromStasiun: 'Stasiun Gubeng',
      toStasiun: 'Stasiun Pasar Senen',
      jadwal: '08:00-09:00',
      status: KeretaStatus.onRoute,
      route: [
        StasiunRoute(nama: 'Surabaya', waktu: '08:00', isPassed: true),
        StasiunRoute(nama: 'Mojokerto', waktu: '08:30', isPassed: true),
        StasiunRoute(nama: 'Kertosono', waktu: '09:15', isActive: true),
        StasiunRoute(nama: 'Jakarta', waktu: '15:00'),
      ],
      gerbongs: [],
    ),
    Kereta(
      kode: 'KA003',
      nama: 'KA Gajayana',
      fromStasiun: 'Stasiun Malang',
      toStasiun: 'Stasiun Gambir',
      jadwal: '19:00-20:00',
      status: KeretaStatus.finished,
      route: [
        StasiunRoute(nama: 'Malang', waktu: '19:00', isPassed: true),
        StasiunRoute(nama: 'Blitar', waktu: '20:30', isPassed: true),
        StasiunRoute(nama: 'Kediri', waktu: '21:45', isPassed: true),
        StasiunRoute(nama: 'Jakarta', waktu: '06:00', isPassed: true),
      ],
      gerbongs: [],
    ),
  ];

  const TrainListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F4F4),
      appBar: AppBar(
        title: Text('Daftar Kereta'),
        backgroundColor: Color(0xFFE91E63),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daftar Kereta Hari Ini',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE91E63),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: daftarKereta.length,
                itemBuilder: (context, index) {
                  final kereta = daftarKereta[index];
                  return _buildKeretaCard(context, kereta);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeretaCard(BuildContext context, Kereta kereta) {
    Color statusColor;
    String statusText;
    Color statusBgColor;
    
    switch (kereta.status) {
      case KeretaStatus.willArrive:
        statusColor = Color(0xFFFF8F00);
        statusBgColor = Color(0xFFFFF3E0);
        statusText = kereta.arrivalCountdown != null 
            ? 'Will Arrive in ${kereta.arrivalCountdown}' 
            : 'Will Arrive';
        break;
      case KeretaStatus.onRoute:
        statusColor = Color(0xFFE91E63);
        statusBgColor = Color(0xFFFCE4EC);
        statusText = 'On Route';
        break;
      case KeretaStatus.finished:
        statusColor = Color(0xFF4CAF50);
        statusBgColor = Color(0xFFE8F5E8);
        statusText = 'Finished';
        break;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(0xFFE91E63), width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detail',
            arguments: kereta,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      kereta.nama,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF8F00),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    kereta.fromStasiun,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF8F00),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(left: 4, top: 4, bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 1,
                      height: 16,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(0xFFE91E63),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    kereta.toStasiun,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFE91E63),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        kereta.jadwal,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFFE91E63),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}