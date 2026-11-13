import 'package:flutter_test/flutter_test.dart';
import 'package:projecttonghop/models/transaction.dart';
import 'package:projecttonghop/models/transaction_type.dart';
import 'package:projecttonghop/models/category.dart';
import 'package:projecttonghop/utils/formatters.dart';
import 'package:projecttonghop/data/transaction_repository.dart';

void main() {
  group('Unit Test: Model & Extension & Repository', () {
    test('Kiem tra copyWith va signedAmount cua Transaction', () {
      final tx = Transaction(
        id: '1',
        title: 'Ăn sáng',
        amount: 30000,
        type: TransactionType.expense,
        category: Category.food,
        date: DateTime(2026, 11, 13),
      );

      // Kiem tra signedAmount cua chi tieu phai la so am
      expect(tx.signedAmount, -30000);

      // Kiem tra copyWith doi sang thu nhap
      final updated = tx.copyWith(type: TransactionType.income, amount: 50000);
      expect(updated.title, 'Ăn sáng');
      expect(updated.amount, 50000);
      expect(updated.signedAmount, 50000);
    });

    test('Kiem tra extension toVnd va toDmy tu viet', () {
      const double money = 1500000;
      expect(money.toVnd(), '1.500.000 ₫');

      final date = DateTime(2026, 5, 9);
      expect(date.toDmy(), '09/05/2026');
    });

    test('Kiem tra tinh tong thu, tong chi va so du', () {
      final repo = TransactionRepository();
      final list = [
        Transaction(
          id: '1',
          title: 'Lương',
          amount: 10000000,
          type: TransactionType.income,
          category: Category.salary,
          date: DateTime.now(),
        ),
        Transaction(
          id: '2',
          title: 'Tiền nhà',
          amount: 3000000,
          type: TransactionType.expense,
          category: Category.bills,
          date: DateTime.now(),
        ),
      ];

      expect(repo.calculateTotalIncome(list), 10000000);
      expect(repo.calculateTotalExpense(list), 3000000);
      expect(repo.calculateBalance(list), 7000000);
    });
  });
}
