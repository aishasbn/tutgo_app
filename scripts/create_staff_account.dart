import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Script untuk membuat akun staff secara manual
Future<void> createStaffAccounts() async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  // Data staff yang akan dibuat
  final List<Map<String, String>> staffData = [
    {
      'staffId': 'STAFF001',
      'name': 'Admin Stasiun Jakarta',
      'password': 'staff123',
    },
    {
      'staffId': 'STAFF002', 
      'name': 'Admin Stasiun Surabaya',
      'password': 'staff123',
    },
    {
      'staffId': 'ADMIN001',
      'name': 'Super Admin',
      'password': 'admin123',
    },
  ];

  print('🚀 Memulai pembuatan akun staff...');
  
  for (final staff in staffData) {
    try {
      final staffId = staff['staffId']!;
      final name = staff['name']!;
      final password = staff['password']!;
      final email = '${staffId.toLowerCase()}@staff.tutgo.com';
      
      print('🔄 Membuat akun untuk: $staffId');
      
      // Buat akun di Firebase Auth
      final UserCredential result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(name);
        await result.user!.reload();
        
        // Simpan data ke Firestore
        await firestore.collection('users').doc(result.user!.uid).set({
          'uid': result.user!.uid,
          'staffId': staffId,
          'name': name,
          'email': email,
          'userType': 'staff',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        print('✅ Akun staff berhasil dibuat:');
        print('   Staff ID: $staffId');
        print('   Email: $email');
        print('   Password: $password');
        print('   Name: $name');
        print('');
      }
    } catch (e) {
      print('❌ Error membuat akun ${staff['staffId']}: $e');
      
      // Jika email sudah ada, coba update data saja
      if (e.toString().contains('email-already-in-use')) {
        print('⚠️ Email sudah ada, mencoba update data...');
        try {
          // Sign in dengan akun yang sudah ada
          final email = '${staff['staffId']!.toLowerCase()}@staff.tutgo.com';
          final result = await auth.signInWithEmailAndPassword(
            email: email,
            password: staff['password']!,
          );
          
          if (result.user != null) {
            // Update data di Firestore
            await firestore.collection('users').doc(result.user!.uid).set({
              'uid': result.user!.uid,
              'staffId': staff['staffId']!,
              'name': staff['name']!,
              'email': email,
              'userType': 'staff',
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            
            print('✅ Data staff berhasil diupdate: ${staff['staffId']}');
          }
        } catch (e2) {
          print('❌ Gagal update data ${staff['staffId']}: $e2');
        }
      }
    }
  }
  
  // Sign out setelah selesai
  try {
    await auth.signOut();
    print('🔄 Signed out from admin account');
  } catch (e) {
    print('⚠️ Warning: Failed to sign out: $e');
  }
  
  print('');
  print('✅ Pembuatan akun staff selesai!');
  print('');
  print('📋 Akun staff yang tersedia:');
  for (final staff in staffData) {
    print('- Staff ID: ${staff['staffId']}');
    print('  Email: ${staff['staffId']!.toLowerCase()}@staff.tutgo.com');
    print('  Password: ${staff['password']}');
    print('');
  }
  
  print('💡 Cara login staff:');
  print('1. Pilih "Staff" di halaman account type');
  print('2. Masukkan Staff ID (contoh: STAFF001)');
  print('3. Masukkan password (contoh: staff123)');
}

// Main function
void main() async {
  print('🔧 Setup akun staff untuk TutGo...');
  await createStaffAccounts();
}
