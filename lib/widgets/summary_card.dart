import 'package:flutter/material.dart';
import '../utils/formatters.dart';

// Widget hien thi the tong quan so du
// Man nay Stateless vi chi nhan du lieu vao de ve len man hinh
class SummaryCard extends StatelessWidget {
  final double balance;
  final double totalIncome;
  final double totalExpense;

  const SummaryCard({
    super.key,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.blue.shade700,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Số dư hiện tại',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              balance.toVnd(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white30),
            const SizedBox(height: 8),
            Row(
              children: [
                // Ben trai: Tong thu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thu nhập (+)',
                        style: TextStyle(color: Colors.greenAccent, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalIncome.toVnd(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Ben phai: Tong chi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chi tiêu (-)',
                        style: TextStyle(color: Colors.redAccent, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalExpense.toVnd(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
