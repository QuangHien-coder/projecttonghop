// Extension format tien va ngay thang tu viet, khong dung thu vien ngoai intl

extension CurrencyFormatX on double {
  // Chuyen so double thanh chuoi tien VND, vd 1500000 -> "1.500.000 ₫"
  String toVnd() {
    int value = toInt().abs();
    String raw = value.toString();

    // Chen dau cham moi 3 so tu phai qua trai
    String result = '';
    int count = 0;
    for (int i = raw.length - 1; i >= 0; i--) {
      result = raw[i] + result;
      count++;
      if (count % 3 == 0 && i > 0) {
        result = '.$result';
      }
    }

    return '$result ₫';
  }
}

extension DateFormatX on DateTime {
  // Format ngay thang theo chuan dd/MM/yyyy
  String toDmy() {
    String d = day.toString().padLeft(2, '0');
    String m = month.toString().padLeft(2, '0');
    String y = year.toString();
    return '$d/$m/$y';
  }
}

