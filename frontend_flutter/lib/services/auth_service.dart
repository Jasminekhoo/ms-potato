class AuthService {
  Future<bool> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return email.isNotEmpty && password.isNotEmpty;
  }

  Future<bool> signup(String email, String password, String name) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return email.isNotEmpty && password.isNotEmpty && name.isNotEmpty;
  }

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}
