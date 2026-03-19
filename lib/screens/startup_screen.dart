import 'package:flutter/material.dart';
import '../services/file_manager_service.dart';
import '../services/database_service.dart';
import 'file_selector_screen.dart';
import 'home_screen.dart';
import 'package:exoda/l10n/app_localizations.dart';

class StartupScreen extends StatefulWidget {
  final Function(Locale)? onLanguageChange;

  const StartupScreen({super.key, this.onLanguageChange});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  final FileManagerService _fileManager = FileManagerService();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  bool _hasFiles = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // تحقق من وجود ملفات
      final files = await _fileManager.getAllFiles();

      if (files.isNotEmpty) {
        setState(() {
          _hasFiles = true;
          _isLoading = false;
        });

        // عرض شاشة اختيار الملفات
        await _showFileSelector();
      } else {
        // لا توجد ملفات، إنشاء ملف جديد
        setState(() {
          _hasFiles = false;
          _isLoading = false;
        });
        await _createFirstFile();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تهيئة التطبيق: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showFileSelector() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FileSelectorScreen(
          onFileSelected: _navigateToHome,
          onLanguageChange: widget.onLanguageChange,
        ),
      ),
    );
  }

  Future<void> _createFirstFile() async {
    final result = await showDialog<Map<String, String?>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _CreateFirstFileDialog(),
    );

    if (result != null) {
      // التحقق من وجود خطأ في النتيجة
      if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error']!),
            backgroundColor: Colors.red,
          ),
        );
        // إعادة عرض الحوار
        await _createFirstFile();
        return;
      }

      try {
        setState(() => _isLoading = true);

        final fileInfo = await _fileManager.createNewFile(
          result['name']!,
          password: result['password'],
        );

        // تعيين كملف افتراضي
        await _fileManager.setDefaultFile(fileInfo.id!);

        DatabaseService.initialLanguage = result['language'];

        // إنشاء قاعدة بيانات جديدة للملف
        await _databaseService.switchToFile(fileInfo.fileName);

        // التأكد من إغلاق حالة التحميل قبل التنقل
        setState(() => _isLoading = false);

        // الانتقال للشاشة الرئيسية مع تأخير صغير
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          _navigateToHome(fileInfo.fileName);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في إنشاء الملف: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _navigateToHome(String fileName) {
    if (!mounted) return;

    print('التنقل إلى الشاشة الرئيسية مع الملف: $fileName');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          onLanguageChange: widget.onLanguageChange ?? (locale) {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              tr.appTitle,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              tr.moneyManagementApp,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 50),
            if (_isLoading)
              const CircularProgressIndicator(color: Colors.white)
            else if (!_hasFiles)
              Text(
                tr.welcomeCreateFile,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CreateFirstFileDialog extends StatefulWidget {
  const _CreateFirstFileDialog();

  @override
  State<_CreateFirstFileDialog> createState() => _CreateFirstFileDialogState();
}

class _CreateFirstFileDialogState extends State<_CreateFirstFileDialog> {
  final _nameController = TextEditingController(text: 'ملفي الشخصي');
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
            Text(
              tr.createFileWelcome,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: tr.fileName,
                border: OutlineInputBorder(),
                hintText: tr.fileNameHint,
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
              subtitle: Text(tr.optional),
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
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: tr.confirmPassword,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              Navigator.of(context).pop({'error': 'يرجى إدخال اسم الملف'});
              return;
            }

            if (_hasPassword) {
              if (_passwordController.text.isEmpty) {
                Navigator.of(context).pop({'error': 'يرجى إدخال كلمة المرور'});
                return;
              }

              if (_passwordController.text != _confirmPasswordController.text) {
                Navigator.of(context)
                    .pop({'error': 'كلمات المرور غير متطابقة'});
                return;
              }
            }

            Navigator.of(context).pop({
              'name': _nameController.text.trim(),
              'password': _hasPassword ? _passwordController.text : null,
              'language': _selectedLanguage,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          child: const Text('ابدأ الآن'),
        ),
      ],
    );
  }
}
