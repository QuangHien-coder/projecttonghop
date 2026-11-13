import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'services/auth_service.dart';
import 'models/transaction.dart';
import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/home_screen.dart';
import 'screens/transaction_list_screen.dart';
import 'screens/transaction_detail_screen.dart';
import 'screens/transaction_form_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/not_found_screen.dart';

// Key danh rieng cho navigator goc
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final authService = AuthService();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authService,

    // Logic dieu huong tu dong redirect theo trang thai dang nhap
    redirect: (context, state) {
      final loggedIn = authService.isLoggedIn;
      final isLoggingIn = state.matchedLocation == '/login';

      // 1. Chua dang nhap ma vao cac trang khac -> ep ve /login
      if (!loggedIn && !isLoggingIn) {
        return '/login';
      }

      // 2. Da dang nhap ma lai vao /login -> day ve trang chu /
      if (loggedIn && isLoggingIn) {
        return '/';
      }

      // Con lai cho phep di tiep binh thuong
      return null;
    },

    // Trang bao loi 404
    errorBuilder: (context, state) => const NotFoundScreen(),

    routes: [
      // Route ngoai Shell: Dang nhap
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Route tim kiem
      GoRoute(
        path: '/search',
        name: 'search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final keyword = state.uri.queryParameters['keyword'];
          return SearchScreen(initialKeyword: keyword);
        },
      ),

      // ShellRoute giu trang thai 3 tab bang StatefulShellRoute.indexedStack
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Nhánh 0: Trang chu
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Nhánh 1: Danh sach giao dich & cac man con
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                name: 'transactions',
                builder: (context, state) {
                  final typeFilter = state.uri.queryParameters['type'];
                  return TransactionListScreen(typeFilter: typeFilter);
                },
                routes: [
                  // Form them moi giao dich (Mo de len tren cung, co nut Back)
                  GoRoute(
                    path: 'add',
                    name: 'transaction-add',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const TransactionFormScreen(),
                  ),
                  // Chi tiet giao dich
                  GoRoute(
                    path: ':id',
                    name: 'transaction-detail',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      final extraTx = state.extra is Transaction ? state.extra as Transaction : null;
                      return TransactionDetailScreen(id: id, initialTransaction: extraTx);
                    },
                    routes: [
                      // Route con sua giao dich: /transactions/:id/edit
                      GoRoute(
                        path: 'edit',
                        name: 'transaction-edit',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          final extraTx = state.extra is Transaction ? state.extra as Transaction : null;
                          return TransactionFormScreen(id: id, initialTransaction: extraTx);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Nhánh 2: Ho so ca nhan
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

