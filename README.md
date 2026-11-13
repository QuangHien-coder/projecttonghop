# Expense Tracker - Ứng dụng Quản lý Chi tiêu Cá nhân

Ứng dụng Flutter quản lý thu chi cá nhân hằng ngày, xem thống kê số dư, phân tích tỷ lệ chi tiêu theo danh mục, lọc theo loại giao dịch và tìm kiếm có debounce.

## 1. Công nghệ & Kiến trúc sử dụng
- **Flutter SDK & Dart 3**: Sử dụng Enhanced Enum, Immutability model (`copyWith`), Extension methods tự viết định dạng tiền tệ và ngày tháng (không dùng thư viện ngoài).
- **Điều hướng**: `go_router` với `StatefulShellRoute.indexedStack` (bảo toàn vị trí cuộn của 3 tab chính: Tổng quan, Giao dịch, Hồ sơ).
- **Quản lý trạng thái (State Management)**: Nâng state lên (Lifting state up) kết hợp `setState` và `ChangeNotifier` (`AuthService`), không dùng thư viện ngoài.
- **Bố cục & Responsive**: Thích ứng theo độ rộng màn hình (`NavigationBar` cho mobile hẹp < 600, `NavigationRail` cho tablet/máy tính ≥ 600).

## 2. Sơ đồ Route (go_router)
| Đường dẫn | Tên route | Màn hình | Chức năng |
|---|---|---|---|
| `/login` | `login` | `LoginScreen` | Đăng nhập tài khoản (nằm ngoài shell) |
| `/` | `home` | `HomeScreen` | Tab 1: Tổng quan số dư, tỷ lệ chi tiêu, 5 giao dịch gần nhất |
| `/transactions` | `transactions` | `TransactionListScreen` | Tab 2: Danh sách nhóm theo ngày, lọc `?type=income\|expense` |
| `/transactions/add` | `transaction-add` | `TransactionFormScreen` | Thêm giao dịch mới (mở dạng push chồng lên) |
| `/transactions/:id` | `transaction-detail` | `TransactionDetailScreen` | Xem chi tiết giao dịch (path param id) |
| `/transactions/:id/edit` | `transaction-edit` | `TransactionFormScreen` | Sửa giao dịch |
| `/search` | `search` | `SearchScreen` | Tìm kiếm giao dịch có debounce 300ms |
| `/profile` | `profile` | `ProfileScreen` | Tab 3: Thông tin cá nhân, tổng giao dịch, đăng xuất |
| (khác) | - | `NotFoundScreen` | Báo lỗi 404 thân thiện |

## 3. Cách chạy ứng dụng
1. Cài đặt các gói phụ thuộc:
   ```bash
   flutter pub get
   ```
2. Chạy ứng dụng trên máy ảo / thiết bị thật:
   ```bash
   flutter run
   ```
3. Chạy kiểm thử tự động (Unit test):
   ```bash
   flutter test
   ```

## 4. Giải thích cách quản lý State
Dự án áp dụng mô hình **Repository tĩnh kết hợp Nâng state lên (Lifting State Up)**:
- `TransactionRepository` giữ dữ liệu trong bộ nhớ và giả lập các tác vụ bất đồng bộ (`Future.delayed`).
- Các màn hình (`HomeScreen`, `TransactionListScreen`) lắng nghe dữ liệu khi `initState`, chia làm 4 trạng thái giao diện rõ ràng thông qua `enum LoadStatus { loading, error, empty, success }`.
- Khi người dùng thêm, sửa hoặc xóa, màn hình gọi hàm từ Repository, cập nhật dữ liệu và gọi `setState()` an toàn (luôn kiểm tra `if (!mounted) return;`).
- Màn hình thêm/sửa giao dịch mở bằng `context.pushNamed(...)`, khi hoàn tất sẽ `context.pop(true)` để màn trước tự động tải lại dữ liệu mới nhất.
