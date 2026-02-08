import '../models/budget.dart';
import '../models/expense.dart';

/// Warning levels and budget threshold alerts
class WarningService {
  /// Budget warning information
  static WarningLevel? getBudgetWarning(
    double totalSpent,
    Budget budget,
  ) {
    final usagePercentage = (totalSpent / budget.monthlyLimit) * 100;

    if (usagePercentage >= 90) {
      final remaining = (budget.monthlyLimit - totalSpent).clamp(0.0, double.infinity);
      return WarningLevel(
        severity: Severity.critical,
        title: 'Budget Limit Approaching',
        message: 'You\'ve spent ${usagePercentage.toStringAsFixed(0)}% of your monthly budget. Only ₹${remaining.toStringAsFixed(0)} remains.',
        percentage: usagePercentage,
      );
    } else if (usagePercentage >= 70) {
      return WarningLevel(
        severity: Severity.warning,
        title: 'Budget at 70%',
        message: 'You\'ve used ${usagePercentage.toStringAsFixed(0)}% of your budget. Consider tracking upcoming expenses carefully.',
        percentage: usagePercentage,
      );
    }

    return null;
  }

  /// Estimate days until budget runs out
  static int estimateDaysUntilBudgetRunsOut(
    double totalSpent,
    Budget budget,
    List<Expense> expenses,
  ) {
    if (expenses.isEmpty) return -1;

    // Calculate daily average from last 7 days or all expenses if fewer
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    
    final recentExpenses = expenses
        .where((e) => e.date.isAfter(oneWeekAgo))
        .toList();

    if (recentExpenses.isEmpty) return -1;

    final dailyAverage = recentExpenses
        .fold<double>(0, (sum, e) => sum + e.amount) / 7; // 7-day average

    if (dailyAverage <= 0) return -1;

    final remaining = budget.monthlyLimit - totalSpent;
    return (remaining / dailyAverage).ceil();
  }

  /// Get category spending breakdown
  static Map<String, double> getCategoryPercentages(
    double totalSpent,
    List<Expense> expenses,
  ) {
    if (expenses.isEmpty) return {};

    final breakdown = <String, double>{};
    
    for (final expense in expenses) {
      final category = expense.category.toString();
      breakdown[category] = (breakdown[category] ?? 0) + expense.amount;
    }

    return breakdown.map(
      (category, amount) => MapEntry(
        category,
        (amount / totalSpent) * 100,
      ),
    );
  }
}

enum Severity {
  info,
  warning,
  critical,
}

class WarningLevel {
  final Severity severity;
  final String title;
  final String message;
  final double percentage; // Budget usage percentage

  WarningLevel({
    required this.severity,
    required this.title,
    required this.message,
    required this.percentage,
  });

  bool get isCritical => severity == Severity.critical;
  bool get isWarning => severity == Severity.warning;
}
