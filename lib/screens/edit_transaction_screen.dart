import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/transaction.dart' as model;
import '../models/entity.dart';
import '../models/expense_type.dart';
import 'package:exoda/l10n/app_localizations.dart';

class EditTransactionScreen extends StatefulWidget {
  final model.Transaction transaction;
  final VoidCallback onTransactionUpdated;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
    required this.onTransactionUpdated,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  String _direction = 'payment';
  String _paymentMethod = 'كاش';
  String? _selectedEntity;
  String? _selectedSubcategory;
  String? _selectedType;
  DateTime _selectedDate = DateTime.now();

  List<Entity> _entities = [];
  List<Entity> _subcategories = [];
  List<ExpenseType> _types = [];
  List<String> _paymentMethods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeFromTransaction();
    _loadData();
  }

  void _initializeFromTransaction() {
    final tx = widget.transaction;
    _direction = tx.direction;
    _paymentMethod = tx.paymentMethod;
    _selectedEntity = tx.entity;
    _selectedSubcategory = tx.subcategory;
    _selectedType = tx.type;
    _selectedDate = tx.date;
    _amountController.text = tx.amount.toString();
    _notesController.text = tx.notes ?? '';
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entities = await _databaseService.getEntities(_direction);
      final types = await _databaseService.getExpenseTypes();
      final paymentMethods = await _databaseService.getPaymentMethods();

      setState(() {
        _entities = entities.where((e) => !e.isSubcategory).toList();
        _types = types;
        _paymentMethods = paymentMethods;
        _isLoading = false;
      });

      if (_selectedEntity != null) {
        _loadSubcategories(_selectedEntity!);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSubcategories(String parentEntity) async {
    final subcategories = await _databaseService.getSubcategories(parentEntity);
    setState(() {
      _subcategories = subcategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr.updateTransaction),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTransaction,
            tooltip: tr.deleteTransaction,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr.direction,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: Text(tr.payment),
                                    value: 'payment',
                                    groupValue: _direction,
                                    onChanged: (value) {
                                      setState(() {
                                        _direction = value!;
                                        _selectedEntity = null;
                                        _selectedSubcategory = null;
                                        _subcategories.clear();
                                      });
                                      _loadData();
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: Text(tr.receipt),
                                    value: 'receipt',
                                    groupValue: _direction,
                                    onChanged: (value) {
                                      setState(() {
                                        _direction = value!;
                                        _selectedEntity = null;
                                        _selectedSubcategory = null;
                                        _subcategories.clear();
                                      });
                                      _loadData();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr.entity,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedEntity,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: tr.pleaseSelectEntity,
                              ),
                              items: _entities.map((entity) {
                                return DropdownMenuItem<String>(
                                  value: entity.name,
                                  child: Text(entity.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedEntity = value;
                                  _selectedSubcategory = null;
                                  _subcategories.clear();
                                });
                                if (value != null && value != 'آخر') {
                                  _loadSubcategories(value);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return tr.pleaseSelectEntity;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr.type,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedType,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: tr.pleaseSelectType,
                              ),
                              items: _types.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type.name,
                                  child: Text(type.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return tr.pleaseSelectType;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr.paymentMethod,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _paymentMethod,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: tr.pleaseSelectPaymentMethod,
                              ),
                              items: _paymentMethods.map((method) {
                                return DropdownMenuItem<String>(
                                  value: method,
                                  child: Text(method),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _paymentMethod = value!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return tr.pleaseSelectPaymentMethod;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr.amount,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: tr.pleaseEnterAmount,
                                suffixText: tr.currency,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return tr.pleaseEnterAmount;
                                }
                                final amount = double.tryParse(value);
                                if (amount == null) {
                                  return tr.pleaseEnterValidAmount;
                                }
                                if (amount <= 0) {
                                  return tr.amountMustBeGreaterThanZero;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr.notes,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _notesController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: tr.notes,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr.date,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  DateFormat('dd/MM/yyyy - HH:mm')
                                      .format(_selectedDate),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _updateTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        tr.updateTransaction,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _updateTransaction() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedTransaction = model.Transaction(
          id: widget.transaction.id,
          direction: _direction,
          paymentMethod: _paymentMethod,
          amount: double.parse(_amountController.text),
          entity: _selectedEntity!,
          subcategory: _selectedSubcategory ?? _selectedEntity!,
          date: _selectedDate,
          type: _selectedType!,
          notes:
              _notesController.text.isNotEmpty ? _notesController.text : null,
        );

        await _databaseService.updateTransaction(updatedTransaction);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث المعاملة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        widget.onTransactionUpdated();
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث المعاملة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteTransaction() {
    final tr = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.deleteTransaction),
        content: Text(tr.areYouSureDeleteTransaction),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (widget.transaction.id != null) {
                await _databaseService
                    .deleteTransaction(widget.transaction.id!);
              }
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close edit screen
                widget.onTransactionUpdated();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(tr.deleteTransaction),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
