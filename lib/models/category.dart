import 'package:flutter/material.dart';

// Danh muc chi tieu / thu nhap - dung mau co san trong Flutter cho don gian
enum Category {
  food('Ăn uống', Icons.restaurant, Colors.red),
  transport('Đi lại', Icons.directions_car, Colors.blue),
  salary('Tiền lương', Icons.account_balance_wallet, Colors.green),
  bills('Hóa đơn', Icons.receipt_long, Colors.orange),
  entertainment('Giải trí', Icons.movie, Colors.purple),
  education('Học tập', Icons.menu_book, Colors.teal),
  other('Khác', Icons.category, Colors.grey);

  final String label;
  final IconData icon;
  final Color color;

  const Category(this.label, this.icon, this.color);
}
