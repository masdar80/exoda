import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/transaction.dart' as model;
import 'add_transaction_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'edit_transaction_screen.dart';
import 'package:exoda/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  final Function(Locale) onLanguageChange;

  const HomeScreen({
    super.key,
    required this.onLanguageChange,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  int _currentIndex = 0;
  List<model.Transaction> _recentTransactions = [];
  bool _isLoading = true;
  double _monthlyExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    print('🏠 بدء تحميل بيانات الشاشة الرئيسية...');
    setState(() {
      _isLoading = true;
    });

    try {
      print('🏠 جلب إجمالي المصاريف الشهرية...');
      final monthlyExpense =
          await _databaseService.getTotalExpensesForMonth(DateTime.now());
      print('🏠 إجمالي المصاريف الشهرية: $monthlyExpense');

      print('🏠 جلب آخر المعاملات...');
      final recentTransactions =
          await _databaseService.getRecentTransactions(limit: 5);
      print('🏠 عدد المعاملات المجلبة: ${recentTransactions.length}');

      for (int i = 0; i < recentTransactions.length; i++) {
        final tx = recentTransactions[i];
        print(
            '🏠 معاملة $i: ${tx.direction} - ${tx.entity} - ${tx.amount} - ${tx.paymentMethod}');
      }

      setState(() {
        _monthlyExpense = monthlyExpense;
        _recentTransactions = recentTransactions;
        _isLoading = false;
      });

      print('🏠 انتهاء تحميل البيانات بنجاح');
    } catch (e) {
      print('🏠 خطأ في تحميل البيانات: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(tr),
          AddTransactionScreen(onTransactionAdded: _loadData),
          ReportsScreen(),
          SettingsScreen(
            onLanguageChange: widget.onLanguageChange,
            onDataChanged: _loadData,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: tr.homeTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle),
            label: tr.addTransactionTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assessment),
            label: tr.reportsTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: tr.settingsTitle,
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(AppLocalizations tr) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(tr.appTitle),
            backgroundColor: Colors.teal,
            floating: true,
            snap: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  print('🔄 تحديث يدوي للشاشة الرئيسية');
                  _loadData();
                },
                tooltip: tr.update,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    children: [
                      _buildExpenseSummaryCard(tr),
                      _buildRecentTransactionsCard(tr),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseSummaryCard(AppLocalizations tr) {
    final currency = tr.currency.isNotEmpty ? tr.currency : 'ريال';
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [Colors.teal, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.totalExpenses,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_monthlyExpense.toStringAsFixed(2)} $currency',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('MMM', 'ar').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsCard(AppLocalizations tr) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr.recentTransactions,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 2; // Switch to reports tab
                    });
                  },
                  child: Text(tr.viewAll, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_recentTransactions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(tr.noTransactionsYet,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          print(
                              '🔄 إعادة تحميل البيانات من زر "لا توجد حركات"');
                          _loadData();
                        },
                        child: Text(tr.update),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...(_recentTransactions.map(
                  (transaction) => _buildTransactionItem(transaction, tr))),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
      model.Transaction transaction, AppLocalizations tr) {
    final currency = tr.currency.isNotEmpty ? tr.currency : 'ريال';
    final formatter = NumberFormat.currency(
      locale: 'ar',
      symbol: currency,
      decimalDigits: 2,
    );

    final isPayment = transaction.direction == 'payment';
    final color = isPayment ? Colors.red : Colors.green;
    final icon = isPayment ? Icons.arrow_downward : Icons.arrow_upward;

    // Show notes for "آخر" category or when notes exist
    final hasNotes = transaction.notes != null && transaction.notes!.isNotEmpty;
    final shouldHighlightNotes =
        transaction.entity == 'آخر' || transaction.type == 'متنوع';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.entity,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${transaction.type} • ${transaction.paymentMethod}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        formatter.format(transaction.amount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        onPressed: () => _editTransaction(transaction),
                        tooltip: 'تعديل',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('dd/MM').format(transaction.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Notes section
          if (hasNotes)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: shouldHighlightNotes
                    ? Colors.amber.shade50
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
                border: shouldHighlightNotes
                    ? Border.all(color: Colors.amber.shade200)
                    : Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.note_alt,
                    size: 14,
                    color: shouldHighlightNotes
                        ? Colors.amber.shade700
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      transaction.notes!,
                      style: TextStyle(
                        fontSize: 11,
                        color: shouldHighlightNotes
                            ? Colors.amber.shade800
                            : Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _editTransaction(model.Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(
          transaction: transaction,
          onTransactionUpdated: _loadData,
        ),
      ),
    );
  }
}
