import 'package:flutter/material.dart';
import '../widgets/warning_box.dart';
import '../widgets/title_section.dart';
import '../widgets/train_code_input_form.dart';
import '../models/kereta_model.dart';
import '../utils/route_helper.dart';

class TrainCodeScreen extends StatefulWidget {
  const TrainCodeScreen({super.key});

  @override
  _TrainCodeScreenState createState() => _TrainCodeScreenState();
}

class _TrainCodeScreenState extends State<TrainCodeScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    String code = _codeController.text.trim();
    
    if (code.isEmpty) {
      _showErrorDialog('Kode kereta tidak boleh kosong');
      return;
    }

    // Simulasi validasi kode
    if (code.toLowerCase() == 'ka001' || code.toLowerCase() == 'test') {
      // Buat dummy data kereta
      Kereta dummyKereta = Kereta(
        kode: code.toUpperCase(),
        nama: 'KA Argo Wilis',
        fromStasiun: 'Stasiun Mulyosari',
        toStasiun: 'Stasiun Keputih',
        jadwal: '06:30-07:00',
        status: KeretaStatus.onRoute,
        arrivalCountdown: '00:05:00',
        route: [
          const StasiunRoute(nama: 'Jombang', waktu: '06:35', isPassed: true),
          const StasiunRoute(nama: 'Madiun', waktu: '', isActive: true),
          const StasiunRoute(nama: 'Malang', waktu: '30 second'),
          const StasiunRoute(nama: 'Jogja Tugu', waktu: '10:30'),
        ],
        gerbongs: const [],
      );

      // Navigate ke detail kereta dengan arguments
      RouteHelper.navigateToDetail(context, arguments: dummyKereta);
    } else {
      _showErrorDialog('Kode kereta tidak valid. Coba gunakan "KA001" atau "test"');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFFE91E63)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEFEF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: () => RouteHelper.goBack(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
            
            const TitleSection(),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.pink[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const WarningBox(),
                    TrainCodeInputForm(
                      controller: _codeController,
                      onSubmit: _handleSubmit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
