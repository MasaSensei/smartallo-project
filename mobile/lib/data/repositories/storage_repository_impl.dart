// lib/app/data/repositories_impl/storage_repository_impl.dart
import 'package:get/get.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import '../../domain/repositories/storage_repository.dart';
import '../models/storage_model.dart';

class StorageRepositoryImpl extends GetConnect implements StorageRepository {
  final _auth = Get.find<AuthService>();

  @override
  void onInit() {
    httpClient.baseUrl = ApiConstants.baseUrl;

    httpClient.addRequestModifier<dynamic>((request) {
      if (_auth.token != null) {
        request.headers['Authorization'] = 'Bearer ${_auth.token}';
      }
      return request;
    });

    super.onInit();
  }

  String _cleanPath(String fullUrl) =>
      fullUrl.replaceAll(ApiConstants.baseUrl, "");

  @override
  Future<List<StorageModel>> getByOrg(String orgId) async {
    // Pakai ApiConstants.storages
    final res = await get("${_cleanPath(ApiConstants.storages)}?org_id=$orgId");

    if (res.isOk) {
      final List data = res.body['data'] ?? [];
      return data.map((e) => StorageModel.fromJson(e)).toList();
    }
    throw res.body?['error'] ?? "Gagal mengambil data storage";
  }

  @override
  Future<StorageModel> create(StorageModel storage) async {
    final res = await post(_cleanPath(ApiConstants.storages), storage.toJson());
    if (res.isOk)
      return StorageModel.fromJson(
        res.body['data'],
      ); // Biasanya response Go lo ada wrap 'data'
    throw res.body?['error'] ?? "Gagal membuat storage";
  }

  @override
  Future<StorageModel> update(String id, StorageModel storage) async {
    final res = await put(
      "${_cleanPath(ApiConstants.storages)}/$id",
      storage.toJson(),
    );
    if (res.isOk) return StorageModel.fromJson(res.body['data']);
    throw res.body?['error'] ?? "Gagal update storage";
  }

  // GANTI NAMA METHOD BIAR GAK BENTROK
  @override
  Future<bool> deleteStorage(String id) async {
    final res = await delete("${_cleanPath(ApiConstants.storages)}/$id");
    return res.isOk;
  }
}
