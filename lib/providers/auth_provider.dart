import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _currentUserId;
  String? _currentUserName;

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _currentUserId = prefs.getString('currentUserId');
    _currentUserName = prefs.getString('currentUserName');
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    // Simple local authentication - in production, use proper auth service
    if (email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = true;
      _currentUserId = DateTime.now().millisecondsSinceEpoch.toString();
      _currentUserName = email.split('@')[0];
      
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('currentUserId', _currentUserId!);
      await prefs.setString('currentUserName', _currentUserName!);
      
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signUp(String name, String email, String password) async {
    // Simple local registration - in production, use proper auth service
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = true;
      _currentUserId = DateTime.now().millisecondsSinceEpoch.toString();
      _currentUserName = name;
      
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('currentUserId', _currentUserId!);
      await prefs.setString('currentUserName', _currentUserName!);
      
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = false;
    _currentUserId = null;
    _currentUserName = null;
    
    await prefs.clear();
    notifyListeners();
  }
}
