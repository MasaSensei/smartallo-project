import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthService extends GetxService {
  final _storage = GetStorage('SmartAlloAuth');
  final _token = RxnString();

  String? get token => _token.value;

  Future<AuthService> init() async {
    // Inisialisasi storage spesifik ini
    await GetStorage.init('SmartAlloAuth');
    _token.value = _storage.read('token');
    print("DEBUG AUTH: Membaca token dari SmartAlloAuth -> ${_token.value}");
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
