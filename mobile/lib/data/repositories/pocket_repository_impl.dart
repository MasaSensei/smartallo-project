import 'package:get/get.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import '../../domain/repositories/pocket_repository.dart';
import '../models/pocket_model.dart';

class PocketRepositoryImpl extends GetConnect implements PocketRepository {
  final _auth = Get.find<AuthService>();

  @override
  void onInit() {
    httpClient.baseUrl = ApiConstants.baseUrl;
    httpClient.addRequestModifier<dynamic>((request) {
      if (_auth.token != null)
        request.headers['Authorization'] = 'Bearer ${_auth.token}';
      return request;
    });
    super.onInit();
  }

  String _p(String url) => url.replaceAll(ApiConstants.baseUrl, "");

  @override
  Future<List<PocketModel>> getByOrg(String orgId) async {
    final res = await get("${_p(ApiConstants.pockets)}?org_id=$orgId");
    if (res.isOk) {
      final List data = res.body['data'] ?? [];
      return data.map((e) => PocketModel.fromJson(e)).toList();
    }
    throw res.body?['message'] ?? "Gagal mengambil data pocket";
  }

  @override
  Future<PocketModel> create(PocketModel pocket) async {
    final res = await post(_p(ApiConstants.pockets), {
      "org_id": pocket.orgId,
      "name": pocket.name,
      "balance": pocket.balance,
      "color": pocket.color,
    });
    if (res.isOk) return PocketModel.fromJson(res.body['data']);
    throw res.body?['message'] ?? "Gagal membuat pocket";
  }

  @override
  Future<PocketModel> update(String id, PocketModel pocket) async {
    final res = await put("${_p(ApiConstants.pockets)}/$id", {
      "name": pocket.name,
      "balance": pocket.balance,
      "color": pocket.color,
    });
    if (res.isOk) return PocketModel.fromJson(res.body['data']);
    throw res.body?['message'] ?? "Gagal update pocket";
  }

  @override
  Future<bool> deletePocket(String id) async {
    final res = await delete("${_p(ApiConstants.pockets)}/$id");
    return res.isOk;
  }
}
