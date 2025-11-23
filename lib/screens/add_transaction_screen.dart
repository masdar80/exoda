import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/transaction.dart' as model;
import '../models/entity.dart';
import '../models/expense_type.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddTransactionScreen extends StatefulWidget {
  final VoidCallback onTransactionAdded;

  const AddTransactionScreen({
    super.key,
    required this.onTransactionAdded,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
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
    _loadData();
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
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSubcategories(AppLocalizations tr, String parentEntity) async {
    final subcategories = await _databaseService.getSubcategories(parentEntity);
    setState(() {
      _subcategories = subcategories;
      _selectedSubcategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr.addTransactionTitle),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tr.entity,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _showAddEntityDialog,
                                  icon: const Icon(Icons.add, size: 16),
                                  label: Text(tr.addEntity),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.teal,
                                  ),
                                ),
                              ],
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
                                if (value != null) {
                                  setState(() {
                                    _selectedEntity = value;
                                    _selectedSubcategory = null;
                                    _subcategories.clear();
                                  });
                                  if (value != tr.other) {
                                    _loadSubcategories(tr, value);
                                  } else {
                                    _showAddEntityDialog();
                                  }
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tr.type,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _showAddTypeDialog,
                                  icon: const Icon(Icons.add, size: 16),
                                  label: Text(tr.addType),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.teal,
                                  ),
                                ),
                              ],
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
                                if (value != null) {
                                  setState(() {
                                    _selectedType = value;
                                  });
                                  if (value == tr.other) {
                                    _showAddTypeDialog();
                                  }
                                }
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tr.paymentMethod,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _showAddPaymentMethodDialog,
                                  icon: const Icon(Icons.add, size: 16),
                                  label: Text(tr.addPaymentMethod),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.teal,
                                  ),
                                ),
                              ],
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
                                if (value != null) {
                                  setState(() {
                                    _paymentMethod = value;
                                  });
                                  if (value == 'آخر') {
                                    _showAddPaymentMethodDialog();
                                  }
                                }
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
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  DateFormat('dd/MM/yyyy - HH:mm').format(_selectedDate),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        tr.save,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showAddEntityDialog() {
    final tr = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.addEntity),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: tr.entityName,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _databaseService.insertEntity(
                  Entity(name: controller.text.trim(), type: _direction, isSubcategory: false),
                );
                Navigator.pop(context);
                await _loadData();
                setState(() {
                  _selectedEntity = controller.text.trim();
                });
              }
            },
            child: Text(tr.save),
          ),
        ],
      ),
    );
  }

  void _showAddTypeDialog() {
    final tr = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.addType),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: tr.typeName,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _databaseService.insertExpenseType(
                  ExpenseType(name: controller.text.trim()),
                );
                Navigator.pop(context);
                await _loadData();
                setState(() {
                  _selectedType = controller.text.trim();
                });
              }
            },
            child: Text(tr.save),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentMethodDialog() {
    final tr = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.addPaymentMethod),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: tr.paymentMethodName,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _databaseService.insertPaymentMethod(controller.text.trim());
                Navigator.pop(context);
                await _loadData();
                setState(() {
                  _paymentMethod = controller.text.trim();
                });
              }
            },
            child: Text(tr.save),
          ),
        ],
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

  Future<void> _saveTransaction() async {
    final tr = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      if (_selectedEntity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr.pleaseSelectEntity),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr.pleaseSelectType),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        final transaction = model.Transaction(
          direction: _direction,
          paymentMethod: _paymentMethod,
          amount: double.parse(_amountController.text),
          entity: _selectedEntity!,
          subcategory: _selectedSubcategory ?? _selectedEntity!,
          date: _selectedDate,
          type: _selectedType!,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );

        await _databaseService.insertTransaction(transaction);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr.transactionAdded),
            backgroundColor: Colors.green,
          ),
        );

        widget.onTransactionAdded();
        
        // Reset form
        _amountController.clear();
        setState(() {
          _selectedEntity = null;
          _selectedSubcategory = null;
          _selectedType = null;
          _selectedDate = DateTime.now();
          _subcategories.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr.error + ': $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
} 