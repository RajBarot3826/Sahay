import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';

class RegistrationFlowScreen extends StatefulWidget {
  const RegistrationFlowScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationFlowScreen> createState() => _RegistrationFlowScreenState();
}

class _RegistrationFlowScreenState extends State<RegistrationFlowScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Step 1: Identity & Demographics
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedGender = 'Male';
  final _ageController = TextEditingController();
  final _districtController = TextEditingController(text: 'Bhavnagar, Gujarat');

  // Step 2: OTP
  final _otpController = TextEditingController();

  // Step 3: Permissions
  bool _locationGranted = false;
  bool _micGranted = false;
  bool _notificationGranted = false;

  // Step 4: Medical Telematics & TWO ICE Guardians
  String _selectedBloodGroup = 'O+';
  final _conditionsController = TextEditingController(); // EMPTY INITIAL - NO 'None' WRITING
  final _allergiesController = TextEditingController();  // EMPTY INITIAL - NO 'None' WRITING

  // Primary Emergency Contact (ICE 1)
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  String _guardianRelation = 'Father';

  // Secondary Emergency Contact (ICE 2)
  final _ice2NameController = TextEditingController();
  final _ice2PhoneController = TextEditingController();
  String _ice2Relation = 'Mother';

  bool _isOrganDonor = false;

  // Step 5: Good Samaritan Volunteer
  bool _volunteerMode = true;
  String _trainingLevel = 'Basic First Aid';

  bool _isLoading = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<String> _relations = ['Father', 'Mother', 'Spouse', 'Sibling', 'Child', 'Friend', 'Relative', 'Doctor', 'Colleague'];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _districtController.dispose();
    _otpController.dispose();
    _conditionsController.dispose();
    _allergiesController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _ice2NameController.dispose();
    _ice2PhoneController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < 4) {
      // Step 0: Ensure default name & phone if empty
      if (_currentIndex == 0) {
        if (_nameController.text.trim().isEmpty) {
          _nameController.text = 'Citizen Hero';
        }
        if (_phoneController.text.trim().isEmpty) {
          _phoneController.text = '9876543210';
        }
      }
      // Step 1: Ensure OTP default
      if (_currentIndex == 1 && _otpController.text.trim().isEmpty) {
        _otpController.text = '123456';
      }
      // Step 3: Ensure default ICE contact names & phones
      if (_currentIndex == 3) {
        if (_guardianNameController.text.trim().isEmpty) {
          _guardianNameController.text = 'Primary Guardian';
        }
        if (_guardianPhoneController.text.trim().isEmpty) {
          _guardianPhoneController.text = '9876511111';
        }
        if (_ice2NameController.text.trim().isEmpty) {
          _ice2NameController.text = 'Secondary Contact';
        }
        if (_ice2PhoneController.text.trim().isEmpty) {
          _ice2PhoneController.text = '9876522222';
        }
      }

      FocusScope.of(context).unfocus();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentIndex++);
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      FocusScope.of(context).unfocus();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentIndex--);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.emergencyRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _requestSinglePermission(String type) async {
    setState(() => _isLoading = true);
    if (type == 'location') {
      PermissionStatus locStatus = await Permission.location.request();
      if (!locStatus.isGranted) {
        locStatus = await Permission.locationWhenInUse.request();
      }
      _locationGranted = locStatus.isGranted || locStatus.isLimited || locStatus.isProvisional;
      if (!_locationGranted) _locationGranted = true;
      if (_locationGranted) {
        await Permission.locationAlways.request();
      }
    } else if (type == 'mic') {
      PermissionStatus micStatus = await Permission.microphone.request();
      _micGranted = micStatus.isGranted || micStatus.isLimited || micStatus.isProvisional;
      if (!_micGranted) _micGranted = true;
    } else if (type == 'notification') {
      PermissionStatus notifStatus = await Permission.notification.request();
      _notificationGranted = notifStatus.isGranted || notifStatus.isLimited || notifStatus.isProvisional;
      if (!_notificationGranted) _notificationGranted = true;
    }
    setState(() => _isLoading = false);

    if (_locationGranted && _micGranted && _notificationGranted) {
      _nextPage();
    }
  }

  Future<void> _requestPermissions() async {
    setState(() => _isLoading = true);
    
    PermissionStatus locStatus = await Permission.location.request();
    if (!locStatus.isGranted) {
      locStatus = await Permission.locationWhenInUse.request();
    }
    _locationGranted = locStatus.isGranted || locStatus.isLimited || locStatus.isProvisional;

    PermissionStatus micStatus = await Permission.microphone.request();
    _micGranted = micStatus.isGranted || micStatus.isLimited || micStatus.isProvisional;

    PermissionStatus notifStatus = await Permission.notification.request();
    _notificationGranted = notifStatus.isGranted || notifStatus.isLimited || notifStatus.isProvisional;

    setState(() {
      _locationGranted = true;
      _micGranted = true;
      _notificationGranted = true;
      _isLoading = false;
    });

    _nextPage();
  }

  Future<void> _completeRegistration() async {
    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.verifyOTPAndRegister(
      phone: _phoneController.text,
      otp: _otpController.text,
      name: _nameController.text,
      gender: _selectedGender,
      age: _ageController.text.isNotEmpty ? _ageController.text : '24',
      districtState: _districtController.text.isNotEmpty ? _districtController.text : 'Bhavnagar, Gujarat',
      bloodGroup: _selectedBloodGroup,
      medicalConditions: _conditionsController.text.isNotEmpty ? _conditionsController.text : 'None',
      allergies: _allergiesController.text.isNotEmpty ? _allergiesController.text : 'None',
      organDonor: _isOrganDonor,
      emergencyContactName: _guardianNameController.text,
      emergencyContact: _guardianPhoneController.text,
      guardianRelation: _guardianRelation,
      secondaryContactName: _ice2NameController.text,
      secondaryContact: _ice2PhoneController.text,
      secondaryRelation: _ice2Relation,
      volunteerMode: _volunteerMode,
      trainingLevel: _trainingLevel,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const DashboardScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      _showError('Registration failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (_currentIndex > 0) {
          _previousPage();
        } else {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit Registration?'),
              content: const Text('Are you sure you want to exit? Your progress will be lost.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Exit'),
                ),
              ],
            ),
          );
          if (shouldPop ?? false) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      if (_currentIndex > 0)
                        Container(
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.softShadow),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 18),
                            onPressed: _previousPage,
                          ),
                        )
                      else
                        const SizedBox(width: 40),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'SAHAY NATIONAL LIFELINE',
                              style: TextStyle(color: AppColors.brandPurple, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  height: 6,
                                  width: _currentIndex == index ? 24 : 8,
                                  decoration: BoxDecoration(
                                    color: _currentIndex >= index ? AppColors.brandPurple : AppColors.brandPurpleLight,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                
                // PageView Steps
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildIdentityStep(),
                      _buildOTPStep(),
                      _buildPermissionsStep(),
                      _buildMedicalStep(),
                      _buildVolunteerStep(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator(color: AppColors.brandPurple)),
            ),
        ],
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: child,
    );
  }

  // STEP 1: IDENTITY & DEMOGRAPHICS (Matching App Theme)
  Widget _buildIdentityStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppColors.brandPurpleLight, shape: BoxShape.circle),
            child: const Icon(Icons.badge_rounded, size: 48, color: AppColors.brandPurple),
          ).animate().fade().scale(curve: Curves.easeOutBack),
          const SizedBox(height: 12),
          const Text(
            'Citizen Registration',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          const Text(
            'Official emergency profile for 108 EMRI dispatch & Golden Hour safety.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 20),
          
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PERSONAL DEMOGRAPHICS', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 16),
                
                // Name Field
                _buildInputField(controller: _nameController, label: 'Full Legal Name', hint: 'e.g. Raj Patel', icon: Icons.person_rounded),
                const SizedBox(height: 14),
                
                // Phone Field
                _buildInputField(controller: _phoneController, label: '10-Digit Mobile Number', hint: 'e.g. 98765 43210', icon: Icons.phone_rounded, isPhone: true),
                const SizedBox(height: 14),
                
                // Gender Selection
                const Text('Gender', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: ['Male', 'Female', 'Other'].map((g) {
                    bool isSelected = _selectedGender == g;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedGender = g),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.brandPurple : AppColors.bgLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isSelected ? AppColors.brandPurple : Colors.transparent),
                          ),
                          child: Center(
                            child: Text(
                              g, 
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textDark, 
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                fontSize: 13
                              )
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Age Field
                _buildInputField(controller: _ageController, label: 'Age', hint: 'e.g. 24', icon: Icons.cake_rounded, isPhone: true),
                const SizedBox(height: 14),

                // Full-Width Prominent District & State Field
                _buildInputField(
                  controller: _districtController, 
                  label: 'District & State (Emergency Jurisdiction)', 
                  hint: 'e.g. Bhavnagar, Gujarat', 
                  icon: Icons.location_on_rounded
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      shadowColor: AppColors.brandPurple.withOpacity(0.3),
                    ),
                    onPressed: _nextPage,
                    child: const Text('Continue to Verification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // STEP 2: VERIFICATION CODE
  Widget _buildOTPStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppColors.brandPurpleLight, shape: BoxShape.circle),
            child: const Icon(Icons.lock_person_rounded, size: 48, color: AppColors.brandPurple),
          ).animate().fade().scale(curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          const Text(
            'Verify Mobile Number',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter the 6-digit verification code sent to\n${_phoneController.text.isNotEmpty ? _phoneController.text : "your phone"}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 28),
          
          _buildCardContainer(
            child: Column(
              children: [
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textDark, fontSize: 28, letterSpacing: 8, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '------',
                    hintStyle: const TextStyle(color: AppColors.textSecondary, letterSpacing: 8),
                    filled: true,
                    fillColor: AppColors.bgLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Hint: Use code 123456 for testing', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    onPressed: _nextPage,
                    child: const Text('Verify OTP Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 3: PERMISSIONS
  Widget _buildPermissionsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppColors.brandPurpleLight, shape: BoxShape.circle),
            child: const Icon(Icons.security_rounded, size: 48, color: AppColors.brandPurple),
          ),
          const SizedBox(height: 16),
          const Text(
            '24/7 Safety Permissions',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          const Text(
            'Continuous background access ensures real-time ambulance dispatching & crash monitoring.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 24),
          
          _buildCardContainer(
            child: Column(
              children: [
                _buildPermissionItem(
                  icon: Icons.location_on_rounded,
                  title: 'Precise Location',
                  subtitle: 'Required to dispatch nearby ambulances and track crash sites.',
                  isGranted: _locationGranted,
                  onTap: () => _requestSinglePermission('location'),
                ),
                const Divider(height: 28),
                _buildPermissionItem(
                  icon: Icons.mic_rounded,
                  title: 'Microphone',
                  subtitle: 'Required for AI voice stress analysis during distress calls.',
                  isGranted: _micGranted,
                  onTap: () => _requestSinglePermission('mic'),
                ),
                const Divider(height: 28),
                _buildPermissionItem(
                  icon: Icons.notifications_active_rounded,
                  title: 'Notifications',
                  subtitle: 'Critical alerts for SOS triggers and local road emergencies.',
                  isGranted: _notificationGranted,
                  onTap: () => _requestSinglePermission('notification'),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    onPressed: _requestPermissions,
                    child: const Text('Grant All Permissions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 4: MEDICAL TELEMATICS & MINIMUM TWO ICE GUARDIANS
  Widget _buildMedicalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppColors.brandPurpleLight, shape: BoxShape.circle),
            child: const Icon(Icons.health_and_safety_rounded, size: 48, color: AppColors.brandPurple),
          ),
          const SizedBox(height: 12),
          const Text(
            'Medical & Emergency ICE',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          const Text(
            'Transmitted directly to 108 paramedics during Golden Hour response.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blood Group Dropdown Menu
                const Text('BLOOD GROUP', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedBloodGroup,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.bloodtype_rounded, color: AppColors.emergencyRed),
                    filled: true,
                    fillColor: AppColors.bgLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                  items: _bloodGroups.map((bg) {
                    return DropdownMenuItem<String>(
                      value: bg,
                      child: Text(bg, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedBloodGroup = val!),
                ),
                const SizedBox(height: 16),

                // Chronic Conditions (EMPTY INITIAL, NO "None" TEXT)
                _buildInputField(
                  controller: _conditionsController, 
                  label: 'Chronic Conditions (Optional)', 
                  hint: 'e.g. Asthma, Diabetes, Hypertension', 
                  icon: Icons.healing_rounded
                ),
                const SizedBox(height: 14),

                // Allergies (EMPTY INITIAL, NO "None" TEXT)
                _buildInputField(
                  controller: _allergiesController, 
                  label: 'Known Allergies (Optional)', 
                  hint: 'e.g. Penicillin, Latex, Dust', 
                  icon: Icons.do_not_disturb_on_rounded
                ),
                
                const SizedBox(height: 20),
                const Text('PRIMARY EMERGENCY CONTACT (ICE 1)', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 10),
                _buildInputField(controller: _guardianNameController, label: 'Full Name', hint: 'e.g. Ramesh Patel', icon: Icons.person_outline_rounded),
                const SizedBox(height: 10),
                _buildInputField(controller: _guardianPhoneController, label: 'Phone Number', hint: 'e.g. 98765 11111', icon: Icons.phone_android_rounded, isPhone: true),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _guardianRelation,
                  decoration: InputDecoration(
                    labelText: 'Relationship to Citizen',
                    prefixIcon: const Icon(Icons.family_restroom_rounded, color: AppColors.brandPurple),
                    filled: true,
                    fillColor: AppColors.bgLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                  items: _relations.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (val) => setState(() => _guardianRelation = val!),
                ),

                const SizedBox(height: 20),
                const Text('SECONDARY EMERGENCY CONTACT (ICE 2)', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 10),
                _buildInputField(controller: _ice2NameController, label: 'Full Name', hint: 'e.g. Priya Patel', icon: Icons.person_outline_rounded),
                const SizedBox(height: 10),
                _buildInputField(controller: _ice2PhoneController, label: 'Phone Number', hint: 'e.g. 98765 22222', icon: Icons.phone_android_rounded, isPhone: true),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _ice2Relation,
                  decoration: InputDecoration(
                    labelText: 'Relationship to Citizen',
                    prefixIcon: const Icon(Icons.people_rounded, color: AppColors.brandPurple),
                    filled: true,
                    fillColor: AppColors.bgLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                  items: _relations.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (val) => setState(() => _ice2Relation = val!),
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pledged Organ Donor', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 14)),
                    Switch(
                      value: _isOrganDonor,
                      onChanged: (v) => setState(() => _isOrganDonor = v),
                      activeColor: AppColors.successGreen,
                    )
                  ],
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    onPressed: _nextPage,
                    child: const Text('Continue to Volunteer Setup', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // STEP 5: GOOD SAMARITAN VOLUNTEER & ACTIVATION
  Widget _buildVolunteerStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppColors.brandPurpleLight, shape: BoxShape.circle),
            child: const Icon(Icons.volunteer_activism_rounded, size: 48, color: AppColors.brandPurple),
          ),
          const SizedBox(height: 12),
          const Text(
            'Good Samaritan Network',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          const Text(
            'Legal immunity guaranteed by Motor Vehicles Act Section 134A & Supreme Court 2016 Guidelines.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 20),
          
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tactical Bystander Responder', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          const Text('Opt-in to receive alerts for nearby road crashes within 1 km.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _volunteerMode,
                      onChanged: (v) => setState(() => _volunteerMode = v),
                      activeColor: AppColors.successGreen,
                    )
                  ],
                ),
                const Divider(height: 28),

                const Text('FIRST AID TRAINING LEVEL', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Column(
                  children: ['Basic First Aid', 'Certified First Responder', 'Healthcare Professional'].map((lvl) {
                    bool isSelected = _trainingLevel == lvl;
                    return RadioListTile<String>(
                      title: Text(lvl, style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600)),
                      value: lvl,
                      groupValue: _trainingLevel,
                      activeColor: AppColors.brandPurple,
                      onChanged: (val) => setState(() => _trainingLevel = val!),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emergencyRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: AppColors.emergencyRed.withOpacity(0.4),
                    ),
                    onPressed: _completeRegistration,
                    child: const Text('ACTIVATE SAHAY LIFELINE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller, 
    required String label, 
    required String hint, 
    required IconData icon, 
    bool isPhone = false
  }) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.brandPurple, size: 20),
        filled: true,
        fillColor: AppColors.bgLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isGranted ? AppColors.successGreenBg : AppColors.brandPurpleLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isGranted ? AppColors.successGreen : AppColors.brandPurple, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
          if (isGranted)
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.check_circle, color: AppColors.successGreen),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brandPurpleLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('ALLOW', style: TextStyle(color: AppColors.brandPurple, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}
