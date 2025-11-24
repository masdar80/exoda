import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/transaction.dart' as model;
import 'advanced_reports_screen.dart';
import 'yearly_report_screen.dart';
import 'package:exoda/l10n/app_localizations.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<model.Transaction> _transactions = [];
  bool _isLoading = true;
  bool _isDetailedView = true;

  // Filter options
  String? _filterDirection;
  String? _filterPaymentMethod;

  DateTime? _fromDate;
  DateTime? _toDate;
  String? _currentFilter;
  String? _filterTypeValue;

  double _calculateTotalPayments() {
    return _transactions
        .where((t) => t.direction == 'payment')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateTotalReceipts() {
    return _transactions
        .where((t) => t.direction == 'receipt')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<model.Transaction> get _filteredTransactions {
    if (_filterTypeValue == null || _filterTypeValue == 'all') {
      return _transactions;
    }
    return _transactions.where((t) => t.direction == _filterTypeValue).toList();
  }

  void _clearFilter() {
    setState(() {
      _currentFilter = null;
      _filterTypeValue = null;
    });
  }

  void _applyFilter() {
    setState(() {
      _currentFilter = _filterTypeValue;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactions = await _databaseService.getTransactions(
        direction: _filterDirection,
        paymentMethod: _filterPaymentMethod,
        startDate: _fromDate,
        endDate: _toDate,
      );

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.reportsTitle),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const YearlyReportScreen(),
                ),
              );
            },
            tooltip: 'Yearly Report',
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvancedReportsScreen(),
                ),
              );
            },
            tooltip: tr.advancedReportsTitle,
          ),
          IconButton(
            icon: Icon(_isDetailedView ? Icons.summarize : Icons.list),
            onPressed: () {
              setState(() {
                _isDetailedView = !_isDetailedView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: tr.filter,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Cards
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.red[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(Icons.arrow_upward,
                                    color: Colors.red, size: 30),
                                const SizedBox(height: 8),
                                Text(
                                  tr.payments,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_calculateTotalPayments().toStringAsFixed(2)} ${tr.currency}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          color: Colors.green[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(Icons.arrow_downward,
                                    color: Colors.green, size: 30),
                                const SizedBox(height: 8),
                                Text(
                                  tr.receipts,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_calculateTotalReceipts().toStringAsFixed(2)} ${tr.currency}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          color: Colors.blue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(Icons.account_balance,
                                    color: Colors.blue, size: 30),
                                const SizedBox(height: 8),
                                Text(
                                  tr.net,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(_calculateTotalReceipts() - _calculateTotalPayments()).toStringAsFixed(2)} ${tr.currency}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter Info
                if (_currentFilter != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      border: Border.all(color: Colors.amber[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.amber[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tr.filterInfo,
                            style: TextStyle(
                              color: Colors.amber[800],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _clearFilter,
                          child: Text(tr.cancel),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Transactions List
                Expanded(
                  child: _filteredTransactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                tr.noTransactionsYet,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _filteredTransactions[index];
                            return _buildTransactionItem(transaction, tr);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildTransactionItem(
      model.Transaction transaction, AppLocalizations tr) {
    final isPayment = transaction.direction == 'payment';
    final color = isPayment ? Colors.red : Colors.green;
    final icon = isPayment ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPayment ? Colors.red[100] : Colors.green[100],
          child: Icon(icon, color: color),
        ),
        title: Text(
          transaction.entity,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${transaction.type} • ${transaction.paymentMethod}'),
            Text(
              DateFormat('dd/MM/yyyy - HH:mm').format(transaction.date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Text(
          '${transaction.amount.toStringAsFixed(2)} ${tr.currency}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    final tr = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.filter),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(tr.payments),
              leading: Radio<String>(
                value: 'payment',
                groupValue: _filterTypeValue,
                onChanged: (value) {
                  setState(() {
                    _filterTypeValue = value;
                  });
                },
              ),
            ),
            ListTile(
              title: Text(tr.receipts),
              leading: Radio<String>(
                value: 'receipt',
                groupValue: _filterTypeValue,
                onChanged: (value) {
                  setState(() {
                    _filterTypeValue = value;
                  });
                },
              ),
            ),
            ListTile(
              title: Text(tr.viewAll),
              leading: Radio<String>(
                value: 'all',
                groupValue: _filterTypeValue,
                onChanged: (value) {
                  setState(() {
                    _filterTypeValue = value;
                  });
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              _applyFilter();
              Navigator.pop(context);
            },
            child: Text(tr.filter),
          ),
        ],
      ),
    );
  }
}
