import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

class EdarIncidentReportScreen extends StatefulWidget {
  const EdarIncidentReportScreen({super.key});

  @override
  State<EdarIncidentReportScreen> createState() => _EdarIncidentReportScreenState();
}

class _EdarIncidentReportScreenState extends State<EdarIncidentReportScreen> {
  int _currentStep = 0;
  
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  final _vehiclesController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _licenseController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _locationController.dispose();
    _vehiclesController.dispose();
    _aadhaarController.dispose();
    _licenseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.navyDark, shape: BoxShape.circle, border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3))),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                    ),
                  ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'e-DAR FORM FILLING',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.techCyan, letterSpacing: 2.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(4, (index) => Expanded(
                  child: Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index <= _currentStep ? AppColors.primaryBlue : AppColors.navyDark,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: index <= _currentStep ? AppColors.innerGlowBlue : null,
                    ),
                  ),
                )),
              ).animate().fade(),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: AppColors.premiumCardShadow,
                      border: Border.all(color: AppColors.primaryBlueLight, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_getStepTitle(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5)),
                        const SizedBox(height: 8),
                        const Text('Complete all fields as per standard operating procedure.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textGrey)),
                        
                        const SizedBox(height: 32),
                        
                        // Dynamic Form Content
                        if (_currentStep == 0) ...[
                          _buildField('DATE OF ACCIDENT', Icons.calendar_today_rounded, _dateController),
                          const SizedBox(height: 20),
                          _buildField('EXACT LOCATION (GPS)', Icons.location_on_rounded, _locationController),
                          const SizedBox(height: 20),
                          _buildField('VEHICLES INVOLVED', Icons.directions_car_rounded, _vehiclesController),
                        ] else if (_currentStep == 1) ...[
                          _buildField('DRIVER 1 AADHAAR', Icons.badge_rounded, _aadhaarController),
                          const SizedBox(height: 20),
                          _buildField('DRIVER 1 LICENSE', Icons.contact_mail_rounded, _licenseController),
                        ] else ...[
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text('Form continues...', style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                        
                        const SizedBox(height: 48),
                        
                        // Next/Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: AppColors.policeGradient,
                              boxShadow: AppColors.innerGlowBlue,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentStep < 3) {
                                  setState(() => _currentStep++);
                                } else {
                                  Navigator.pop(context); // Submit
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: Text(_currentStep == 3 ? 'CRYPTOGRAPHIC SIGN & SUBMIT' : 'NEXT SECTION', 
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate(key: ValueKey(_currentStep)).fade(duration: 400.ms).slideX(begin: 0.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'Incident Details';
      case 1: return 'Driver Information';
      case 2: return 'Insurance & Registration';
      case 3: return 'Digital Evidence Review';
      default: return 'e-DAR Report';
    }
  }

  Widget _buildField(String label, IconData icon, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textGrey, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primaryBlueLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
