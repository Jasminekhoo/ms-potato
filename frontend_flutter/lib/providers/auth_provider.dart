import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  bool isAuthenticated = false;

  Future<bool> login(String email, String password) async {
    final ok = await _authService.login(email, password);
    isAuthenticated = ok;
    notifyListeners();
    return ok;
  }

  Future<void> logout() async {
    await _authService.logout();
    isAuthenticated = false;
    notifyListeners();
  }
}
