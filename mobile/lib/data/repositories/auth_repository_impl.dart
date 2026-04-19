import 'package:get/get.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/constants/api_constants.dart';

class AuthRepositoryImpl implements AuthRepository {
  final GetConnect _connect = GetConnect();

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _connect.post(ApiConstants.login, {
      "email": email,
      "password": password,
    });

    if (response.isOk) return response.body['data'];
    throw response.body?['message'] ?? "Login gagal";
  }

  @override
  Future<bool> register(String name, String email, String password) async {
    final response = await _connect.post(ApiConstants.register, {
      "username": name,
      "email": email,
      "password": password,
    });

    if (response.isOk) return true;
    throw response.body?['message'] ?? "Registrasi gagal";
  }
}
