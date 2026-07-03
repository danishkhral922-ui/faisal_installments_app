import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isAdmin = false;
  String _currentEmail = '';
  String _currentName = '';

  bool get isAuthenticated => _user != null;
  bool get isAdmin => _isAdmin;
  String get currentEmail => _currentEmail;
  String get currentName => _currentName;

  Future<void> initialize() async {
    _user = _auth.currentUser;

    if (_user == null) {
      _isAdmin = false;
      _currentEmail = '';
      _currentName = '';
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      return;
    }

    _currentEmail = _user!.email ?? '';

    final adminDoc = await _firestore
        .collection('admins')
        .doc(_user!.uid)
        .get();

    _isAdmin = adminDoc.exists;
    _currentName = (adminDoc.data()?['name'] ?? '') as String;

    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = cred.user;
    if (user == null) {
      throw Exception('Sign up failed');
    }

    await _firestore.collection('admins').doc(user.uid).set({
      'name': name.trim(),
      'email': email.trim(),
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    });

    _user = user;
    _isAdmin = true;
    _currentEmail = user.email ?? '';
    _currentName = name.trim();
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = cred.user;
    if (user == null) {
      throw Exception('Sign in failed');
    }

    _user = user;
    _currentEmail = user.email ?? '';

    final adminDoc = await _firestore.collection('admins').doc(user.uid).get();
    _isAdmin = adminDoc.exists;
    _currentName = (adminDoc.data()?['name'] ?? '') as String;

    notifyListeners();

    if (!_isAdmin) {
      throw Exception('Not an admin account');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _isAdmin = false;
    _currentEmail = '';
    _currentName = '';
    notifyListeners();
  }
}
