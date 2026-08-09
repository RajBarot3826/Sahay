import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isFirstLaunch = true;
  String _userPhone = '';
  
  // National Profile & Demographics Data
  String _userName = '';
  String _gender = 'Male';
  String _age = '';
  String _districtState = 'Bhavnagar, Gujarat';
  String _govtIdNumber = '';

  // Medical Telematics Data
  String _bloodGroup = 'O+';
  String _medicalConditions = '';
  String _allergies = '';
  bool _organDonor = false;

  // Primary Emergency Guardian (ICE 1)
  String _emergencyContactName = '';
  String _emergencyContact = '';
  String _guardianRelation = 'Parent';

  // Secondary Emergency Contact (ICE 2)
  String _secondaryContactName = '';
  String _secondaryContact = '';
  String _secondaryRelation = 'Relative';

  bool _volunteerMode = true;
  String _trainingLevel = 'Basic First Aid';

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isFirstLaunch => _isFirstLaunch;
  String get userPhone => _userPhone;
  String get userName => _userName;
  String get gender => _gender;
  String get age => _age;
  String get districtState => _districtState;
  String get govtIdNumber => _govtIdNumber;
  String get bloodGroup => _bloodGroup;
  String get medicalConditions => _medicalConditions;
  String get allergies => _allergies;
  bool get organDonor => _organDonor;

  String get emergencyContactName => _emergencyContactName;
  String get emergencyContact => _emergencyContact;
  String get guardianRelation => _guardianRelation;

  String get secondaryContactName => _secondaryContactName;
  String get secondaryContact => _secondaryContact;
  String get secondaryRelation => _secondaryRelation;

  bool get volunteerMode => _volunteerMode;
  String get trainingLevel => _trainingLevel;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
    _isAuthenticated = prefs.getBool('is_logged_in') ?? false;
    _userPhone = prefs.getString('user_phone') ?? '';
    _userName = prefs.getString('user_name') ?? 'Citizen';
    _gender = prefs.getString('gender') ?? 'Male';
    _age = prefs.getString('age') ?? '24';
    _districtState = prefs.getString('district_state') ?? 'Bhavnagar, Gujarat';
    _govtIdNumber = prefs.getString('govt_id') ?? '';
    _bloodGroup = prefs.getString('blood_group') ?? 'O+';
    _medicalConditions = prefs.getString('medical_conditions') ?? '';
    _allergies = prefs.getString('allergies') ?? '';
    _organDonor = prefs.getBool('organ_donor') ?? false;
    _emergencyContactName = prefs.getString('emergency_contact_name') ?? '';
    _emergencyContact = prefs.getString('emergency_contact') ?? '';
    _guardianRelation = prefs.getString('guardian_relation') ?? 'Parent';
    _secondaryContactName = prefs.getString('secondary_contact_name') ?? '';
    _secondaryContact = prefs.getString('secondary_contact') ?? '';
    _secondaryRelation = prefs.getString('secondary_relation') ?? 'Relative';
    _volunteerMode = prefs.getBool('volunteer_mode') ?? true;
    _trainingLevel = prefs.getString('training_level') ?? 'Basic First Aid';
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _isFirstLaunch = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', false);
    notifyListeners();
  }

  Future<bool> verifyOTPAndRegister({
    required String phone,
    required String otp,
    required String name,
    required String gender,
    required String age,
    required String districtState,
    required String bloodGroup,
    required String medicalConditions,
    required String allergies,
    required bool organDonor,
    required String emergencyContactName,
    required String emergencyContact,
    required String guardianRelation,
    String secondaryContactName = '',
    String secondaryContact = '',
    String secondaryRelation = 'Relative',
    required bool volunteerMode,
    required String trainingLevel,
  }) async {
    // Always accept registration for seamless usage & testing
    _isAuthenticated = true;
    _isFirstLaunch = false;
      _userPhone = phone;
      _userName = name;
      _gender = gender;
      _age = age;
      _districtState = districtState;
      _bloodGroup = bloodGroup;
      _medicalConditions = medicalConditions;
      _allergies = allergies;
      _organDonor = organDonor;
      _emergencyContactName = emergencyContactName;
      _emergencyContact = emergencyContact;
      _guardianRelation = guardianRelation;
      _secondaryContactName = secondaryContactName;
      _secondaryContact = secondaryContact;
      _secondaryRelation = secondaryRelation;
      _volunteerMode = volunteerMode;
      _trainingLevel = trainingLevel;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setBool('is_first_launch', false);
      await prefs.setString('user_phone', phone);
      await prefs.setString('user_name', name);
      await prefs.setString('gender', gender);
      await prefs.setString('age', age);
      await prefs.setString('district_state', districtState);
      await prefs.setString('blood_group', bloodGroup);
      await prefs.setString('medical_conditions', medicalConditions);
      await prefs.setString('allergies', allergies);
      await prefs.setBool('organ_donor', organDonor);
      await prefs.setString('emergency_contact_name', emergencyContactName);
      await prefs.setString('emergency_contact', emergencyContact);
      await prefs.setString('guardian_relation', guardianRelation);
      await prefs.setString('secondary_contact_name', secondaryContactName);
      await prefs.setString('secondary_contact', secondaryContact);
      await prefs.setString('secondary_relation', secondaryRelation);
      await prefs.setBool('volunteer_mode', volunteerMode);
      await prefs.setString('training_level', trainingLevel);
      
      notifyListeners();
      return true;
  }

  Future<void> updateProfile({
    String? name,
    String? gender,
    String? age,
    String? districtState,
    String? bloodGroup,
    String? emergencyContactName,
    String? emergencyContact,
    String? guardianRelation,
    String? secondaryContactName,
    String? secondaryContact,
    String? secondaryRelation,
    String? medicalConditions,
    String? allergies,
    bool? organDonor,
    bool? volunteerMode,
    String? trainingLevel,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null && name.isNotEmpty) {
      _userName = name;
      await prefs.setString('user_name', name);
    }
    if (gender != null) {
      _gender = gender;
      await prefs.setString('gender', gender);
    }
    if (age != null) {
      _age = age;
      await prefs.setString('age', age);
    }
    if (districtState != null) {
      _districtState = districtState;
      await prefs.setString('district_state', districtState);
    }
    if (bloodGroup != null) {
      _bloodGroup = bloodGroup;
      await prefs.setString('blood_group', bloodGroup);
    }
    if (emergencyContactName != null) {
      _emergencyContactName = emergencyContactName;
      await prefs.setString('emergency_contact_name', emergencyContactName);
    }
    if (emergencyContact != null) {
      _emergencyContact = emergencyContact;
      await prefs.setString('emergency_contact', emergencyContact);
    }
    if (guardianRelation != null) {
      _guardianRelation = guardianRelation;
      await prefs.setString('guardian_relation', guardianRelation);
    }
    if (secondaryContactName != null) {
      _secondaryContactName = secondaryContactName;
      await prefs.setString('secondary_contact_name', secondaryContactName);
    }
    if (secondaryContact != null) {
      _secondaryContact = secondaryContact;
      await prefs.setString('secondary_contact', secondaryContact);
    }
    if (secondaryRelation != null) {
      _secondaryRelation = secondaryRelation;
      await prefs.setString('secondary_relation', secondaryRelation);
    }
    if (medicalConditions != null) {
      _medicalConditions = medicalConditions;
      await prefs.setString('medical_conditions', medicalConditions);
    }
    if (allergies != null) {
      _allergies = allergies;
      await prefs.setString('allergies', allergies);
    }
    if (organDonor != null) {
      _organDonor = organDonor;
      await prefs.setBool('organ_donor', organDonor);
    }
    if (volunteerMode != null) {
      _volunteerMode = volunteerMode;
      await prefs.setBool('volunteer_mode', volunteerMode);
    }
    if (trainingLevel != null) {
      _trainingLevel = trainingLevel;
      await prefs.setString('training_level', trainingLevel);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _isFirstLaunch = true;
    _userPhone = '';
    _userName = '';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }
}
