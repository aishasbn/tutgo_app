import 'package:flutter/material.dart';
import '../services/train_service.dart';
import '../models/kereta_model.dart';
import '../widgets/route_card.dart';
import '../utils/route_helper.dart';

class TrainListScreen extends StatefulWidget {
  const TrainListScreen({super.key});

  @override
  State<TrainListScreen> createState() => _TrainListScreenState();
}

class _TrainListScreenState extends State<TrainListScreen> {
  final TrainService _trainService = TrainService();
  List<Kereta> _activeTrains = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveTrains();
    _listenToTrainUpdates();
  }

  void _listenToTrainUpdates() {
    // Listen to real-time updates from conductor
    _trainService.activeTrainsStream.listen((trains) {
      if (mounted) {
        setState(() {
          _activeTrains = trains;
        });
      }
    });

    _trainService.trainUpdateStream.listen((update) {
      if (mounted) {
        print('📡 Received train update: ${update['type']}');
        // Refresh the list when there's an update
        _loadActiveTrains();
      }
    });
  }

  Future<void> _loadActiveTrains() async {
    try {
      final trains = await _trainService.getActiveTrains();
      if (mounted) {
        setState(() {
          _activeTrains = trains;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading active trains: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshTrains() async {
    setState(() {
      _isLoading = true;
    });
    await _loadActiveTrains();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F4),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Trains',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Active train journeys',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFFE91E63),
            ),
            SizedBox(height: 16),
            Text(
              'Loading trains...',
              style: TextStyle(
                color: Color(0xFFE91E63),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_activeTrains.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.train,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'NO DATA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'NO DATA',
              style: TextStyle(
                color: Color(0xFFE91E63),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You haven\'t input any train code',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                RouteHelper.navigateToTrainCode(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
              ),
              child: const Text(
                'Input Train Code',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshTrains,
      color: const Color(0xFFE91E63),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _activeTrains.length,
        itemBuilder: (context, index) {
          final train = _activeTrains[index];
          return GestureDetector(
            onTap: () {
              RouteHelper.navigateToDetail(context, arguments: train);
            },
            child: RouteCard(kereta: train),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _trainService.dispose();
    super.dispose();
  }
}
