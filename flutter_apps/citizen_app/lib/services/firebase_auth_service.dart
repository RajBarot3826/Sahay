import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> authenticate(String phone, String password) async {
    try {
      // For hackathon/prototype purposes, we use Anonymous Auth 
      // but tie it to the provided phone number in Firestore.
      // This skips the complex SMS verification steps for quick testing.
      UserCredential userCredential = await _auth.signInAnonymously();
      
      if (userCredential.user != null) {
        // Save user profile in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'phoneNumber': phone,
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'citizen',
          'status': 'active',
        }, SetOptions(merge: true));
        return true;
      }
      return false;
    } catch (e) {
      print("Firebase Login Error: $e");
      return false;
    }
  }
}
