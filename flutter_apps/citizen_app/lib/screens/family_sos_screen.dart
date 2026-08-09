// Flutter Screen 18: Family SOS (Fully Functional)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';

class FamilySosScreen extends StatefulWidget {
  const FamilySosScreen({Key? key}) : super(key: key);

  @override
  State<FamilySosScreen> createState() => _FamilySosScreenState();
}

class _FamilySosScreenState extends State<FamilySosScreen> {
  List<Map<String, dynamic>> _familyMembers = [];

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('family_contacts');
    if (data != null) {
      setState(() {
        _familyMembers = (jsonDecode(data) as List).map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  Future<void> _saveFamilyMembers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('family_contacts', jsonEncode(_familyMembers));
  }

  void _addFamilyMember() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Family Member', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Relation / Name (e.g. Sister)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandPurple),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                setState(() {
                  _familyMembers.add({
                    'name': nameCtrl.text,
                    'phone': phoneCtrl.text,
                    'active': true,
                  });
                });
                _saveFamilyMembers();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${nameCtrl.text} added to Family SOS network!')),
                );
              }
            },
            child: const Text('ADD MEMBER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('FAMILY SOS', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ALERT CONTACTS', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              const Text('These contacts will be notified automatically if you trigger an SOS alert.', style: TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4)),
              const SizedBox(height: 24),
              
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _familyMembers.length,
                  itemBuilder: (context, index) {
                    final m = _familyMembers[index];
                    return _buildFamilySwitch(
                      m['name'], 
                      m['phone'], 
                      m['active'] as bool, 
                      (val) {
                        setState(() => m['active'] = val);
                        _saveFamilyMembers();
                      },
                    ).animate().fadeIn(delay: (50 * index).ms).slideX();
                  },
                ),
              ),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.alertRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 8,
                    shadowColor: AppColors.alertRed.withAlpha(100),
                  ),
                  onPressed: () async {
                    final activePhones = _familyMembers.where((m) => m['active'] == true).map((m) => m['phone']).join(',');
                    if (activePhones.isNotEmpty) {
                      final url = Uri.parse('sms:$activePhones?body=EMERGENCY! I need help. My location is being shared via Sahay.');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No active family members to alert.')));
                    }
                  },
                  icon: const Icon(Icons.warning_rounded, color: Colors.white),
                  label: const Text('SEND FAMILY ALERT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 0.5)),
                ),
              ).animate().scale(delay: 300.ms),
              const SizedBox(height: 12),

              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 8,
                    shadowColor: AppColors.brandPurple.withAlpha(100),
                  ),
                  onPressed: _addFamilyMember,
                  icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
                  label: const Text('Add Family Member', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 0.5)),
                ),
              ).animate().fadeIn(delay: 400.ms)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFamilySwitch(String name, String phone, bool val, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
        border: Border.all(color: val ? AppColors.brandPurple.withAlpha(30) : Colors.transparent, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onChanged(!val),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: val ? AppColors.brandPurpleLight : AppColors.bgLight, shape: BoxShape.circle),
                  child: Icon(Icons.person_rounded, color: val ? AppColors.brandPurple : AppColors.textSecondary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark)),
                      const SizedBox(height: 2),
                      Text(phone, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Switch(
                  value: val,
                  onChanged: onChanged,
                  activeColor: AppColors.brandPurple,
                  activeTrackColor: AppColors.brandPurpleLight,
                  inactiveThumbColor: AppColors.textSecondary,
                  inactiveTrackColor: AppColors.bgLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
