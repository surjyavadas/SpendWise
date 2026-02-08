import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../services/storage_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final StorageService storageService;

  List<Expense> _expenses = [];
  Budget _budget = Budget(monthlyLimit: 5000.0);
  bool _isLoading = false;
  String? _error;

  // Undo functionality
  Expense? _lastDeletedExpense;
  int? _lastDeletedIndex;

  ExpenseProvider({required this.storageService});

  // Getters
  List<Expense> get expenses => _expenses;
  Budget get budget => _budget;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalSpent =>
      _expenses.fold(0, (sum, e) => sum + e.amount);
  double get remaining => _budget.monthlyLimit - totalSpent;
  bool get canUndo => _lastDeletedExpense != null;

  /// Get budget usage percentage clamped between 0 and 100
  double get budgetUsagePercentage {
    if (_budget.monthlyLimit <= 0) return 0;
    final percentage = (totalSpent / _budget.monthlyLimit) * 100;
    return percentage.clamp(0.0, 100.0);
  }

  /// Check if over budget
  bool get isOverBudget => totalSpent > _budget.monthlyLimit;

  /// Get over-budget amount (positive if over)
  double get overBudgetAmount {
    final diff = totalSpent - _budget.monthlyLimit;
    return diff > 0 ? diff : 0;
  }

  /// Get remaining budget, never negative
  double get remainingBudgetSafe {
    return remaining > 0 ? remaining : 0;
  }

  // Load data
  Future<void> loadData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _expenses = await storageService.loadExpenses();
      _budget = await storageService.loadBudget();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add expense
  Future<void> addExpense(Expense expense) async {
    try {
      _expenses.add(expense);
      await storageService.saveExpenses(_expenses);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add expense: $e';
      notifyListeners();
    }
  }

  // Delete expense with undo
  Future<void> deleteExpense(int index) async {
    try {
      if (index < 0 || index >= _expenses.length) return;

      _lastDeletedExpense = _expenses[index];
      _lastDeletedIndex = index;

      _expenses.removeAt(index);
      await storageService.saveExpenses(_expenses);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete expense: $e';
      notifyListeners();
    }
  }

  // Undo delete
  Future<void> undoDelete() async {
    try {
      if (_lastDeletedExpense != null && _lastDeletedIndex != null) {
        _expenses.insert(_lastDeletedIndex!, _lastDeletedExpense!);
        await storageService.saveExpenses(_expenses);
        _lastDeletedExpense = null;
        _lastDeletedIndex = null;
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to undo delete: $e';
      notifyListeners();
    }
  }

  // Update budget
  Future<void> updateBudget(double amount) async {
    try {
      _budget = _budget.copyWith(monthlyLimit: amount);
      await storageService.saveBudget(_budget);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update budget: $e';
      notifyListeners();
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    try {
      _expenses = [];
      _budget = Budget(monthlyLimit: 5000.0);
      await storageService.clear();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear data: $e';
      notifyListeners();
    }
  }
}
