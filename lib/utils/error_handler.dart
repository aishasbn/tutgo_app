
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ErrorHandler {
  // Show error dialog with consistent styling
  static void showErrorDialog(BuildContext context, String message, {String? title}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title ?? 'Error',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE91E63),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show success dialog
  static void showSuccessDialog(BuildContext context, String message, {String? title, VoidCallback? onOk}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title ?? 'Berhasil',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onOk?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE91E63),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFFE91E63),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'Ya',
    String cancelText = 'Batal',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE91E63),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Format Firebase Auth error for user display
  static String formatFirebaseError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'Password terlalu lemah. Minimal 6 karakter dengan kombinasi huruf dan angka.';
        case 'email-already-in-use':
          return 'Email sudah digunakan oleh akun lain. Silakan gunakan email yang berbeda.';
        case 'invalid-email':
          return 'Format email tidak valid. Periksa kembali email Anda.';
        case 'user-not-found':
          return 'Akun tidak ditemukan. Periksa email Anda atau daftar akun baru.';
        case 'wrong-password':
          return 'Password salah. Periksa kembali password Anda.';
        case 'user-disabled':
          return 'Akun telah dinonaktifkan. Hubungi administrator.';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan login. Coba lagi dalam beberapa menit.';
        case 'operation-not-allowed':
          return 'Operasi tidak diizinkan. Hubungi administrator.';
        case 'invalid-credential':
          return 'Kredensial tidak valid. Periksa email dan password Anda.';
        case 'network-request-failed':
          return 'Koneksi internet bermasalah. Periksa koneksi Anda dan coba lagi.';
        case 'requires-recent-login':
          return 'Operasi ini memerlukan login ulang. Silakan logout dan login kembali.';
        default:
          return error.message ?? 'Terjadi kesalahan yang tidak diketahui.';
      }
    }
    
    // Handle other types of errors
    String errorMessage = error.toString();
    if (errorMessage.startsWith('Exception: ')) {
      errorMessage = errorMessage.substring(11);
    }
    
    return errorMessage;
  }

  // Log error for debugging
  static void logError(String operation, dynamic error, {StackTrace? stackTrace}) {
    print('❌ Error in $operation:');
    print('   Error: $error');
    if (stackTrace != null) {
      print('   Stack trace: $stackTrace');
    }
    print('   Time: ${DateTime.now()}');
    print('');
  }

  // Check if error is network related
  static bool isNetworkError(dynamic error) {
    if (error is FirebaseAuthException) {
      return error.code == 'network-request-failed';
    }
    
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') || 
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('unreachable');
  }

  // Get user-friendly error title
  static String getErrorTitle(dynamic error) {
    if (isNetworkError(error)) {
      return 'Masalah Koneksi';
    }
    
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Login Gagal';
        case 'email-already-in-use':
          return 'Email Sudah Digunakan';
        case 'weak-password':
          return 'Password Lemah';
        case 'too-many-requests':
          return 'Terlalu Banyak Percobaan';
        default:
          return 'Error';
      }
    }
    
    return 'Error';
  }
}

