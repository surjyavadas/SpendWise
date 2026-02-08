import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/expense.dart';
import '../models/budget.dart';

abstract class StorageService {
  Future<void> saveExpenses(List<Expense> expenses);
  Future<List<Expense>> loadExpenses();
  Future<void> saveBudget(Budget budget);
  Future<Budget> loadBudget();
  Future<void> clear();
}

class SharedPreferencesStorageService implements StorageService {
  static const String _expensesKey = 'expenses';
  static const String _budgetKey = 'budget';
  late SharedPreferences _prefs;

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveExpenses(List<Expense> expenses) async {
    await _initialize();
    final jsonList =
        expenses.map((e) => json.encode(e.toJson())).toList();
    await _prefs.setStringList(_expensesKey, jsonList);
  }

  @override
  Future<List<Expense>> loadExpenses() async {
    await _initialize();
    final jsonList = _prefs.getStringList(_expensesKey) ?? [];
    return jsonList
        .map((e) => Expense.fromJson(json.decode(e)))
        .toList();
  }

  @override
  Future<void> saveBudget(Budget budget) async {
    await _initialize();
    await _prefs.setString(_budgetKey, json.encode(budget.toJson()));
  }

  @override
  Future<Budget> loadBudget() async {
    await _initialize();
    final jsonStr = _prefs.getString(_budgetKey);
    if (jsonStr == null) {
      return Budget(monthlyLimit: 5000.0);
    }
    return Budget.fromJson(json.decode(jsonStr));
  }

  @override
  Future<void> clear() async {
    await _initialize();
    await _prefs.clear();
  }
}
