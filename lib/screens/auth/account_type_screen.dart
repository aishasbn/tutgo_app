import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/route_helper.dart';

class AccountTypeScreen extends StatefulWidget {
  const AccountTypeScreen({super.key});

  @override
  _AccountTypeScreenState createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen> {
  String selectedType = 'user'; // 'user' or 'staff'

  Future<void> _saveAccountType(String accountType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_account_type', accountType);
      print('✅ Account type saved: $accountType');
    } catch (e) {
      print('❌ Error saving account type: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'Choose Your Account Type',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Account type selection
              Row(
                children: [
                  // Staff option
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedType = 'staff';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selectedType == 'staff' 
                                ? const Color(0xFFE91E63) 
                                : Colors.grey[300]!,
                            width: selectedType == 'staff' ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE91E63).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person_pin,
                                size: 60,
                                color: Color(0xFFE91E63),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Staff',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // User option
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedType = 'user';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selectedType == 'user' 
                                ? const Color(0xFFE91E63) 
                                : Colors.grey[300]!,
                            width: selectedType == 'user' ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE91E63).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.luggage,
                                size: 60,
                                color: Color(0xFFE91E63),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Pengunjung',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Save selected account type
                    await _saveAccountType(selectedType);
                    
                    if (selectedType == 'staff') {
                      RouteHelper.navigateToStaffLogin(context);
                    } else {
                      RouteHelper.navigateToUserLogin(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
