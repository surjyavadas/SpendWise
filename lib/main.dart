import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/storage_service.dart';
import 'providers/expense_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SpendWiseApp());
}

class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Storage service (low-level dependency)
        Provider<StorageService>(
          create: (_) => SharedPreferencesStorageService(),
        ),

        // Expense provider (depends on StorageService)
        ChangeNotifierProvider<ExpenseProvider>(
          create: (context) => ExpenseProvider(
            storageService: context.read<StorageService>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SpendWise',

        // THEME (light only, no dark mode)
        theme: AppTheme.lightTheme,

        // Entry screen
        home: const HomeScreen(),
      ),
    );
  }
}
