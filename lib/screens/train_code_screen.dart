import 'package:flutter/material.dart';
import '../../widgets/warning_box.dart';
import '../../widgets/title_section.dart';
import '../../widgets/train_code_input_form.dart';
import '../../services/train_service.dart';
import '../../utils/route_helper.dart';

class TrainCodeScreen extends StatefulWidget {
  const TrainCodeScreen({super.key});

  @override
  _TrainCodeScreenState createState() => _TrainCodeScreenState();
}

class _TrainCodeScreenState extends State<TrainCodeScreen> {
  final _codeController = TextEditingController();
  final TrainService _trainService = TrainService();
  bool _isLoading = false;
  List<String> _availableCodes = [];
  String _debugMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAvailableCodes();
    _debugFirebaseData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _debugFirebaseData() async {
    try {
      await _trainService.debugPrintAllTrains();
    } catch (e) {
      print('Debug error: $e');
    }
  }

  Future<void> _loadAvailableCodes() async {
    setState(() {
      _isLoading = true;
      _debugMessage = 'Loading available train codes...';
    });

    try {
      final codes = await _trainService.getAvailableTrainCodes();
      setState(() {
        _availableCodes = codes;
        _debugMessage = 'Found ${codes.length} available train codes: $codes';
      });
    } catch (e) {
      setState(() {
        _debugMessage = 'Error loading codes: $e';
      });
      print('Error loading available codes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    String code = _codeController.text.trim();
    
    if (code.isEmpty) {
      _showErrorDialog('Kode kereta tidak boleh kosong');
      return;
    }

    setState(() {
      _isLoading = true;
      _debugMessage = 'Searching for train with code: $code';
    });

    try {
      // Cari kereta berdasarkan kode
      final kereta = await _trainService.getTrainByCode(code);
      
      if (kereta != null) {
        setState(() {
          _debugMessage = 'Train found: ${kereta.nama}';
        });
        // Navigate ke detail kereta dengan data dari Firebase
        RouteHelper.navigateToDetail(context, arguments: kereta);
      } else {
        setState(() {
          _debugMessage = 'Train not found with code: $code';
        });
        // Jika tidak ditemukan, tampilkan kode yang tersedia
        _showTrainNotFoundDialog();
      }
    } catch (e) {
      setState(() {
        _debugMessage = 'Error searching train: $e';
      });
      _showErrorDialog('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  void _showTrainNotFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kereta Tidak Ditemukan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kode kereta "${_codeController.text}" tidak ditemukan.'),
            const SizedBox(height: 16),
            if (_availableCodes.isNotEmpty) ...[
              const Text(
                'Kode kereta yang tersedia:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _availableCodes.map((code) => 
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: GestureDetector(
                          onTap: () {
                            _codeController.text = code;
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              code,
                              style: const TextStyle(
                                color: Color(0xFFE91E63),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ),
            ] else ...[
              const Text('Tidak ada data kereta yang tersedia.'),
              const SizedBox(height: 8),
              const Text(
                'Pastikan data kereta sudah disetup di database.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
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
                      isLoading: _isLoading,
                      availableCodes: _availableCodes,
                    ),
                  ],
                ),
              ),
            ),
            
            // Debug message
            if (_debugMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Debug Info:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _debugMessage,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Available codes section
            if (_availableCodes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kode Kereta Tersedia:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableCodes.map((code) => 
                          GestureDetector(
                            onTap: () {
                              _codeController.text = code;
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE91E63).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFE91E63).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                code,
                                style: const TextStyle(
                                  color: Color(0xFFE91E63),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ).toList(),
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
