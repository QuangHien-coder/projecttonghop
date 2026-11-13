import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/transaction_repository.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import '../widgets/transaction_tile.dart';
import '../utils/formatters.dart';

// Enum 4 trang thai giao dien theo yeu cau de bai
enum LoadStatus { loading, error, empty, success }

// Widget StatefulWidget vi quan ly 4 trang thai tai du lieu va loc theo query param
class TransactionListScreen extends StatefulWidget {
  final String? typeFilter;

  const TransactionListScreen({super.key, this.typeFilter});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final _repository = TransactionRepository();
  LoadStatus _status = LoadStatus.loading;
  String _errorMessage = '';
  List<Transaction> _allTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void didUpdateWidget(covariant TransactionListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Khi query param ?type= thay doi, setState lai de loc
    if (oldWidget.typeFilter != widget.typeFilter) {
      _applyFilter();
    }
  }

  Future<void> _loadTransactions() async {
    setState(() => _status = LoadStatus.loading);
    try {
      final data = await _repository.getAll();
      data.sort((a, b) => b.date.compareTo(a.date));

      if (!mounted) return;
      _allTransactions = data;
      _applyFilter();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = LoadStatus.error;
        _errorMessage = e.toString();
      });
    }
  }

  void _applyFilter() {
    final filtered = _getFilteredList();
    setState(() {
      if (filtered.isEmpty) {
        _status = LoadStatus.empty;
      } else {
        _status = LoadStatus.success;
      }
    });
  }

  List<Transaction> _getFilteredList() {
    if (widget.typeFilter == 'income') {
      return _allTransactions.where((t) => t.type == TransactionType.income).toList();
    } else if (widget.typeFilter == 'expense') {
      return _allTransactions.where((t) => t.type == TransactionType.expense).toList();
    }
    return _allTransactions;
  }

  // Xoa giao dich co AlertDialog xac nhan va SnackBar hoan tac
  Future<void> _confirmDelete(Transaction tx) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa "${tx.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // Luu lai ban backup de hoan tac
    final deletedTx = tx;
    await _repository.delete(tx.id);
    await _loadTransactions();

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa "${deletedTx.title}"'),
        action: SnackBarAction(
          label: 'HOÀN TÁC',
          onPressed: () async {
            await _repository.add(deletedTx);
            _loadTransactions();
          },
        ),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return 'Hôm nay';
    if (checkDate == yesterday) return 'Hôm qua';
    return date.toDmy();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách giao dịch', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.pushNamed('search'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh chip loc theo query parameter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: widget.typeFilter == null || widget.typeFilter!.isEmpty,
                  onSelected: (val) {
                    if (val) context.go('/transactions');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Thu nhập'),
                  selected: widget.typeFilter == 'income',
                  selectedColor: Colors.green.shade100,
                  onSelected: (val) {
                    if (val) context.go('/transactions?type=income');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Chi tiêu'),
                  selected: widget.typeFilter == 'expense',
                  selectedColor: Colors.red.shade100,
                  onSelected: (val) {
                    if (val) context.go('/transactions?type=expense');
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Hien thi 4 trang thai
          Expanded(
            child: _buildBodyByStatus(filtered),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final needReload = await context.pushNamed<bool>('transaction-add');
          if (needReload == true) _loadTransactions();
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm giao dịch'),
      ),
    );
  }

  Widget _buildBodyByStatus(List<Transaction> items) {
    switch (_status) {
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case LoadStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 54, color: Colors.red),
              const SizedBox(height: 12),
              Text('Đã xảy ra lỗi: $_errorMessage', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadTransactions,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        );

      case LoadStatus.empty:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text('Chưa có giao dịch nào phù hợp', style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.go('/transactions'),
                child: const Text('Bỏ lọc'),
              ),
            ],
          ),
        );

      case LoadStatus.success:
        final grouped = _repository.groupByDate(items);
        final dateKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

        return RefreshIndicator(
          onRefresh: _loadTransactions,
          child: ListView.builder(
            itemCount: dateKeys.length,
            itemBuilder: (context, dateIndex) {
              final dateKey = dateKeys[dateIndex];
              final txList = grouped[dateKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.grey.shade100,
                    child: Text(
                      _formatDateHeader(dateKey),
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                    ),
                  ),
                  ...txList.map((tx) {
                    return Dismissible(
                      key: Key(tx.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        await _confirmDelete(tx);
                        return false; // De UI cap nhat qua repository chu khong dismiss tu do
                      },
                      child: TransactionTile(
                        transaction: tx,
                        onTap: () async {
                          final needReload = await context.pushNamed<bool>(
                            'transaction-detail',
                            pathParameters: {'id': tx.id},
                          );
                          if (needReload == true) _loadTransactions();
                        },
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        );
    }
  }
}

