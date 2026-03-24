import 'package:get/get.dart';
import 'package:mobile/core/theme/app_theme.dart';

class DashboardController extends GetxController {
  final rxPockets = <Map<String, dynamic>>[].obs;
  final rxTransactions = <Map<String, dynamic>>[].obs;
  final rxTotalBalance = 0.0.obs;
  final rxUserName = "Masayoshi".obs;
  final rxUserTier = "FREE".obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    rxPockets.assignAll([
      {
        "name": "Tabungan Nikah",
        "balance": 15000000.0,
        "target": 50000000.0,
        "color": AppTheme.primary,
      },
      {
        "name": "Dana Darurat",
        "balance": 5000000.0,
        "target": 10000000.0,
        "color": AppTheme.success,
      },
    ]);

    rxTransactions.assignAll([
      {"title": "Kopi Pagi", "amount": 25000.0, "type": "OUT", "date": "Today"},
      {
        "title": "Project Freelance",
        "amount": 2000000.0,
        "type": "IN",
        "date": "Yesterday",
      },
    ]);

    _calculateTotal();
  }

  void _calculateTotal() {
    rxTotalBalance.value = rxPockets.fold(
      0,
      (sum, item) => sum + item['balance'],
    );
  }
}
