import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AmountText extends StatelessWidget {
  final double amount;
  final TextStyle style;

  const AmountText(this.amount, {super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return Text(currencyFormat.format(amount), style: style);
  }
}
