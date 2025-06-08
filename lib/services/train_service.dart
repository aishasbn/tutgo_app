import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/kereta_model.dart';

class TrainService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get train data by code
  Future<Kereta?> getTrainByCode(String code) async {
    try {
      print('Searching for train with code: $code');
      
      // Search in trains collection
      final querySnapshot = await _firestore
          .collection('trains')
          .where('kode', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('Train not found with code: $code');
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      
      print('Train found: ${data['nama']}');
      return _mapFirestoreToKereta(data);
    } catch (e) {
      print('Error getting train by code: $e');
      return null;
    }
  }

  // Get all trains
  Future<List<Kereta>> getAllTrains() async {
    try {
      final querySnapshot = await _firestore.collection('trains').get();
      
      return querySnapshot.docs
          .map((doc) => _mapFirestoreToKereta(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting all trains: $e');
      return [];
    }
  }

  // Update train status
  Future<void> updateTrainStatus(String trainCode, KeretaStatus status) async {
    try {
      final querySnapshot = await _firestore
          .collection('trains')
          .where('kode', isEqualTo: trainCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await _firestore.collection('trains').doc(docId).update({
          'status': _statusToString(status),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating train status: $e');
    }
  }

  // Update train route progress
  Future<void> updateTrainProgress(String trainCode, int currentStationIndex) async {
    try {
      final querySnapshot = await _firestore
          .collection('trains')
          .where('kode', isEqualTo: trainCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        List<dynamic> route = List.from(data['route'] ?? []);

        // Update route progress
        for (int i = 0; i < route.length; i++) {
          route[i]['isPassed'] = i < currentStationIndex;
          route[i]['isActive'] = i == currentStationIndex;
        }

        await _firestore.collection('trains').doc(doc.id).update({
          'route': route,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating train progress: $e');
    }
  }

  // Map Firestore data to Kereta model
  Kereta _mapFirestoreToKereta(Map<String, dynamic> data) {
    return Kereta(
      kode: data['kode'] ?? '',
      nama: data['nama'] ?? '',
      fromStasiun: data['fromStasiun'] ?? '',
      toStasiun: data['toStasiun'] ?? '',
      jadwal: data['jadwal'] ?? '',
      status: _stringToStatus(data['status'] ?? 'willArrive'),
      arrivalCountdown: data['arrivalCountdown'],
      route: (data['route'] as List<dynamic>?)
          ?.map((item) => StasiunRoute(
                nama: item['nama'] ?? '',
                waktu: item['waktu'] ?? '',
                isPassed: item['isPassed'] ?? false,
                isActive: item['isActive'] ?? false,
              ))
          .toList() ?? [],
      gerbongs: (data['gerbongs'] as List<dynamic>?)
          ?.map((item) => Gerbong(
                kode: item['kode'] ?? '',
                tipe: item['tipe'] ?? '',
                kapasitas: item['kapasitas'] ?? 0,
                terisi: item['terisi'] ?? 0,
              ))
          .toList() ?? [],
    );
  }

  // Convert status string to enum
  KeretaStatus _stringToStatus(String status) {
    switch (status.toLowerCase()) {
      case 'willarrive':
        return KeretaStatus.willArrive;
      case 'onroute':
        return KeretaStatus.onRoute;
      case 'finished':
        return KeretaStatus.finished;
      default:
        return KeretaStatus.willArrive;
    }
  }

  // Convert status enum to string
  String _statusToString(KeretaStatus status) {
    switch (status) {
      case KeretaStatus.willArrive:
        return 'willArrive';
      case KeretaStatus.onRoute:
        return 'onRoute';
      case KeretaStatus.finished:
        return 'finished';
    }
  }

  // Get available train codes (untuk suggestion)
  Future<List<String>> getAvailableTrainCodes() async {
    try {
      final querySnapshot = await _firestore.collection('trains').get();
      
      return querySnapshot.docs
          .map((doc) => doc.data()['kode'] as String)
          .toList();
    } catch (e) {
      print('Error getting train codes: $e');
      return [];
    }
  }
}

