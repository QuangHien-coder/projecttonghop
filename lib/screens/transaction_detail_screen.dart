import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/transaction_repository.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import '../utils/formatters.dart';

// Man chi tiet: Stateful vi co load du lieu theo id truyen tu duong dan
class TransactionDetailScreen extends StatefulWidget {
  final String id;
  final Transaction? initialTransaction;

  const TransactionDetailScreen({
    super.key,
    required this.id,
    this.initialTransaction,
  });

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final _repository = TransactionRepository();
  Transaction? _transaction;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Neu co truyen qua extra thi dung luon, khong thi moi goi repo tim
    if (widget.initialTransaction != null) {
      _transaction = widget.initialTransaction;
      _isLoading = false;
    } else {
      _loadDetail();
    }
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    final item = await _repository.getById(widget.id);
    if (!mounted) return; // check mounted cho chac
    setState(() {
      _transaction = item;
      _isLoading = false;
    });
  }

  Future<void> _deleteTransaction() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa giao dịch này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await _repository.delete(widget.id);
    if (!mounted) return;
    // Xoa xong thi pop ve va bao true de man truoc load lai
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Neu khong tim thay id thi bao loi khong bi crash
    if (_transaction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.orange),
              const SizedBox(height: 12),
              const Text('Không tìm thấy giao dịch!'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    final tx = _transaction!;
    final isIncome = tx.type == TransactionType.income;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết giao dịch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await context.pushNamed<bool>(
                'transaction-edit',
                pathParameters: {'id': tx.id},
                extra: tx,
              );
              if (updated == true) {
                _loadDetail();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteTransaction,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header dung Container don gian hien thi so tien va icon
          Container(
            padding: const EdgeInsets.all(20),
            color: isIncome ? Colors.green.shade50 : Colors.red.shade50,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: tx.category.color,
                  child: Icon(tx.category.icon, size: 30, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  '${isIncome ? '+' : '-'} ${tx.amount.toVnd()}',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tx.type.label,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Cac thong tin ben duoi
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.title),
                  title: const Text('Tiêu đề'),
                  trailing: Text(
                    tx.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Danh mục'),
                  trailing: Text(tx.category.label),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Ngày'),
                  trailing: Text(tx.date.toDmy()),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.note),
                  title: const Text('Ghi chú'),
                  subtitle: Text(tx.note ?? '(Không có ghi chú)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
