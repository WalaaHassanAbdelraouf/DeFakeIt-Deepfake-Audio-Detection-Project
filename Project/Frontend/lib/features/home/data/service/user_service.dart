import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final ValueNotifier<String?> usernameNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> emailNotifier = ValueNotifier<String?>(null);

  Future<void> loadUserData() async {
    final username = await _storage.read(key: 'username');
    final email = await _storage.read(key: 'email');

    usernameNotifier.value = username;
    emailNotifier.value = email;
  }

  Future<void> updateUserData(String username, String email) async {
    await Future.wait([
      _storage.write(key: 'username', value: username),
      _storage.write(key: 'email', value: email),
    ]);
    usernameNotifier.value = username;
    emailNotifier.value = email;
  }

  Future<void> setUser(
      {required String username, required String email}) async {
    await Future.wait([
      _storage.write(key: 'username', value: username),
      _storage.write(key: 'email', value: email),
    ]);
    usernameNotifier.value = username;
    emailNotifier.value = email;
  }

  void dispose() {
    usernameNotifier.dispose();
    emailNotifier.dispose();
  }
}
