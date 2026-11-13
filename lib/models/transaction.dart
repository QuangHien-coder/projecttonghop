import 'transaction_type.dart';
import 'category.dart';

// Model giao dich - dung final de dam bao bat bien (immutable)
class Transaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final Category category;
  final DateTime date;
  final String? note; // co the null neu khong nhap ghi chu

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  // Getter tra ve so tien co dau: + neu la thu nhap, - neu la chi tieu
  double get signedAmount {
    if (type == TransactionType.income) {
      return amount;
    }
    return -amount;
  }

  // Ham copyWith giup tao ban sao khi sua ma khong thay doi truc tiep doi tuong cu
  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    Category? category,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}

