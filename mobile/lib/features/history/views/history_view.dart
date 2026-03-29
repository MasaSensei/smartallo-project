import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/amount_text.dart';
import 'package:mobile/features/history/controllers/history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text(
          "Transaction History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildCalendarStrip(), // Kalender Horizontal di atas
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value)
                return const Center(child: CircularProgressIndicator());
              if (controller.groupedTransactions.isEmpty)
                return const Center(
                  child: Text(
                    "Belum ada transaksi",
                    style: TextStyle(color: Colors.white38),
                  ),
                );

              final dates = controller.groupedTransactions.keys.toList();

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  String dateKey = dates[index];
                  List<dynamic> txs = controller.groupedTransactions[dateKey]!;
                  return _buildDateSection(dateKey, txs);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: HORIZONTAL CALENDAR STRIP ---
  Widget _buildCalendarStrip() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 14, // Tampilkan 14 hari terakhir
        itemBuilder: (context, i) {
          DateTime date = DateTime.now().subtract(Duration(days: i));
          bool isToday = i == 0;
          return Container(
            width: 60,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color:
                  isToday ? AppTheme.primary : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isToday ? AppTheme.primary : Colors.white10,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('EEE').format(date),
                  style: TextStyle(
                    color: isToday ? Colors.white : Colors.white38,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date.day.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET: DATE GROUP SECTION ---
  Widget _buildDateSection(String dateKey, List<dynamic> txs) {
    DateTime date = DateTime.parse(dateKey);
    String label = _getDateLabel(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...txs.map((tx) => _buildTransactionTile(tx)).toList(),
      ],
    );
  }

  Widget _buildTransactionTile(dynamic tx) {
    bool isIncoming = tx['type'] == 'IN';
    double amount = double.tryParse(tx['total_amount'].toString()) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // 1. Icon Indicator (Tetap)
          CircleAvatar(
            backgroundColor:
                isIncoming
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
            child: Icon(
              isIncoming ? Icons.add_rounded : Icons.remove_rounded,
              color: isIncoming ? Colors.greenAccent : Colors.redAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12), // Kurangi sedikit gap agar lega
          // 2. Info Deskripsi & Kantong (Flexible)
          Expanded(
            flex: 3, // Memberi proporsi lebih besar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['description'] ?? "No Description",
                  maxLines: 1, // Batasi agar tidak berantakan
                  overflow:
                      TextOverflow
                          .ellipsis, // Tambahkan titik-titik jika kepanjangan
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                // Gunakan Wrap atau SingleChildScrollView kecil agar tag tidak overflow
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tx['source_pocket_name'] ?? "Pocket",
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "• ${tx['category_name'] ?? 'General'}",
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 3. Jumlah Uang (Flexible / Constrained)
          Expanded(
            flex: 2, // Memberi ruang khusus untuk angka
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  // PENTING: Mengecilkan teks otomatis jika angka terlalu panjang
                  fit: BoxFit.scaleDown,
                  child: AmountText(
                    amount,
                    style: TextStyle(
                      color: isIncoming ? Colors.greenAccent : Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  isIncoming ? "Income" : "Expense",
                  style: TextStyle(
                    color:
                        isIncoming
                            ? Colors.green.withOpacity(0.5)
                            : Colors.red.withOpacity(0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day)
      return "Today";
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1)
      return "Yesterday";
    return DateFormat('EEEE, dd MMM').format(date);
  }
}
