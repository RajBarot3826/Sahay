import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../services/certificate_service.dart';

class GoodSamaritanProtectionScreen extends StatefulWidget {
  const GoodSamaritanProtectionScreen({Key? key}) : super(key: key);

  @override
  State<GoodSamaritanProtectionScreen> createState() => _GoodSamaritanProtectionScreenState();
}

class _GoodSamaritanProtectionScreenState extends State<GoodSamaritanProtectionScreen> {
  final CertificateService _certService = CertificateService();
  bool _isGenerating = false;

  Future<void> _generateCertificate() async {
    setState(() => _isGenerating = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String userName = authProvider.userName;
      String city = authProvider.districtState.split(',').first.trim();
      
      // Get Location
      Position? position;
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
            position = await Geolocator.getCurrentPosition();
          }
        }
      } catch (e) {
        debugPrint('Geolocator error: $e');
      }
      
      final result = await _certService.generateCertificate(
        helperName: userName,
        city: city.isEmpty ? 'Unknown' : city,
        lat: position?.latitude ?? 0.0,
        lng: position?.longitude ?? 0.0,
        emergencyId: 'EMG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Certificate Generated Successfully!')));
      
      _certService.previewCertificate(result['pdfBytes']);
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('GOOD SAMARITAN LAW', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Shield Icon Badge
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.successGreen.withAlpha(50), width: 4),
                  boxShadow: [BoxShadow(color: AppColors.successGreen.withAlpha(40), blurRadius: 30, spreadRadius: 5)],
                ),
                child: const Icon(Icons.shield_rounded, size: 72, color: AppColors.successGreen),
              ),
              const SizedBox(height: 24),

              const Text(
                'You are Protected',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: AppColors.textDark, letterSpacing: -0.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'Good Samaritan Law protects you from harassment while helping accident victims.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
              ),
              const SizedBox(height: 32),

              // Generate Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                    shadowColor: AppColors.brandPurple.withAlpha(100),
                  ),
                  onPressed: _isGenerating ? null : _generateCertificate,
                  child: _isGenerating 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('GENERATE MY CERTIFICATE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 32),

              // My Certificates Section
              if (uid != null) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('My Certificates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark)),
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('certificates').orderBy('date', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No certificates generated yet.', style: TextStyle(color: AppColors.textSecondary)));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
                        var data = doc.data() as Map<String, dynamic>;
                        
                        DateTime date = data['date'] != null ? (data['date'] as Timestamp).toDate() : DateTime.now();
                        String formattedDate = DateFormat('dd MMM yyyy').format(date);
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(data['certId'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandPurple)),
                                    Text(formattedDate, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text('${data['city'] ?? 'Unknown'}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.share, size: 16),
                                      label: const Text('Share'),
                                      onPressed: () {
                                        if (data['pdfPath'] != null) {
                                          _certService.shareCertificate(data['pdfPath']);
                                        }
                                      },
                                    ),
                                  ],
                                )
                              ]
                            )
                          )
                        );
                      }
                    );
                  }
                ),
                const SizedBox(height: 32),
              ],

              // Legal Info Expandable Cards
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Legal Protections', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark)),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  children: [
                    _buildExpandableTile('Legal Protection', 'As per Good Samaritan Law', 'Under Section 134A of the Motor Vehicles (Amendment) Act, 2019, a Good Samaritan shall not be liable for any civil or criminal action for any injury to or death of the victim of an accident involving a motor vehicle, where such injury or death resulted from the Good Samaritan\'s negligence in acting or failing to act while rendering emergency medical or non-medical care or assistance.'),
                    const Divider(height: 1, color: Colors.black12),
                    _buildExpandableTile('No Harassment', 'By Police or Authorities', 'A Good Samaritan shall not be subjected to harassment by the police or any other authority. They are not required to reveal their personal identity, and can choose to remain anonymous.'),
                    const Divider(height: 1, color: Colors.black12),
                    _buildExpandableTile('No Court Appearance', 'You won\'t be forced to appear', 'A Good Samaritan who has voluntarily informed the police or emergency services regarding an injured person shall not be compelled to appear in court or before the police to give evidence.'),
                    const Divider(height: 1, color: Colors.black12),
                    _buildExpandableTile('Confidentiality', 'Your identity is kept strictly safe', 'Personal information of a Good Samaritan shall be kept strictly confidential by hospitals, police, and other authorities unless they voluntarily choose to disclose it.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableTile(String title, String subtitle, String content) {
    return ExpansionTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: AppColors.successGreen.withAlpha(20), shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, size: 18, color: AppColors.successGreen),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Text(
            content,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
        )
      ],
    );
  }
}
