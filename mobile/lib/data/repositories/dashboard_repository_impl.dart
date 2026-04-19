import 'package:get/get.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/auth/services/auth_service.dart'; // Import AuthService
import '../../domain/repositories/dashboard_repository.dart';
import '../models/pocket_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class DashboardRepositoryImpl extends GetConnect
    implements DashboardRepository {
  // Ambil instance AuthService untuk Token
  final _auth = Get.find<AuthService>();

  @override
  void onInit() {
    // 1. Set Base URL
    httpClient.baseUrl = ApiConstants.baseUrl;
    httpClient.timeout = const Duration(seconds: 10);

    // 2. Request Modifier: Sisipkan Token & Header
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/json';

      if (_auth.token != null) {
        request.headers['Authorization'] = 'Bearer ${_auth.token}';
      }

      print("🚀 Dashboard Request: ${request.url}");
      return request;
    });

    // 3. Response Modifier: Handle Kick 401
    httpClient.addResponseModifier((request, response) {
      if (response.statusCode == 401) {
        _auth.clearAuth();
        Get.offAllNamed('/login');
      }
      return response;
    });

    super.onInit();
  }

  /// Helper biar URL gak tumpuk (http://localhost...http://localhost...)
  String _cleanPath(String fullUrl) {
    return fullUrl.replaceAll(ApiConstants.baseUrl, "");
  }

  @override
  Future<List<PocketModel>> getPockets() async {
    final res = await get(_cleanPath(ApiConstants.pockets));
    if (res.isOk) {
      return (res.body['data'] as List)
          .map((e) => PocketModel.fromJson(e))
          .toList();
    }
    throw res.body?['error'] ?? "Gagal memuat Pockets";
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final res = await get(_cleanPath(ApiConstants.categories));
    if (res.isOk) {
      return (res.body['data'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    }
    throw res.body?['error'] ?? "Gagal memuat Kategori";
  }

  @override
  Future<List<TransactionModel>> getHistory({int limit = 10}) async {
    // Gabungin clean path dengan query parameter
    final path = "${_cleanPath(ApiConstants.transactions)}?limit=$limit";
    final res = await get(path);

    if (res.isOk) {
      return (res.body['data'] as List)
          .map((e) => TransactionModel.fromJson(e))
          .toList();
    }
    throw res.body?['error'] ?? "Gagal mengambil riwayat transaksi";
  }

  @override
  Future<bool> createTransaction(TransactionModel tx) async {
    final res = await post(_cleanPath(ApiConstants.transactions), tx.toJson());

    if (res.isOk) return true;
    throw res.body?['error'] ?? "Gagal membuat transaksi";
  }

  @override
  Future<bool> deleteTransaction(String id) async {
    final path = "${_cleanPath(ApiConstants.transactions)}/$id";
    final res = await delete(path);

    if (res.isOk) return true;
    throw res.body?['error'] ?? "Gagal menghapus transaksi";
  }
}
