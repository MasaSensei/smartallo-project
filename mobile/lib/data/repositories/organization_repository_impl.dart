import 'package:get/get.dart';
import 'package:mobile/data/models/organization_model.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import '../../domain/repositories/organization_repository.dart';
import '../../../core/constants/api_constants.dart';

class OrganizationRepositoryImpl extends GetConnect
    implements OrganizationRepository {
  // Ambil instance AuthService untuk Token
  final _auth = Get.find<AuthService>();

  @override
  void onInit() {
    // 1. Set Base URL utama
    httpClient.baseUrl = ApiConstants.baseUrl;

    // 2. Timeout & Header Standar
    httpClient.timeout = const Duration(seconds: 10);

    // 3. Request Modifier (Satpam Token)
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/json';

      // Sisipkan Bearer Token secara otomatis
      if (_auth.token != null) {
        request.headers['Authorization'] = 'Bearer ${_auth.token}';
      }

      return request;
    });

    // 4. Response Modifier (Handle 401/Kick User)
    httpClient.addResponseModifier((request, response) {
      if (response.statusCode == 401) {
        _auth.clearAuth();
        Get.offAllNamed('/login');
      }
      return response;
    });
  }

  /// Helper untuk membersihkan URL lengkap dari ApiConstants
  /// supaya tidak double saat digabung dengan httpClient.baseUrl
  String _cleanPath(String fullUrl) {
    // Ini akan menghapus bagian "http://localhost:8080/api/v1"
    // sehingga tersisa "/organizations" saja
    return fullUrl.replaceAll(ApiConstants.baseUrl, "");
  }

  @override
  Future<List<OrganizationModel>> getAll() async {
    // Pakai _cleanPath supaya GetConnect tidak menggandakan URL
    final res = await get(_cleanPath(ApiConstants.organizations));

    if (res.isOk) {
      final List data = res.body['data'];
      return data.map((e) => OrganizationModel.fromJson(e)).toList();
    }
    throw res.body?['message'] ?? "Gagal mengambil data workspace";
  }

  @override
  Future<OrganizationModel> getDetail(String id) async {
    final path = "${_cleanPath(ApiConstants.organizations)}/$id";
    final res = await get(path);

    if (res.isOk) return OrganizationModel.fromJson(res.body['data']);
    throw res.body?['message'] ?? "Gagal mengambil detail";
  }

  @override
  Future<bool> create(String name) async {
    final res = await post(_cleanPath(ApiConstants.organizations), {
      "name": name,
    });

    if (res.isOk) return true;
    throw res.body?['message'] ?? "Gagal membuat workspace";
  }
}
