import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/responder_state.dart';
import 'responder_dashboard.dart';

class ResponderLoginScreen extends StatefulWidget {
  const ResponderLoginScreen({super.key});

  @override
  State<ResponderLoginScreen> createState() => _ResponderLoginScreenState();
}

class _ResponderLoginScreenState extends State<ResponderLoginScreen> {
  // Enhanced Citizen App Colors for "Powerful" look
  static const Color _bgColor = Color(0xFFF8F7FC); 
  static const Color _primaryPurple = Color(0xFF8247FF); // Slightly more vibrant/neon purple
  static const Color _primaryPurpleDark = Color(0xFF6B21A8); // Deep rich purple for gradients
  static const Color _primaryPurpleLight = Color(0xFFF3F0FF); 
  static const Color _textDark = Color(0xFF0F172A); 
  static const Color _textGrey = Color(0xFF64748B);
  static const Color _finalButtonColor = Color(0xFFFF3B4C); // Punchy Red
  static const Color _finalButtonColorDark = Color(0xFFE11D48);

  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _ambulanceNoController = TextEditingController();
  
  String _selectedVehicleType = 'ALS Ambulance (Advanced)';
  String _selectedHospital = 'Sir T. General Hospital, Bhavnagar';
  String _selectedShift = '24/7 Rapid Emergency Duty';
  bool _isLoading = false;
  bool _isOxygenReady = true;
  bool _isAEDReady = true;

  final List<String> _vehicleTypes = [
    'ALS Ambulance (Advanced)',
    'BLS Ambulance (Basic Life Support)',
    'Patient Transport Van',
    'Rapid First Responder Unit',
  ];

  final List<String> _hospitals = [
    'Sir T. General Hospital, Bhavnagar',
    'BIMS Trauma Center & ER Unit',
    '108 GVK EMRI Base Hub (North)',
    'Bajrangdas Bapa Emergency Care',
  ];

