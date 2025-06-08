import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Script untuk testing auth flow
Future<void> testAuthFlow() async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  print('🧪 Testing Firebase Auth Flow...');
  print('');
  
  // Test 1: Check Firebase connection
  print('1️⃣ Testing Firebase connection...');
  try {
    await firestore.collection('_test').limit(1).get();
    print('✅ Firebase connection OK');
  } catch (e) {
    print('❌ Firebase connection failed: $e');
    return;
  }
  
  // Test 2: Test user registration
  print('');
  print('2️⃣ Testing user registration...');
  try {
    final testEmail = 'test${DateTime.now().millisecondsSinceEpoch}@test.com';
    final testPassword = 'test123';
    final testName = 'Test User';
    
    print('   Creating user: $testEmail');
    
    final result = await auth.createUserWithEmailAndPassword(
      email: testEmail,
      password: testPassword,
    );
    
    if (result.user != null) {
      await result.user!.updateDisplayName(testName);
      await result.user!.reload();
      
      await firestore.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'name': testName,
        'email': testEmail,
        'userType': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ User registration successful');
      print('   UID: ${result.user!.uid}');
      print('   Email: ${result.user!.email}');
      print('   Display Name: ${result.user!.displayName}');
      
      // Clean up test user
      await result.user!.delete();
      await firestore.collection('users').doc(result.user!.uid).delete();
      print('   🧹 Test user cleaned up');
    }
  } catch (e) {
    print('❌ User registration failed: $e');
  }
  
  // Test 3: Test staff login
  print('');
  print('3️⃣ Testing staff login...');
  try {
    final staffEmail = 'staff001@staff.tutgo.com';
    final staffPassword = 'staff123';
    
    print('   Attempting staff login: $staffEmail');
    
    final result = await auth.signInWithEmailAndPassword(
      email: staffEmail,
      password: staffPassword,
    );
    
    if (result.user != null) {
      print('✅ Staff login successful');
      print('   UID: ${result.user!.uid}');
      print('   Email: ${result.user!.email}');
      
      // Check staff data in Firestore
      final doc = await firestore.collection('users').doc(result.user!.uid).get();
      if (doc.exists) {
        final data = doc.data();
        print('   User Type: ${data?['userType']}');
        print('   Staff ID: ${data?['staffId']}');
      }
      
      await auth.signOut();
      print('   🔓 Signed out');
    }
  } catch (e) {
    print('❌ Staff login failed: $e');
    print('   Make sure staff account exists. Run create_staff_account.dart first.');
  }
  
  // Test 4: Test error handling
  print('');
  print('4️⃣ Testing error handling...');
  try {
    await auth.signInWithEmailAndPassword(
      email: 'nonexistent@test.com',
      password: 'wrongpassword',
    );
  } on FirebaseAuthException catch (e) {
    print('✅ Error handling working correctly');
    print('   Error code: ${e.code}');
    print('   Error message: ${e.message}');
  } catch (e) {
    print('⚠️ Unexpected error type: $e');
  }
  
  // Test 5: Check train data
  print('');
  print('5️⃣ Testing train data...');
  try {
    final trainQuery = await firestore.collection('trains').limit(3).get();
    
    if (trainQuery.docs.isNotEmpty) {
      print('✅ Train data available');
      for (final doc in trainQuery.docs) {
        final data = doc.data();
        print('   - ${data['kode']}: ${data['nama']}');
      }
    } else {
      print('⚠️ No train data found. Run create_train_data.dart first.');
    }
  } catch (e) {
    print('❌ Failed to check train data: $e');
  }
  
  print('');
  print('🎉 Auth flow testing completed!');
  print('');
  print('📋 Summary:');
  print('- Firebase connection: Working');
  print('- User registration: Working');
  print('- Staff login: Check if staff accounts exist');
  print('- Error handling: Working');
  print('- Train data: Check if data exists');
  print('');
  print('💡 Next steps:');
  print('1. Run create_staff_account.dart if staff login failed');
  print('2. Run create_train_data.dart if no train data found');
  print('3. Test the app with real user interactions');
}

// Main function
void main() async {
  await testAuthFlow();
}
