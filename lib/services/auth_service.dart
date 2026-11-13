import 'package:flutter/foundation.dart';

// Service quan ly dang nhap gia lap, ke thua ChangeNotifier de lam refreshListenable cho GoRouter
class AuthService extends ChangeNotifier {
  // Singleton dung chung
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isLoggedIn = false;
  String _username = '';

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;

  // Dang nhap
  Future<bool> login(String user, String pass) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Gia lap: chi can nhap username la cho vao
    if (user.trim().isNotEmpty) {
      _isLoggedIn = true;
      _username = user.trim();
      notifyListeners(); // Bao cho GoRouter biet de chay redirect
      return true;
    }
    return false;
  }

  // Dang xuat
  void logout() {
    _isLoggedIn = false;
    _username = '';
    notifyListeners(); // Bao cho GoRouter quay ve /login
  }
}

