import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import '../utils/formatters.dart';

// Widget StatelessWidget vi chi nhan 1 transaction va callback onTap de hien thi
class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? Colors.green.shade700 : Colors.red.shade700;
    final sign = isIncome ? '+' : '-';

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: transaction.category.color.withValues(alpha: 0.2),
        child: Icon(
          transaction.category.icon,
          color: transaction.category.color,
          size: 22,
        ),
      ),
      title: Text(
        transaction.title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        '${transaction.category.label} • ${transaction.date.toDmy()}',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      trailing: Text(
        '$sign ${transaction.amount.toVnd()}',
        style: TextStyle(
          color: amountColor,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}

