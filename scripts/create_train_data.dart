import 'package:cloud_firestore/cloud_firestore.dart';

// Script untuk membuat data kereta di Firestore
Future<void> createTrainData() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  try {
    // Data kereta Surabaya - Jakarta
    final trainData = {
      'kode': 'SBY-JKT-001',
      'nama': 'Argo Bromo Anggrek',
      'fromStasiun': 'Surabaya Gubeng',
      'toStasiun': 'Jakarta Gambir',
      'jadwal': '08:00',
      'status': 'onRoute',
      'arrivalCountdown': '2 jam 30 menit',
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

    // Simpan ke collection 'trains'
    await firestore.collection('trains').doc('SBY-JKT-001').set(trainData);
    
    print('✅ Data kereta berhasil dibuat!');
    print('Kode kereta: SBY-JKT-001');
    print('Rute: Surabaya Gubeng → Jakarta Gambir');
    
    // Buat beberapa data kereta lainnya
    await _createAdditionalTrains(firestore);
    
  } catch (e) {
    print('❌ Error membuat data kereta: $e');
  }
}

Future<void> _createAdditionalTrains(FirebaseFirestore firestore) async {
  // Kereta Jakarta - Surabaya (arah sebaliknya)
  final trainData2 = {
    'kode': 'JKT-SBY-001',
    'nama': 'Argo Bromo Anggrek',
    'fromStasiun': 'Jakarta Gambir',
    'toStasiun': 'Surabaya Gubeng',
    'jadwal': '20:00',
    'status': 'willArrive',
    'arrivalCountdown': '30 menit',
    'route': [
      {
        'nama': 'Jakarta Gambir',
        'waktu': '20:00',
        'isPassed': false,
        'isActive': true,
      },
      {
        'nama': 'Cirebon',
        'waktu': '23:30',
        'isPassed': false,
        'isActive': false,
      },
      {
        'nama': 'Purwokerto',
        'waktu': '02:00',
        'isPassed': false,
        'isActive': false,
      },
      {
        'nama': 'Yogyakarta',
        'waktu': '04:15',
        'isPassed': false,
        'isActive': false,
      },
      {
        'nama': 'Solo Balapan',
        'waktu': '05:00',
        'isPassed': false,
        'isActive': false,
      },
      {
        'nama': 'Madiun',
        'waktu': '06:15',
        'isPassed': false,
        'isActive': false,
      },
      {
        'nama': 'Kertosono',
        'waktu': '07:00',
        'isPassed': false,
        'isActive': false,
      },
      {
        'nama': 'Mojokerto',
        'waktu': '07:45',
        'isPassed': false,
        'isActive': false,
      },
      {
        'nama': 'Surabaya Gubeng',
        'waktu': '08:30',
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
        'kode': 'EKS-2',
        'tipe': 'Eksekutif',
        'kapasitas': 50,
        'terisi': 33,
      },
      {
        'kode': 'BIS-1',
        'tipe': 'Bisnis',
        'kapasitas': 64,
        'terisi': 45,
      },
      {
        'kode': 'BIS-2',
        'tipe': 'Bisnis',
        'kapasitas': 64,
        'terisi': 52,
      },
    ],
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  await firestore.collection('trains').doc('JKT-SBY-001').set(trainData2);
  print('✅ Data kereta JKT-SBY-001 berhasil dibuat!');
}

// Fungsi untuk membuat akun staff default
Future<void> createDefaultStaffAccounts() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  try {
    // Staff 1
    await firestore.collection('users').doc('staff001').set({
      'staffId': 'STAFF001',
      'name': 'Admin Stasiun',
      'email': 'staff001@staff.tutgo.com',
      'userType': 'staff',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    print('✅ Akun staff default berhasil dibuat!');
    print('Staff ID: STAFF001');
    print('Email: staff001@staff.tutgo.com');
    print('Password: (harus dibuat manual di Firebase Auth)');
    
  } catch (e) {
    print('❌ Error membuat akun staff: $e');
  }
}

// Main function untuk menjalankan setup
void main() async {
  print('🚀 Memulai setup data kereta...');
  
  await createTrainData();
  await createDefaultStaffAccounts();
  
  print('✅ Setup selesai!');
  print('');
  print('📋 Yang perlu dilakukan selanjutnya:');
  print('1. Buat akun staff di Firebase Auth Console');
  print('2. Email: staff001@staff.tutgo.com');
  print('3. Password: (sesuai keinginan, minimal 6 karakter)');
  print('4. Test login dengan kode kereta: SBY-JKT-001');
}
