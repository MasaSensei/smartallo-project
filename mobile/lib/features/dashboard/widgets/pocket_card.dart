import 'package:flutter/material.dart';
import '../../../../core/widgets/amount_text.dart';

class PocketCard extends StatelessWidget {
  final Map<String, dynamic> pocket;

  const PocketCard({super.key, required this.pocket});

  @override
  Widget build(BuildContext context) {
    double progress = pocket['balance'] / pocket['target'];
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [pocket['color'], pocket['color'].withOpacity(0.7)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            pocket['name'],
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          AmountText(
            pocket['balance'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${(progress * 100).toInt()}% dari target",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 6,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
