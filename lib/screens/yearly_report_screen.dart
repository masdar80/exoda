import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_service.dart';
import 'package:exoda/l10n/app_localizations.dart';

class YearlyReportScreen extends StatefulWidget {
  const YearlyReportScreen({super.key});

  @override
  State<YearlyReportScreen> createState() => _YearlyReportScreenState();
}

class _YearlyReportScreenState extends State<YearlyReportScreen> {
  final DatabaseService _databaseService = DatabaseService();
  int _selectedYear = DateTime.now().year;
  bool _isLoading = false;
  List<Map<String, dynamic>> _yearlyData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _databaseService.getYearlySummary(_selectedYear);
      setState(() {
        _yearlyData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading yearly data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fallback for localization if not available yet (though it should be)
    final tr = AppLocalizations.of(context);
    final title = tr != null
        ? 'التقرير السنوي'
        : 'Yearly Report'; // Manual fallback if key missing

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildYearSelector(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _yearlyData.isEmpty
                    ? const Center(child: Text('No data'))
                    : _buildChartContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.teal.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              setState(() {
                _selectedYear--;
              });
              _loadData();
            },
          ),
          Text(
            '$_selectedYear',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () {
              setState(() {
                _selectedYear++;
              });
              _loadData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChartContent() {
    double maxVal = 0;
    for (var item in _yearlyData) {
      if (item['income'] > maxVal) maxVal = item['income'];
      if (item['expense'] > maxVal) maxVal = item['expense'];
    }
    // Add some padding to top
    maxVal = maxVal * 1.2;
    if (maxVal == 0) maxVal = 100;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: maxVal / 5,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        int index = value.toInt();
                        if (index > 0 && index <= 12) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text('$index', style: style),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxVal / 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.right,
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xff37434d)),
                ),
                minX: 1,
                maxX: 12,
                minY: 0,
                maxY: maxVal,
                lineBarsData: [
                  // Income Line (Green)
                  LineChartBarData(
                    spots: _yearlyData.map((e) {
                      return FlSpot(
                        (e['month'] as int).toDouble(),
                        e['income'] as double,
                      );
                    }).toList(),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.1),
                    ),
                  ),
                  // Expense Line (Red)
                  LineChartBarData(
                    spots: _yearlyData.map((e) {
                      return FlSpot(
                        (e['month'] as int).toDouble(),
                        e['expense'] as double,
                      );
                    }).toList(),
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.red.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Income (Receipts)', Colors.green),
        const SizedBox(width: 20),
        _buildLegendItem('Expenses (Payments)', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
