// Flutter Screen 24: Profile with Full National Registry Details & 2 ICE Contacts
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  void _showEditProfileDialog(BuildContext context, AuthProvider auth) {
    final nameCtrl = TextEditingController(text: auth.userName);
    final ageCtrl = TextEditingController(text: auth.age);
    final districtCtrl = TextEditingController(text: auth.districtState);
    final bloodCtrl = TextEditingController(text: auth.bloodGroup);
    final guardianNameCtrl = TextEditingController(text: auth.emergencyContactName);
    final guardianPhoneCtrl = TextEditingController(text: auth.emergencyContact);
    final ice2NameCtrl = TextEditingController(text: auth.secondaryContactName);
    final ice2PhoneCtrl = TextEditingController(text: auth.secondaryContact);
    final medicalCtrl = TextEditingController(text: auth.medicalConditions);
    final allergiesCtrl = TextEditingController(text: auth.allergies);
    String gender = auth.gender;
    bool isDonor = auth.organDonor;
    bool isVolunteer = auth.volunteerMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('EDIT NATIONAL REGISTRY DETAILS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                    const SizedBox(height: 20),
                    
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Full Legal Name',
                        prefixIcon: const Icon(Icons.person_rounded, color: AppColors.brandPurple),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        prefixIcon: const Icon(Icons.cake_rounded, color: AppColors.brandPurple),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: districtCtrl,
                      decoration: InputDecoration(
                        labelText: 'District & State (Emergency Jurisdiction)',
                        prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.brandPurple),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: bloodCtrl,
                      decoration: InputDecoration(
                        labelText: 'Blood Group (e.g. O+, A+)',
                        prefixIcon: const Icon(Icons.bloodtype_rounded, color: AppColors.emergencyRed),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text('PRIMARY EMERGENCY GUARDIAN (ICE 1)', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: guardianNameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Primary Guardian Name',
                        prefixIcon: const Icon(Icons.contact_phone_rounded, color: AppColors.brandPurple),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: guardianPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Primary Guardian Phone',
                        prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.brandPurple),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text('SECONDARY EMERGENCY CONTACT (ICE 2)', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: ice2NameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Secondary Contact Name',
                        prefixIcon: const Icon(Icons.contact_phone_rounded, color: AppColors.brandPurple),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: ice2PhoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Secondary Contact Phone',
                        prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.brandPurple),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: medicalCtrl,
                      decoration: InputDecoration(
                        labelText: 'Chronic Conditions (e.g. Asthma)',
                        prefixIcon: const Icon(Icons.healing_rounded, color: AppColors.brandPurple),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: allergiesCtrl,
                      decoration: InputDecoration(
                        labelText: 'Known Allergies (e.g. Penicillin)',
                        prefixIcon: const Icon(Icons.do_not_disturb_on_rounded, color: AppColors.brandPurple),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Organ Donor Pledged', style: TextStyle(fontWeight: FontWeight.bold)),
                        Switch(
                          value: isDonor,
                          onChanged: (v) => setModalState(() => isDonor = v),
                          activeColor: Colors.green,
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Good Samaritan Volunteer Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                        Switch(
                          value: isVolunteer,
                          onChanged: (v) => setModalState(() => isVolunteer = v),
                          activeColor: AppColors.brandPurple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () async {
                          await auth.updateProfile(
                            name: nameCtrl.text,
                            gender: gender,
                            age: ageCtrl.text,
                            districtState: districtCtrl.text,
                            bloodGroup: bloodCtrl.text,
                            emergencyContactName: guardianNameCtrl.text,
                            emergencyContact: guardianPhoneCtrl.text,
                            secondaryContactName: ice2NameCtrl.text,
                            secondaryContact: ice2PhoneCtrl.text,
                            medicalConditions: medicalCtrl.text,
                            allergies: allergiesCtrl.text,
                            organDonor: isDonor,
                            volunteerMode: isVolunteer,
                          );
                          if (modalContext.mounted) Navigator.pop(modalContext);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('National registry profile updated!'), backgroundColor: Colors.green),
                            );
                          }
                        },
                        child: const Text('SAVE REGISTRY PROFILE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: AppColors.emergencyRed),
              SizedBox(width: 12),
              Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text('Are you sure you want to log out? You will need to sign in again with your phone number and OTP.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emergencyRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/registration', (route) => false);
                }
              },
              child: const Text('LOGOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        String displayName = auth.userName.isNotEmpty ? auth.userName : 'Citizen Hero';
        String userPhone = auth.userPhone.isNotEmpty ? auth.userPhone : '+91 98765 43210';
        String bloodGroup = auth.bloodGroup.isNotEmpty ? auth.bloodGroup : 'O+';
        String district = auth.districtState.isNotEmpty ? auth.districtState : 'Bhavnagar, Gujarat';
        String gender = auth.gender;
        String age = auth.age.isNotEmpty ? auth.age : '24';
        String guardian = auth.emergencyContactName.isNotEmpty ? auth.emergencyContactName : 'Primary Guardian';
        String ice2Name = auth.secondaryContactName.isNotEmpty ? auth.secondaryContactName : 'Secondary ICE Contact';

        return Scaffold(
          backgroundColor: AppColors.bgLight,
          appBar: AppBar(
            title: const Text('NATIONAL REGISTRY PROFILE', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.softShadow),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                          boxShadow: AppColors.glowPurple,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const CircleAvatar(
                            radius: 54,
                            backgroundColor: AppColors.brandPurpleLight,
                            child: Icon(Icons.person_rounded, size: 64, color: AppColors.brandPurple),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showEditProfileDialog(context, auth),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.brandPurple,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(displayName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: AppColors.textDark, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text('$gender • $age yrs • $district', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('$userPhone • Blood: $bloodGroup', style: const TextStyle(color: AppColors.brandPurple, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

                // Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (auth.volunteerMode)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(color: AppColors.brandPurpleLight, borderRadius: BorderRadius.circular(12)),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_user_rounded, color: AppColors.brandPurple, size: 16),
                            SizedBox(width: 6),
                            Text('Good Samaritan Volunteer', style: TextStyle(color: AppColors.brandPurple, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    if (auth.organDonor)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                        child: const Row(
                          children: [
                            Icon(Icons.favorite_rounded, color: Colors.green, size: 16),
                            SizedBox(width: 6),
                            Text('Organ Donor', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 28),

                // Metrics Row
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildProfileStat('12', 'Incidents'),
                        Container(width: 1, height: 40, color: Colors.grey.withAlpha(30)),
                        _buildProfileStat('5', 'Lives Helped', isHighlight: true),
                        Container(width: 1, height: 40, color: Colors.grey.withAlpha(30)),
                        _buildProfileStat('1250', 'Points'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('EMERGENCY GUARDIANS (2 ICE CONTACTS)', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 12),
                
                // ICE 1 Card
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(color: AppColors.brandPurpleLight, shape: BoxShape.circle),
                        child: const Icon(Icons.contact_emergency_rounded, color: AppColors.brandPurple, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$guardian (${auth.guardianRelation}) - ICE 1', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(auth.emergencyContact.isNotEmpty ? auth.emergencyContact : '+91 98765 11111', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ICE 2 Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.brandPurpleLight.withOpacity(0.5), shape: BoxShape.circle),
                        child: const Icon(Icons.people_rounded, color: AppColors.brandPurple, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$ice2Name (${auth.secondaryRelation}) - ICE 2', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(auth.secondaryContact.isNotEmpty ? auth.secondaryContact : '+91 98765 22222', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('ACCOUNT', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 12),

                _buildMenuTile(
                  Icons.person_outline_rounded, 
                  'Personal Details',
                  onTap: () => _showEditProfileDialog(context, auth),
                ),
                _buildMenuTile(
                  Icons.workspace_premium_rounded, 
                  'My Certificates',
                  onTap: () => Navigator.pushNamed(context, '/rewards_badges'),
                ),
                _buildMenuTile(
                  Icons.school_rounded, 
                  'My Trainings',
                  onTap: () => Navigator.pushNamed(context, '/learn_train'),
                ),
                _buildMenuTile(
                  Icons.settings_rounded, 
                  'Settings',
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
                const SizedBox(height: 12),
                _buildMenuTile(
                  Icons.logout_rounded, 
                  'Logout', 
                  color: AppColors.emergencyRed, 
                  isDestructive: true,
                  onTap: () => _showLogoutDialog(context, auth),
                ),
                
                const SizedBox(height: 30),
                const Text('Sahay Citizen National Registry v1.0.0', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileStat(String val, String label, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: isHighlight ? AppColors.brandPurple : AppColors.textDark)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {required VoidCallback onTap, Color color = AppColors.textDark, bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDestructive ? AppColors.emergencyRedBg : AppColors.bgLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: isDestructive ? AppColors.emergencyRed : AppColors.brandPurple, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: isDestructive ? AppColors.emergencyRed : AppColors.textDark)),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.withAlpha(100)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