  final List<String> _shifts = [
    '24/7 Rapid Emergency Duty',
    'Day Shift (08:00 AM - 08:00 PM)',
    'Night Shift (08:00 PM - 08:00 AM)',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _ambulanceNoController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0) {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required')));
        return;
      }
      if (_phoneController.text.trim().length != 10) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number must be 10 digits')));
        return;
      }
    }

    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      _submitAuth();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _submitAuth() async {
    setState(() => _isLoading = true);
    final state = Provider.of<ResponderState>(context, listen: false);
    await state.registerResponder(
      name: _nameController.text.trim().isEmpty ? 'Ramesh Kumar' : _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? '+91 98765 43210' : _phoneController.text.trim(),
      ambulanceNo: _ambulanceNoController.text.trim().isEmpty ? 'GJ-04-AB-1088' : _ambulanceNoController.text.trim(),
      license: _licenseController.text.trim().isEmpty ? 'GJ0420210098765' : _licenseController.text.trim(),
      vehicleType: _selectedVehicleType,
      hospital: _selectedHospital,
    );
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResponderDashboard()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildSlide1(),
                  _buildSlide2(),
                  _buildSlide3(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          if (_currentPage > 0)
            GestureDetector(
              onTap: _prevPage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: _primaryPurple.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textDark),
              ).animate().scale(curve: Curves.easeOutBack, duration: 300.ms),
            )
          else
            const SizedBox(width: 42, height: 42),

          Expanded(
            child: Column(
              children: [
                const Text(
                  'SAHAY NATIONAL LIFELINE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: _primaryPurple,
                    letterSpacing: 1.8,
                  ),
                ).animate().fade(duration: 400.ms).slideY(begin: -0.2),
                const SizedBox(height: 12),
                // Stepper Dots with Glow
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_totalPages, (index) {
                    bool isActive = index == _currentPage;
                    bool isPassed = index < _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: isActive ? 28 : 6,
                      decoration: BoxDecoration(
                        color: isActive || isPassed ? _primaryPurple : _primaryPurpleLight,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: isActive ? [BoxShadow(color: _primaryPurple.withOpacity(0.4), blurRadius: 6, spreadRadius: 1)] : [],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }

  Widget _buildSlideLayout({
    required IconData topIcon,
    required String title,
    required String subtitle,
    required String cardSectionTitle,
    required List<Widget> cardContent,
    required String buttonText,
    required bool isFinalStep,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 28),
          
          // Enhanced Circular Icon with dual-layer glow
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _primaryPurple.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _primaryPurpleLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: _primaryPurple.withOpacity(0.2), blurRadius: 20, spreadRadius: -5),
                ],
              ),
              child: Icon(topIcon, size: 42, color: _primaryPurple),
            ),
          ).animate().scale(delay: 50.ms, curve: Curves.easeOutBack, duration: 600.ms),
          
          const SizedBox(height: 24),
          
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _textDark,
              letterSpacing: -0.5,
            ),
          ).animate().fade(duration: 400.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 10),
          
          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: _textGrey,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ).animate().fade(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 36),
          
          // Massive Premium White Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32), // More rounded like modern iOS
              boxShadow: [
                BoxShadow(color: _primaryPurple.withOpacity(0.06), blurRadius: 40, offset: const Offset(0, 20)),
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cardSectionTitle.isNotEmpty) ...[
                  Text(
                    cardSectionTitle.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _textGrey,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                ...cardContent,
                
                const SizedBox(height: 40),
                
                // Powerful Gradient Button
                SizedBox(
                  width: double.infinity,
                  height: 64, // Taller button for better tap target
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: isFinalStep 
                            ? [_finalButtonColor, _finalButtonColorDark]
                            : [_primaryPurple, _primaryPurpleDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isFinalStep ? _finalButtonColor : _primaryPurple).withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _isLoading && isFinalStep
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                        buttonText,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fade(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSlide1() {
    return _buildSlideLayout(
      topIcon: Icons.badge_rounded,
      title: 'Driver Registration',
      subtitle: 'Official emergency profile for 108 EMRI dispatch & Golden Hour safety.',
      cardSectionTitle: 'PERSONAL DEMOGRAPHICS',
      buttonText: 'Continue to Verification',
      isFinalStep: false,
      cardContent: [
        _buildInputField(controller: _nameController, icon: Icons.person_rounded, hint: 'Full Legal Name'),
        const SizedBox(height: 16),
        _buildInputField(controller: _phoneController, icon: Icons.phone_rounded, hint: '10-Digit Mobile Number', keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        _buildInputField(controller: _licenseController, icon: Icons.credit_card_rounded, hint: 'EMT Badge / License ID'),
      ],
    );
  }

  Widget _buildSlide2() {
    return _buildSlideLayout(
      topIcon: Icons.directions_car_rounded,
      title: 'Vehicle Information',
      subtitle: 'Register your emergency vehicle and assigned hospital hub.',
      cardSectionTitle: 'VEHICLE DETAILS',
      buttonText: 'Continue to Equipment',
      isFinalStep: false,
      cardContent: [
        _buildInputField(controller: _ambulanceNoController, icon: Icons.numbers_rounded, hint: 'Ambulance Registration No.'),
        const SizedBox(height: 16),
        _buildDropdownField(value: _selectedVehicleType, items: _vehicleTypes, icon: Icons.local_shipping_rounded, onChanged: (v) => setState(() => _selectedVehicleType = v!)),
        const SizedBox(height: 16),
        _buildDropdownField(value: _selectedHospital, items: _hospitals, icon: Icons.local_hospital_rounded, onChanged: (v) => setState(() => _selectedHospital = v!)),
      ],
    );
  }

  Widget _buildSlide3() {
    return _buildSlideLayout(
      topIcon: Icons.health_and_safety_rounded,
      title: 'Readiness & Shift',
      subtitle: 'Confirm your shift schedule and mandatory life-saving equipment.',
      cardSectionTitle: 'EQUIPMENT CHECKLIST',
      buttonText: 'ACTIVATE SAHAY LIFELINE',
      isFinalStep: true,
      cardContent: [
        _buildDropdownField(value: _selectedShift, items: _shifts, icon: Icons.access_time_rounded, onChanged: (v) => setState(() => _selectedShift = v!)),
        const SizedBox(height: 28),
        _buildToggleRow(title: 'Oxygen Cylinder Ready', value: _isOxygenReady, onChanged: (v) => setState(() => _isOxygenReady = v)),
        const SizedBox(height: 24),
        _buildToggleRow(title: 'AED Operational', value: _isAEDReady, onChanged: (v) => setState(() => _isAEDReady = v)),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _primaryPurpleLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.transparent, width: 2), // Placeholder for focus borders if needed
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: _textDark),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(icon, color: _primaryPurple, size: 24),
          ),
          hintText: hint,
          hintStyle: const TextStyle(color: _textGrey, fontWeight: FontWeight.w600, fontSize: 16),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(color: _primaryPurple),
          ),
          labelText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: _primaryPurpleLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          icon: const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.keyboard_arrow_down_rounded, color: _primaryPurple),
          ),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Icon(icon, color: _primaryPurple, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: _textDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: value ? const Color(0xFFE8FDF0) : Colors.transparent, // Very light green if active
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: value ? const Color(0xFF22C55E).withOpacity(0.3) : Colors.transparent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF22C55E),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: _textGrey.withOpacity(0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
