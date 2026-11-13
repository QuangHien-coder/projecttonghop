import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/transaction_repository.dart';
import '../models/transaction.dart';
import '../widgets/transaction_tile.dart';

// Widget StatefulWidget vi can debounce nhap lieu tu ban phim va cap nhat ket qua tim kiem
class SearchScreen extends StatefulWidget {
  final String? initialKeyword;

  const SearchScreen({super.key, this.initialKeyword});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _repository = TransactionRepository();
  final _searchController = TextEditingController();

  Timer? _debounce;
  List<Transaction> _allTransactions = [];
  List<Transaction> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialKeyword != null) {
      _searchController.text = widget.initialKeyword!;
    }
    _loadAllData();
  }

  @override
  void dispose() {
    // BAT BUOC: Huy timer va dispose controller tranh ro ri bo nho
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final data = await _repository.getAll();
    if (!mounted) return;
    _allTransactions = data;
    setState(() => _isLoading = false);

    if (_searchController.text.trim().isNotEmpty) {
      _performSearch(_searchController.text.trim());
    }
  }

  // Ham xu ly debounce: doi 300ms sau khi nguoi dung ngung go moi loc ket qua
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query.trim());
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final lower = query.toLowerCase();
    final results = _allTransactions.where((t) {
      final matchTitle = t.title.toLowerCase().contains(lower);
      final matchCategory = t.category.label.toLowerCase().contains(lower);
      final matchNote = t.note?.toLowerCase().contains(lower) ?? false;
      return matchTitle || matchCategory || matchNote;
    }).toList();

    setState(() => _searchResults = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm giao dịch...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _searchController.text.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('Nhập từ khóa để tìm theo tên, danh mục hoặc ghi chú', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('Không tìm thấy kết quả nào cho "${_searchController.text}"', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
                      itemBuilder: (context, index) {
                        final tx = _searchResults[index];
                        return TransactionTile(
                          transaction: tx,
                          onTap: () async {
                            final needReload = await context.pushNamed<bool>(
                              'transaction-detail',
                              pathParameters: {'id': tx.id},
                            );
                            if (needReload == true) {
                              _loadAllData();
                            }
                          },
                        );
                      },
                    ),
    );
  }
}
