import 'dart:convert';
import 'package:mobile/core/network/base_client.dart';
import 'package:mobile/core/constants/api_constants.dart';
import '../data/models/organization_model.dart';

class OrganizationService {
  // Ambil list workspace + tier info
  static Future<Map<String, dynamic>?> fetchAll() async {
    final response = await BaseClient.get(ApiConstants.organizations);
    if (response != null && response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // Ambil detail saldo & chart terbaru
  static Future<OrganizationModel?> getDetail(String orgId) async {
    final response = await BaseClient.get(
      "${ApiConstants.organizations}/$orgId",
    );
    if (response != null && response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return OrganizationModel.fromJson(data);
    }
    return null;
  }

  // Create workspace baru
  static Future<Map<String, dynamic>?> create(String name) async {
    final response = await BaseClient.post(ApiConstants.organizations, {
      "name": name,
    });
    if (response != null) {
      return {
        "success": response.statusCode == 200,
        "message": jsonDecode(response.body)['message'],
      };
    }
    return null;
  }
}
