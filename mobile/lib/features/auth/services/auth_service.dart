import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthService extends GetxService {
  final _storage = GetStorage();
  final _token = RxnString(); // Pakai Rx supaya bisa dipantau perubahannya

  String? get token => _token.value;

  Future<AuthService> init() async {
    // Saat aplikasi nyala, langsung baca token yang tersimpan
    _token.value = _storage.read('token');
    return this;
  }

  Future<void> saveAuth(String newToken, dynamic userData) async {
    _token.value = newToken;
    await _storage.write('token', newToken);
    await _storage.write('user', userData);
  }

  Future<void> clearAuth() async {
    _token.value = null;
    await _storage.erase();
  }

  bool get isLoggedIn => _token.value != null;
}
