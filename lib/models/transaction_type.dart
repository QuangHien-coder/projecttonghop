// Enum loai giao dich: thu nhap hoac chi tieu
enum TransactionType {
  income('Thu nhập'),
  expense('Chi tiêu');

  // Nhan hien thi tieng Viet tren UI
  final String label;

  const TransactionType(this.label);
}

