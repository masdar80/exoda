import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/file_manager_service.dart';
import '../services/database_service.dart';
import '../models/file_info.dart';
import 'home_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FileSelectorScreen extends StatefulWidget {
  final Function(String fileName) onFileSelected;
  final Function(Locale)? onLanguageChange;

  const FileSelectorScreen({
    super.key,
    required this.onFileSelected,
    this.onLanguageChange,
  });

  @override
  State<FileSelectorScreen> createState() => _FileSelectorScreenState();
}

class _FileSelectorScreenState extends State<FileSelectorScreen> {
  final FileManagerService _fileManager = FileManagerService();
  final DatabaseService _databaseService = DatabaseService();
  List<FileInfo> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final files = await _fileManager.getAllFiles();
      if (mounted) {
        setState(() {
          _files = files;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الملفات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectFile(FileInfo fileInfo) async {
    print('🎯 بدء اختيار الملف: ${fileInfo.name} (${fileInfo.fileName})');
    
    if (fileInfo.hasPassword) {
      print('🔒 الملف محمي بكلمة مرور، طلب كلمة المرور...');
      final password = await _showPasswordDialog();
      if (password == null || !mounted) {
        print('❌ تم إلغاء إدخال كلمة المرور');
        return;
      }

      print('🔑 التحقق من كلمة المرور...');
      final isValid = await _fileManager.verifyPassword(fileInfo.id!, password);
      if (!mounted) return;
      
      if (!isValid) {
        print('❌ كلمة المرور غير صحيحة');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('كلمة المرور غير صحيحة'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      print('✅ كلمة المرور صحيحة');
    }

    print('⏰ تحديث وقت الوصول...');
    await _fileManager.updateLastAccessed(fileInfo.id!);
    
    print('📁 تعيين الملف كحالي...');
    _fileManager.setCurrentFile(fileInfo.fileName);
    
    print('🔄 تبديل قاعدة البيانات...');
    await _databaseService.switchToFile(fileInfo.fileName);
    
    // التأكد من أن الـ widget ما زال موجود قبل التنقل
    if (mounted) {
      print('🚀 التنقل المباشر للشاشة الرئيسية...');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            onLanguageChange: widget.onLanguageChange ?? (locale) {},
          ),
        ),
      );
    } else {
      print('❌ Widget غير متاح، لا يمكن الانتقال');
    }
  }

  Future<String?> _showPasswordDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('أدخل كلمة المرور'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'كلمة المرور',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  Future<void> _createNewFile() async {
    print('🆕 بدء إنشاء ملف جديد...');
    
    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => _CreateFileDialog(),
    );

    if (result != null && mounted) {
      try {
        print('📝 إنشاء ملف بالاسم: ${result['name']}');
        print('🔒 محمي بكلمة مرور: ${result['password'] != null}');
        
        final fileInfo = await _fileManager.createNewFile(
          result['name']!,
          password: result['password'],
        );
        
        print('✅ تم إنشاء الملف: ${fileInfo.name} (${fileInfo.fileName})');

        // إنشاء قاعدة بيانات جديدة للملف
        print('🔄 تبديل قاعدة البيانات للملف الجديد...');
        await _databaseService.switchToFile(fileInfo.fileName);
        
        // تحديد هذا الملف كافتراضي إذا كان الوحيد
        if (_files.isEmpty) {
          print('⭐ تعيين الملف كافتراضي...');
          await _fileManager.setDefaultFile(fileInfo.id!);
        }

        // التأكد من أن الـ widget ما زال موجود قبل التنقل
        if (mounted) {
          print('🚀 التنقل المباشر للشاشة الرئيسية...');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                onLanguageChange: widget.onLanguageChange ?? (locale) {},
              ),
            ),
          );
        } else {
          print('❌ Widget غير متاح، لا يمكن الانتقال');
        }
        
      } catch (e) {
        print('❌ خطأ في إنشاء الملف: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في إنشاء الملف: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (result == null) {
      print('❌ تم إلغاء إنشاء الملف');
    } else {
      print('❌ Widget غير متاح عند إنشاء الملف');
    }
  }

  Future<void> _deleteFile(FileInfo fileInfo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف الملف "${fileInfo.name}"؟\nستفقد جميع البيانات الموجودة فيه نهائياً.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await _fileManager.deleteFile(fileInfo.id!);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الملف بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          _loadFiles();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل في حذف الملف'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر ملف'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // زر إنشاء ملف جديد
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _createNewFile,
                      icon: const Icon(Icons.add),
                      label: const Text('إنشاء ملف جديد'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),

                // قائمة الملفات
                Expanded(
                  child: _files.isEmpty
                      ? Center(
                          child: Text(
                            tr.noFiles,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _files.length,
                          itemBuilder: (context, index) {
                            final file = _files[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: file.isDefault ? Colors.green : Colors.blue,
                                  child: Icon(
                                    file.hasPassword ? Icons.lock : Icons.folder,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  file.name,
                                  style: TextStyle(
                                    fontWeight: file.isDefault ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('تاريخ الإنشاء: ${DateFormat('dd/MM/yyyy').format(file.createdAt)}'),
                                    Text('آخر دخول: ${DateFormat('dd/MM/yyyy HH:mm').format(file.lastAccessed)}'),
                                    if (file.isDefault)
                                      const Text(
                                        'الملف الافتراضي',
                                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                      ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'default':
                                        _fileManager.setDefaultFile(file.id!);
                                        _loadFiles();
                                        break;
                                      case 'delete':
                                        _deleteFile(file);
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    if (!file.isDefault)
                                      const PopupMenuItem(
                                        value: 'default',
                                        child: Text('تعيين كافتراضي'),
                                      ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('حذف'),
                                    ),
                                  ],
                                ),
                                onTap: () => _selectFile(file),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _CreateFileDialog extends StatefulWidget {
  @override
  State<_CreateFileDialog> createState() => _CreateFileDialogState();
}

class _CreateFileDialogState extends State<_CreateFileDialog> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _hasPassword = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedLanguage = 'ar';

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return AlertDialog(
      title: const Text('إنشاء ملف جديد'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: tr.fileName,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: InputDecoration(
                labelText: tr.defaultLanguage,
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'es', child: Text('Español')),
                DropdownMenuItem(value: 'el', child: Text('Ελληνικά')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value ?? 'ar';
                });
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: Text(tr.passwordProtection),
              value: _hasPassword,
              onChanged: (value) {
                setState(() {
                  _hasPassword = value ?? false;
                  if (!_hasPassword) {
                    _passwordController.clear();
                    _confirmPasswordController.clear();
                  }
                });
              },
            ),
            if (_hasPassword) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: tr.password,
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: tr.confirmPassword,
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(tr.pleaseEnterFileName)),
              );
              return;
            }

            if (_hasPassword) {
              if (_passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(tr.pleaseEnterPassword)),
                );
                return;
              }

              if (_passwordController.text != _confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(tr.passwordsDoNotMatch)),
                );
                return;
              }
            }

            Navigator.of(context).pop({
              'name': _nameController.text.trim(),
              'password': _hasPassword ? _passwordController.text : null,
              'language': _selectedLanguage,
            });
          },
          child: Text(tr.create),
        ),
      ],
    );
  }
} 