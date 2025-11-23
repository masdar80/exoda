import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/entity.dart';

class AdvancedReportsScreen extends StatefulWidget {
  const AdvancedReportsScreen({super.key});

  @override
  State<AdvancedReportsScreen> createState() => _AdvancedReportsScreenState();
}

class _AdvancedReportsScreenState extends State<AdvancedReportsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  int _selectedIndex = 0;
  bool _isLoading = false;
  
  // Date filter variables
  DateTime? _fromDate;
  DateTime? _toDate;
  
  // Chart filter options
  DateTime? _chartStartDate;
  DateTime? _chartEndDate;
  String _selectedPeriod = 'thisMonth';
  
    _loadData();
  }
  
  Future<void> _calculateMonthlyTotals() async {
    try {
      // Calculate first month total
      final firstMonthStart = DateTime(_firstYear, _firstMonth, 1);
      final firstMonthEnd = DateTime(_firstYear, _firstMonth + 1, 0);
      
      final firstMonthTransactions = await _databaseService.getTransactions(
        direction: 'payment',
        startDate: firstMonthStart,
        endDate: firstMonthEnd,
      );
      
      _firstMonthTotal = firstMonthTransactions
          .fold(0.0, (sum, t) => sum + t.amount);
      
      // Calculate second month total
      final secondMonthStart = DateTime(_secondYear, _secondMonth, 1);
      final secondMonthEnd = DateTime(_secondYear, _secondMonth + 1, 0);
      
      final secondMonthTransactions = await _databaseService.getTransactions(
        direction: 'payment',
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
      });
    }
  }

  void _selectToDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
      });
    }
  }

  void _setDateRangeFromPeriod() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'thisMonth':
        _chartStartDate = DateTime(now.year, now.month, 1);
        _chartEndDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'lastMonth':
        _chartStartDate = DateTime(now.year, now.month - 1, 1);
        _chartEndDate = DateTime(now.year, now.month, 0);
        break;
      case 'thisYear':
        _chartStartDate = DateTime(now.year, 1, 1);
        _chartEndDate = DateTime(now.year, 12, 31);
        break;
      case 'lastYear':
        _chartStartDate = DateTime(now.year - 1, 1, 1);
        _chartEndDate = DateTime(now.year - 1, 12, 31);
        break;
      case 'custom':
        // Keep existing dates
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(tr.advancedReportsTitle),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildTabBar(tr),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildSelectedView(tr),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(AppLocalizations tr) {
    return Container(
      margin: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(tr, tr.pieChart, 0),
    final isSelected = _selectedIndex == index;
    return ElevatedButton(
      onPressed: () => setState(() => _selectedIndex = index),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.teal : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

      children: [
        _buildPeriodSelector(tr),
        Expanded(
          child: FutureBuilder<Map<String, double>>(
            future: _getExpensesByCategory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(tr.noDataForPeriod),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      tr.expensesByCategoryTitle,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieChartSections(snapshot.data!),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLegend(snapshot.data!),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(AppLocalizations tr) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              tr.selectPeriodTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildPeriodChip(tr, tr.thisMonth, 'thisMonth'),
                _buildPeriodChip(tr, tr.lastMonth, 'lastMonth'),
                _buildPeriodChip(tr, tr.thisYear, 'thisYear'),
                _buildPeriodChip(tr, tr.lastYear, 'lastYear'),
                _buildPeriodChip(tr, tr.customPeriod, 'custom'),
              ],
            ),
            if (_selectedPeriod == 'custom') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectDate(true),
                      child: Text(
                        _chartStartDate != null 
                          ? DateFormat('dd/MM/yyyy').format(_chartStartDate!)
                          : tr.fromDate,
                      ),
                    ),
                  ),
                  Text(tr.to),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectDate(false),
                      child: Text(
                        _chartEndDate != null 
                          ? DateFormat('dd/MM/yyyy').format(_chartEndDate!)
                          : tr.toDate,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(AppLocalizations tr, String label, String value) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: _selectedPeriod == value,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedPeriod = value;
            _setDateRangeFromPeriod();
          });
        }
      },
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> data) {
    final colors = [
      Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.teal, Colors.amber, Colors.pink, Colors.indigo, Colors.cyan,
    ];
    
    int colorIndex = 0;
    final total = data.values.fold(0.0, (sum, value) => sum + value);
    
    return data.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, double> data) {
    final colors = [
      Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.teal, Colors.amber, Colors.pink, Colors.indigo, Colors.cyan,
    ];
    
    int colorIndex = 0;
    final total = data.values.fold(0.0, (sum, value) => sum + value);
    
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: data.entries.map((entry) {
        final color = colors[colorIndex % colors.length];
        colorIndex++;
        final percentage = (entry.value / total * 100);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${entry.key}: ${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthlyComparison(AppLocalizations tr) {
    return Column(
      children: [
        _buildComparisonSelector(tr),
        Expanded(
          child: FutureBuilder<Map<String, Map<String, double>>>(
            future: _getMonthlyComparison(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(tr.noDataForComparison),
                );
              }

              return _buildComparisonChart(tr, snapshot.data!);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonSelector(AppLocalizations tr) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              tr.monthlyComparisonTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        tr.firstMonthTitle,
                        style: const TextStyle(fontSize: 12),
                      ),
                      DropdownButton<int>(
                        value: _firstMonth,
                        items: List.generate(12, (index) => index + 1)
                            .map((month) => DropdownMenuItem(
                                  value: month,
                                  child: Text(_getMonthName(month)),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _firstMonth = value!),
                      ),
                      DropdownButton<int>(
                        value: _firstYear,
                        items: List.generate(5, (index) => DateTime.now().year - index)
                            .map((year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _firstYear = value!),
                      ),
                    ],
                  ),
                ),
                const Text('مقابل'),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        tr.secondMonthTitle,
                        style: const TextStyle(fontSize: 12),
                      ),
                      DropdownButton<int>(
                        value: _secondMonth,
                        items: List.generate(12, (index) => index + 1)
                            .map((month) => DropdownMenuItem(
                                  value: month,
                                  child: Text(_getMonthName(month)),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _secondMonth = value!),
                      ),
                      DropdownButton<int>(
                        value: _secondYear,
                        items: List.generate(5, (index) => DateTime.now().year - index)
                            .map((year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _secondYear = value!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
      child: Column(
        children: [
          Text(
            'مقارنة ${_getMonthName(_firstMonth)} $_firstYear مع ${_getMonthName(_secondMonth)} $_secondYear',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxValue(data),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final categories = data.keys.toList();
                        if (value.toInt() < categories.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              categories[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(data),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(tr.firstMonthTitle, Colors.blue),
              const SizedBox(width: 16),
              _buildLegendItem(tr.secondMonthTitle, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, Map<String, double>> data) {
    return data.entries.map((entry) {
      final categoryIndex = data.keys.toList().indexOf(entry.key);
      final categoryData = entry.value;
      
      return BarChartGroupData(
        x: categoryIndex,
        barRods: [
          BarChartRodData(
            toY: categoryData['first'] ?? 0,
            color: Colors.blue,
            width: 16,
          ),
          BarChartRodData(
            toY: categoryData['second'] ?? 0,
            color: Colors.red,
            width: 16,
          ),
        ],
      );
    }).toList();
  }

  double _getMaxValue(Map<String, Map<String, double>> data) {
    double max = 0;
    for (var categoryData in data.values) {
      for (var value in categoryData.values) {
        if (value > max) max = value;
      }
    }
    return max * 1.2; // Add 20% padding
  }

  Future<void> _selectDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_chartStartDate ?? DateTime.now()) : (_chartEndDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        if (isStartDate) {
          _chartStartDate = date;
        } else {
          _chartEndDate = date;
        }
      });
    }
  }

  Future<Map<String, double>> _getExpensesByCategory() async {
    final transactions = await _databaseService.getTransactions(
      direction: 'payment',
      startDate: _chartStartDate,
      endDate: _chartEndDate,
    );

    final Map<String, double> categoryExpenses = {};
    final parentCategories = await _databaseService.getParentCategories('payment');
    
    for (var transaction in transactions) {
      // Find parent category
      String parentCategory = transaction.entity;
      final parent = parentCategories.firstWhere(
        (cat) => cat.name == transaction.entity,
        orElse: () => Entity(name: 'آخر', type: 'payment'),
      );
      
      if (parent.name != 'آخر') {
        parentCategory = parent.name;
      }
      
      categoryExpenses[parentCategory] = 
          (categoryExpenses[parentCategory] ?? 0) + transaction.amount;
    }

    return categoryExpenses;
  }

  Future<Map<String, Map<String, double>>> _getMonthlyComparison() async {
    // Get transactions for first month
    final firstMonthStart = DateTime(_firstYear, _firstMonth, 1);
    final firstMonthEnd = DateTime(_firstYear, _firstMonth + 1, 0);
    final firstMonthTransactions = await _databaseService.getTransactions(
      direction: 'payment',
      startDate: firstMonthStart,
      endDate: firstMonthEnd,
    );

    // Get transactions for second month
    final secondMonthStart = DateTime(_secondYear, _secondMonth, 1);
    final secondMonthEnd = DateTime(_secondYear, _secondMonth + 1, 0);
    final secondMonthTransactions = await _databaseService.getTransactions(
      direction: 'payment',
      startDate: secondMonthStart,
      endDate: secondMonthEnd,
    );

    // Organize by categories
    final Map<String, Map<String, double>> comparison = {};
    final parentCategories = await _databaseService.getParentCategories('payment');
    
    // Process first month
    for (var transaction in firstMonthTransactions) {
      String parentCategory = transaction.entity;
      final parent = parentCategories.firstWhere(
        (cat) => cat.name == transaction.entity,
        orElse: () => Entity(name: 'آخر', type: 'payment'),
      );
      
      if (parent.name != 'آخر') {
        parentCategory = parent.name;
      }
      
      comparison[parentCategory] ??= {'first': 0, 'second': 0};
      comparison[parentCategory]!['first'] = 
          (comparison[parentCategory]!['first'] ?? 0) + transaction.amount;
    }

    // Process second month
    for (var transaction in secondMonthTransactions) {
      String parentCategory = transaction.entity;
      final parent = parentCategories.firstWhere(
        (cat) => cat.name == transaction.entity,
        orElse: () => Entity(name: 'آخر', type: 'payment'),
      );
      
      if (parent.name != 'آخر') {
        parentCategory = parent.name;
      }
      
      comparison[parentCategory] ??= {'first': 0, 'second': 0};
      comparison[parentCategory]!['second'] = 
          (comparison[parentCategory]!['second'] ?? 0) + transaction.amount;
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(data),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(tr.firstMonthTitle, Colors.blue),
              const SizedBox(width: 16),
              _buildLegendItem(tr.secondMonthTitle, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, Map<String, double>> data) {
    return data.entries.map((entry) {
      final categoryIndex = data.keys.toList().indexOf(entry.key);
      final categoryData = entry.value;
      
      return BarChartGroupData(
        x: categoryIndex,
        barRods: [
          BarChartRodData(
            toY: categoryData['first'] ?? 0,
            color: Colors.blue,
            width: 16,
          ),
          BarChartRodData(
            toY: categoryData['second'] ?? 0,
            color: Colors.red,
            width: 16,
          ),
        ],
      );
    }).toList();
  }

  double _getMaxValue(Map<String, Map<String, double>> data) {
    double max = 0;
    for (var categoryData in data.values) {
      for (var value in categoryData.values) {
        if (value > max) max = value;
      }
    }
    return max * 1.2; // Add 20% padding
  }

  Future<void> _selectDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_chartStartDate ?? DateTime.now()) : (_chartEndDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        if (isStartDate) {
          _chartStartDate = date;
        } else {
          _chartEndDate = date;
        }
      });
    }
  }

  Future<Map<String, double>> _getExpensesByCategory() async {
    final transactions = await _databaseService.getTransactions(
      direction: 'payment',
      startDate: _chartStartDate,
      endDate: _chartEndDate,
    );

    final Map<String, double> categoryExpenses = {};
    final parentCategories = await _databaseService.getParentCategories('payment');
    
    for (var transaction in transactions) {
      // Find parent category
      String parentCategory = transaction.entity;
      final parent = parentCategories.firstWhere(
        (cat) => cat.name == transaction.entity,
        orElse: () => Entity(name: 'آخر', type: 'payment'),
      );
      
      if (parent.name != 'آخر') {
        parentCategory = parent.name;
      }
      
      categoryExpenses[parentCategory] = 
          (categoryExpenses[parentCategory] ?? 0) + transaction.amount;
    }

    return categoryExpenses;
  }

  Future<Map<String, Map<String, double>>> _getMonthlyComparison() async {
    // Get transactions for first month
    final firstMonthStart = DateTime(_firstYear, _firstMonth, 1);
    final firstMonthEnd = DateTime(_firstYear, _firstMonth + 1, 0);
    final firstMonthTransactions = await _databaseService.getTransactions(
      direction: 'payment',
      startDate: firstMonthStart,
      endDate: firstMonthEnd,
    );

    // Get transactions for second month
    final secondMonthStart = DateTime(_secondYear, _secondMonth, 1);
    final secondMonthEnd = DateTime(_secondYear, _secondMonth + 1, 0);
    final secondMonthTransactions = await _databaseService.getTransactions(
      direction: 'payment',
      startDate: secondMonthStart,
      endDate: secondMonthEnd,
    );

    // Organize by categories
    final Map<String, Map<String, double>> comparison = {};
    final parentCategories = await _databaseService.getParentCategories('payment');
    
    // Process first month
    for (var transaction in firstMonthTransactions) {
      String parentCategory = transaction.entity;
      final parent = parentCategories.firstWhere(
        (cat) => cat.name == transaction.entity,
        orElse: () => Entity(name: 'آخر', type: 'payment'),
      );
      
      if (parent.name != 'آخر') {
        parentCategory = parent.name;
      }
      
      comparison[parentCategory] ??= {'first': 0, 'second': 0};
      comparison[parentCategory]!['first'] = 
          (comparison[parentCategory]!['first'] ?? 0) + transaction.amount;
    }

    // Process second month
    for (var transaction in secondMonthTransactions) {
      String parentCategory = transaction.entity;
      final parent = parentCategories.firstWhere(
        (cat) => cat.name == transaction.entity,
        orElse: () => Entity(name: 'آخر', type: 'payment'),
      );
      
      if (parent.name != 'آخر') {
        parentCategory = parent.name;
      }
      
      comparison[parentCategory] ??= {'first': 0, 'second': 0};
      comparison[parentCategory]!['second'] = 
          (comparison[parentCategory]!['second'] ?? 0) + transaction.amount;
    }

    return comparison;
  }

  Widget _buildFamilyInsights(AppLocalizations tr) {
    return Column(
      children: [
        _buildPeriodSelector(tr),
        Expanded(
          child: FutureBuilder<Map<String, double>>(
            future: _getExpensesByType(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(tr.noFamilyData),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      tr.spendingShare,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieChartSections(snapshot.data!),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLegend(snapshot.data!),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Future<Map<String, double>> _getExpensesByType() async {
    return await _databaseService.getExpensesByType(
      startDate: _chartStartDate,
      endDate: _chartEndDate,
    );
  }

  String _getMonthName(int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return months[month - 1];
  }
}