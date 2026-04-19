import '../entities/user.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<bool> register(String name, String email, String password);
}
