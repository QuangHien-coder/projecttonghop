import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/transaction_repository.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import '../models/category.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import '../utils/formatters.dart';

// Man hinh chinh (Home): Stateful vi co load du lieu va reload khi them sua xoa
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = TransactionRepository();
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Ham load du lieu tu repo
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _repository.getAll();

    // Sap xep ngay moi nhat len dau
    data.sort((a, b) => b.date.compareTo(a.date));

    if (!mounted) return;
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome = _repository.calculateTotalIncome(_transactions);
    final totalExpense = _repository.calculateTotalExpense(_transactions);
    final balance = totalIncome - totalExpense;
    // Lay toi da 5 giao dich gan nhat
    final recentTransactions = _transactions.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý chi tiêu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.pushNamed('search'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                children: [
                  // The tong quan so du
                  SummaryCard(
                    balance: balance,
                    totalIncome: totalIncome,
                    totalExpense: totalExpense,
                  ),

                  // Phan thong ke don gian theo danh muc
                  _buildCategorySpending(totalExpense),

                  // Tieu de 5 giao dich gan day
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Gần đây',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => context.goNamed('transactions'),
                          child: const Text('Tất cả'),
                        ),
                      ],
                    ),
                  ),

                  if (recentTransactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('Chưa có giao dịch')),
                    )
                  else
                    ...recentTransactions.map((tx) {
                      return TransactionTile(
                        transaction: tx,
                        onTap: () async {
                          final needReload = await context.pushNamed<bool>(
                            'transaction-detail',
                            pathParameters: {'id': tx.id},
                          );
                          if (needReload == true) _loadData();
                        },
                      );
                    }),

                  const SizedBox(height: 70),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final needReload = await context.pushNamed<bool>('transaction-add');
          if (needReload == true) _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Ham thong ke chi tieu theo danh muc
  Widget _buildCategorySpending(double totalExpense) {
    if (totalExpense <= 0) return const SizedBox.shrink();

    // Gom tien chi theo tung danh muc
    final Map<Category, double> map = {};
    for (var tx in _transactions) {
      if (tx.type == TransactionType.expense) {
        map[tx.category] = (map[tx.category] ?? 0.0) + tx.amount;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê chi tiêu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...map.entries.map((entry) {
              final ratio = entry.value / totalExpense;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key.label),
                        Text(entry.value.toVnd()),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: ratio,
                      color: entry.key.color,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
