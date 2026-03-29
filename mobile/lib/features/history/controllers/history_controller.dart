import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/constants/api_constants.dart';

class HistoryController extends GetxController {
  final _connect = GetConnect();
  final _storage = GetStorage();

  var isLoading = false.obs;
  var rxTransactions = <dynamic>[].obs;

  // Observable Map untuk grouping: {"2026-03-29": [...], "2026-03-28": [...]}
  var groupedTransactions = <String, List<dynamic>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFullHistory();
  }

  Map<String, String> get _headers => {
    'Authorization': 'Bearer ${_storage.read('token')}',
  };

  Future<void> fetchFullHistory() async {
    isLoading.value = true;
    final orgId = _storage.read(
      'active_org_id',
    ); // Pastikan key storage sinkron

    try {
      final response = await _connect.get(
        "${ApiConstants.transactionHistory}?org_id=$orgId",
        headers: _headers,
      );

      if (response.status.isOk) {
        final List<dynamic> data = response.body['data'] ?? [];
        rxTransactions.assignAll(data);
        _groupTransactions(data); // Kelompokkan data setelah fetch
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _groupTransactions(List<dynamic> data) {
    Map<String, List<dynamic>> tempGroup = {};
    for (var tx in data) {
      // Asumsi API kirim 'created_at' atau 'date'
      DateTime date = DateTime.parse(tx['created_at'] ?? tx['date']);
      String dateStr = DateFormat('yyyy-MM-dd').format(date);

      if (tempGroup[dateStr] == null) tempGroup[dateStr] = [];
      tempGroup[dateStr]!.add(tx);
    }
    groupedTransactions.value = tempGroup;
  }
}
