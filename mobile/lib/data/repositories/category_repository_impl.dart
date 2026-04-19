import 'package:get/get.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl extends GetConnect implements CategoryRepository {
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
  Future<List<CategoryModel>> getByOrg(String orgId) async {
    final res = await get("${_p(ApiConstants.categories)}?org_id=$orgId");
    if (res.isOk) {
      final List data = res.body['data'] ?? [];
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    }
    throw res.body?['message'] ?? "Gagal mengambil data kategori";
  }

  @override
  Future<CategoryModel> create(CategoryModel category) async {
    final res = await post(_p(ApiConstants.categories), {
      "org_id": category.orgId,
      "name": category.name,
      "type": category.type,
    });
    if (res.isOk) return CategoryModel.fromJson(res.body['data']);
    throw res.body?['message'] ?? "Gagal membuat kategori";
  }

  @override
  Future<CategoryModel> update(String id, CategoryModel category) async {
    final res = await put("${_p(ApiConstants.categories)}/$id", {
      "name": category.name,
      "type": category.type,
    });
    if (res.isOk) return CategoryModel.fromJson(res.body['data']);
    throw res.body?['message'] ?? "Gagal update kategori";
  }

  @override
  Future<bool> deleteCategory(String id) async {
    final res = await delete("${_p(ApiConstants.categories)}/$id");
    return res.isOk;
  }
}
