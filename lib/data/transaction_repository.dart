import '../models/transaction.dart';
import '../models/transaction_type.dart';
import '../models/category.dart';

// Repository quan ly du lieu giao dich trong bo nho (gia lap database / API)
class TransactionRepository {
  // Khoi tao singleton hoac static de dung chung 1 danh sach tren toan app
  static final TransactionRepository _instance = TransactionRepository._internal();
  factory TransactionRepository() => _instance;

  TransactionRepository._internal() {
    _seedData();
  }

  final List<Transaction> _items = [];

  // Du lieu mau ban dau (10 ban ghi nhu de bai yeu cau)
  void _seedData() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));

    _items.addAll([
      Transaction(
        id: 't1',
        title: 'Lương tháng',
        amount: 15000000,
        type: TransactionType.income,
        category: Category.salary,
        date: now,
        note: 'Lương công ty chuyển khoản',
      ),
      Transaction(
        id: 't2',
        title: 'Ăn trưa',
        amount: 45000,
        type: TransactionType.expense,
        category: Category.food,
        date: now,
      ),
      Transaction(
        id: 't3',
        title: 'Đổ xăng',
        amount: 70000,
        type: TransactionType.expense,
        category: Category.transport,
        date: now,
      ),
      Transaction(
        id: 't4',
        title: 'Cà phê',
        amount: 35000,
        type: TransactionType.expense,
        category: Category.food,
        date: yesterday,
      ),
      Transaction(
        id: 't5',
        title: 'Tiền điện',
        amount: 650000,
        type: TransactionType.expense,
        category: Category.bills,
        date: yesterday,
      ),
      Transaction(
        id: 't6',
        title: 'Bán đồ cũ',
        amount: 500000,
        type: TransactionType.income,
        category: Category.other,
        date: yesterday,
      ),
      Transaction(
        id: 't7',
        title: 'Xem phim',
        amount: 120000,
        type: TransactionType.expense,
        category: Category.entertainment,
        date: twoDaysAgo,
      ),
      Transaction(
        id: 't8',
        title: 'Mua sách',
        amount: 220000,
        type: TransactionType.expense,
        category: Category.education,
        date: twoDaysAgo,
      ),
      Transaction(
        id: 't9',
        title: 'Tiền thưởng',
        amount: 1000000,
        type: TransactionType.income,
        category: Category.salary,
        date: twoDaysAgo,
      ),
      Transaction(
        id: 't10',
        title: 'Gửi xe tháng',
        amount: 100000,
        type: TransactionType.expense,
        category: Category.transport,
        date: twoDaysAgo,
      ),
    ]);
  }

  // Lay tat ca giao dich, co gia lap delay 500ms
  Future<List<Transaction>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Tra ve ban sao cua list de ngoai UI khong sua bay vao list goc
    return List.from(_items);
  }

  // Lay chi tiet theo id
  Future<Transaction?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _items.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // Them giao dich moi
  Future<void> add(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (transaction.amount <= 0) {
      throw Exception('Số tiền phải lớn hơn 0');
    }
    _items.insert(0, transaction);
  }

  // Cap nhat giao dich
  Future<void> update(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (transaction.amount <= 0) {
      throw Exception('Số tiền phải lớn hơn 0');
    }
    final index = _items.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _items[index] = transaction;
    } else {
      throw Exception('Không tìm thấy giao dịch để cập nhật');
    }
  }

  // Xoa giao dich theo id
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _items.removeWhere((t) => t.id == id);
  }

  // Thuat toan gom nhom giao dich theo ngay
  Map<DateTime, List<Transaction>> groupByDate(List<Transaction> transactions) {
    final Map<DateTime, List<Transaction>> grouped = {};

    for (var tx in transactions) {
      // Chuan hoa ngay ve 0 gio 0 phut de gom dung ngay
      final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(tx);
    }

    return grouped;
  }

  // Tinh tong thu nhap dung fold
  double calculateTotalIncome(List<Transaction> list) {
    return list
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Tinh tong chi tieu dung fold
  double calculateTotalExpense(List<Transaction> list) {
    return list
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Tinh so du
  double calculateBalance(List<Transaction> list) {
    return calculateTotalIncome(list) - calculateTotalExpense(list);
  }
}

