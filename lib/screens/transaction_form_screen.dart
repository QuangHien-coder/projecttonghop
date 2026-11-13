import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/transaction_repository.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import '../models/category.dart';
import '../widgets/category_picker.dart';
import '../utils/formatters.dart';

// Man form them / sua: dung StatefulWidget vi co form nhap va can dispose controller
class TransactionFormScreen extends StatefulWidget {
  final String? id;
  final Transaction? initialTransaction;

  const TransactionFormScreen({
    super.key,
    this.id,
    this.initialTransaction,
  });

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = TransactionRepository();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late TransactionType _selectedType;
  late Category _selectedCategory;
  late DateTime _selectedDate;
  bool _isLoading = false;

  // Neu co id la sua, khong co id la them
  bool get _isEditMode => widget.id != null;

  @override
  void initState() {
    super.initState();
    final init = widget.initialTransaction;

    _titleController = TextEditingController(text: init?.title ?? '');
    _amountController = TextEditingController(
      text: init != null ? init.amount.toInt().toString() : '',
    );
    _noteController = TextEditingController(text: init?.note ?? '');

    _selectedType = init?.type ?? TransactionType.expense;
    _selectedCategory = init?.category ?? Category.food;
    _selectedDate = init?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    // BAT BUOC: Dispose controller khi thoat form de khong bi tru diem
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final amountVal = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final titleVal = _titleController.text.trim();
    final noteVal = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

    setState(() => _isLoading = true);

    try {
      if (_isEditMode) {
        final updatedTx = Transaction(
          id: widget.id!,
          title: titleVal,
          amount: amountVal,
          type: _selectedType,
          category: _selectedCategory,
          date: _selectedDate,
          note: noteVal,
        );
        await _repository.update(updatedTx);
      } else {
        // Sinh id bang timestamp
        final newTx = Transaction(
          id: 't_${DateTime.now().millisecondsSinceEpoch}',
          title: titleVal,
          amount: amountVal,
          type: _selectedType,
          category: _selectedCategory,
          date: _selectedDate,
          note: noteVal,
        );
        await _repository.add(newTx);
      }

      if (!mounted) return;
      // Tra ve true de man truoc biet can reload
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Sửa giao dịch' : 'Thêm giao dịch'),
      ),
      // Bọc SingleChildScrollView de khong bi loi tran (overflow) khi bat ban phim
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Chon Thu hoac Chi
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Chi tiêu'),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Thu nhập'),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (newSelection) {
                  setState(() => _selectedType = newSelection.first);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  hintText: 'VD: Ăn trưa, Đổ xăng...',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số tiền',
                  hintText: 'VD: 50000',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null || val <= 0) {
                    return 'Số tiền phải lớn hơn 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text('Danh mục:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CategoryPicker(
                selectedCategory: _selectedCategory,
                onSelected: (cat) => setState(() => _selectedCategory = cat),
              ),
              const SizedBox(height: 16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Ngày'),
                subtitle: Text(_selectedDate.toDmy()),
                trailing: TextButton(
                  onPressed: _pickDate,
                  child: const Text('Chọn ngày'),
                ),
              ),
              const Divider(),

              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú thêm',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTransaction,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditMode ? 'Cập nhật' : 'Lưu lại'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
