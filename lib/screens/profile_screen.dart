import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../data/transaction_repository.dart';

// Widget StatelessWidget vi lay thong tin tu AuthService va TransactionRepository de hien thi
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final repository = TransactionRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ người dùng', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder(
        future: repository.getAll(),
        builder: (context, snapshot) {
          final txCount = snapshot.hasData ? snapshot.data!.length : 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                const CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 14),
                Text(
                  authService.username.isNotEmpty ? authService.username : 'Người dùng',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('Tài khoản cá nhân', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),

                // Thong ke nhanh
                Card(
                  elevation: 0,
                  color: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '$txCount',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            const SizedBox(height: 4),
                            const Text('Tổng giao dịch', style: TextStyle(fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                        Container(height: 30, width: 1, color: Colors.blue.shade200),
                        const Column(
                          children: [
                            Text(
                              'VND',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            SizedBox(height: 4),
                            Text('Đơn vị tiền tệ', style: TextStyle(fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Danh sach cai dat & thong tin
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Phiên bản ứng dụng'),
                  trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Bảo mật dữ liệu'),
                  trailing: const Icon(Icons.chevron_right),
                ),
                const Divider(),
                const SizedBox(height: 32),

                // Nut Dang xuat
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      // Goi logout tu auth service, GoRouter refreshListenable se tu dong redirect ve /login
                      authService.logout();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Đăng xuất', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

