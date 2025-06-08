import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreRepair {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Repair missing user document for current user
  static Future<bool> repairCurrentUserDocument() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No current user to repair');
        return false;
      }

      print('🔧 Repairing user document for: ${user.uid}');

      // Check if document exists
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        print('✅ User document already exists');
        return true;
      }

      // Create missing document
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
        'email': user.email,
        'userType': user.email?.contains('@staff.tutgo.com') == true ? 'staff' : 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ User document repaired successfully');
      return true;
    } catch (e) {
      print('❌ Error repairing user document: $e');
      return false;
    }
  }

  // Repair missing user document by UID
  static Future<bool> repairUserDocumentByUID(String uid) async {
    try {
      print('🔧 Repairing user document for UID: $uid');

      // Check if document exists
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        print('✅ User document already exists');
        return true;
      }

      // Try to get user info from Firebase Auth
      // Note: This requires admin privileges, so we'll create with minimal data
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': 'User',
        'email': 'unknown@example.com',
        'userType': 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'repaired': true,
      });

      print('✅ User document repaired with minimal data');
      return true;
    } catch (e) {
      print('❌ Error repairing user document by UID: $e');
      return false;
    }
  }

  // Check and repair all missing documents for authenticated users
  static Future<void> checkAndRepairAllUsers() async {
    try {
      print('🔧 Checking for users without Firestore documents...');

      // This would require admin access to list all users
      // For now, we'll just repair the current user
      await repairCurrentUserDocument();

    } catch (e) {
      print('❌ Error checking and repairing users: $e');
    }
  }

  // Verify Firestore document integrity
  static Future<bool> verifyUserDocumentIntegrity(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (!doc.exists) {
        print('❌ Document does not exist for UID: $uid');
        return false;
      }

      final data = doc.data();
      if (data == null) {
        print('❌ Document exists but has no data for UID: $uid');
        return false;
      }

      // Check required fields
      final requiredFields = ['uid', 'email', 'userType'];
      for (final field in requiredFields) {
        if (!data.containsKey(field) || data[field] == null) {
          print('❌ Missing required field "$field" for UID: $uid');
          return false;
        }
      }

      print('✅ Document integrity verified for UID: $uid');
      return true;
    } catch (e) {
      print('❌ Error verifying document integrity: $e');
      return false;
    }
  }
}
