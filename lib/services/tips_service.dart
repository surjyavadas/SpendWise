import '../models/expense.dart';

/// Contextual spending tips based on user behavior
class TipsService {
  /// Generate a single contextual tip based on spending patterns
  static String? generateContextualTip(List<Expense> expenses) {
    if (expenses.isEmpty) return null;

    // Category dominance tip
    final categoryBreakdown = _getCategoryBreakdown(expenses);
    for (final entry in categoryBreakdown.entries) {
      final percentage = entry.value;
      if (percentage > 40) {
        final categoryName = _getCategoryName(entry.key);
        return '$categoryName accounts for ${percentage.toStringAsFixed(0)}% of your spending. Consider reviewing these expenses.';
      }
    }

    // Many small expenses tip
    final smallExpenses = expenses.where((e) => e.amount < 50).length;
    if (smallExpenses > 10 && (smallExpenses / expenses.length) > 0.4) {
      return 'You have ${smallExpenses} small expenses. Try grouping similar purchases together for better tracking.';
    }

    // Spending trend tip
    if (expenses.length >= 10) {
      final lastWeek = DateTime.now().subtract(const Duration(days: 7));
      final thisWeek = expenses
          .where((e) => e.date.isAfter(lastWeek))
          .fold(0.0, (sum, e) => sum + (e.amount as num))
          .toDouble();

      final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
      final lastWeekExpenses = expenses
          .where((e) => e.date.isAfter(twoWeeksAgo) && e.date.isBefore(lastWeek))
          .fold(0.0, (sum, e) => sum + (e.amount as num))
          .toDouble();

      if (thisWeek > lastWeekExpenses && lastWeekExpenses > 0) {
        final increase = (((thisWeek - lastWeekExpenses) / lastWeekExpenses) * 100)
            .toStringAsFixed(0);
        return 'Your spending is ${increase}% higher than last week. Check which categories are driving this increase.';
      }
    }

    return null;
  }

  /// Get category breakdown as percentages
  static Map<String, double> _getCategoryBreakdown(List<Expense> expenses) {
    if (expenses.isEmpty) return {};

    final breakdown = <String, double>{};
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);

    for (final expense in expenses) {
      final category = expense.category.toString();
      breakdown[category] = (breakdown[category] ?? 0) + expense.amount;
    }

    return breakdown.map(
      (category, amount) => MapEntry(
        category,
        (amount / total) * 100,
      ),
    );
  }

  /// Get human-readable category name
  static String _getCategoryName(String categoryString) {
    // Parse "Category.food" to "Food"
    if (categoryString.contains('.')) {
      final parts = categoryString.split('.');
      if (parts.length > 1) {
        final name = parts.last;
        return name.charAt(0).toUpperCase() + name.substring(1);
      }
    }
    return categoryString;
  }
}

extension on String {
  String charAt(int index) => this[index];
}
