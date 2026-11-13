import 'package:flutter/material.dart';
import 'app_router.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

// Widget goc cua ung dung
class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
