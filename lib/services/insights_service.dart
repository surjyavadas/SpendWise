import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/category.dart';

class InsightsService {
  /// Get only meaningful insights (statistically significant)
  static List<String> getMeaningfulInsights(List<Expense> expenses) {
    if (expenses.length < 5) return []; // Need minimum data
    
    final insights = <String>[];
    
    // Get this month's expenses
    final now = DateTime.now();
    final thisMonth = expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .toList();
    
    if (thisMonth.length < 3) return insights; // Need at least 3 this month
    
    final thisMonthTotal = thisMonth.fold<double>(0, (sum, e) => sum + e.amount);
    
    // Insight 1: Category dominance (>40%)
    final categoryBreakdown = getCategoryBreakdown(thisMonth);
    for (final entry in categoryBreakdown.entries) {
      final percentage = (entry.value / thisMonthTotal) * 100;
      if (percentage > 40) {
        insights.add('${entry.key.emoji} ${entry.key.displayName} accounts for ${percentage.toStringAsFixed(0)}% of your spending');
        break; // Only one category insight
      }
    }
    
    // Insight 2: Monthly trend (only if we have last month data)
    final lastMonth = expenses
        .where((e) => e.date.month == (now.month - 1 == 0 ? 12 : now.month - 1) &&
                      e.date.year == (now.month - 1 == 0 ? now.year - 1 : now.year))
        .toList();
    
    if (lastMonth.isNotEmpty) {
      final lastMonthTotal = lastMonth.fold<double>(0, (sum, e) => sum + e.amount);
      final diff = thisMonthTotal - lastMonthTotal;
      final percent = ((diff / lastMonthTotal) * 100).abs();
      
      if (percent > 15) { // Only show if >15% change
        if (diff < 0) {
          insights.add('📉 You\'re spending ${percent.toStringAsFixed(0)}% less than last month');
        } else {
          insights.add('📈 You\'re spending ${percent.toStringAsFixed(0)}% more than last month');
        }
      }
    }
    
    // Insight 3: Budget burn rate (if expenses are accelerating)
    if (thisMonth.length >= 7) {
      final firstWeek = thisMonth.where((e) => e.date.day <= 7).fold<double>(0, (sum, e) => sum + e.amount);
      final recentWeek = thisMonth.where((e) => e.date.day > now.day - 7).fold<double>(0, (sum, e) => sum + e.amount);
      
      if (firstWeek > 0 && recentWeek > firstWeek * 1.3) {
        insights.add('⚡ Your daily spending is accelerating');
      }
    }
    
    return insights;
  }

  static String getTrendInsight(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return "Start tracking your expenses to get insights!";
    }

    final now = DateTime.now();
    final thisMonth = expenses
        .where((e) =>
            e.date.month == now.month && e.date.year == now.year)
        .toList();

    if (thisMonth.isEmpty) {
      return "No expenses this month. Good job staying mindful!";
    }

    final total = thisMonth.fold<double>(0, (sum, e) => sum + e.amount);
    final average = total / thisMonth.length;
    final maxExpense =
        thisMonth.reduce((a, b) => a.amount > b.amount ? a : b);

    final trends = <String>[];
    if (average > 500) {
      trends.add("Your average expense is ₹${average.toStringAsFixed(0)} - consider budgeting!");
    }
    if (maxExpense.amount > 2000) {
      trends.add("Your highest expense was ₹${maxExpense.amount.toStringAsFixed(0)} on ${maxExpense.category.emoji} ${maxExpense.category.displayName}");
    }

    return trends.isNotEmpty
        ? trends.join(" | ")
        : "You're maintaining consistent spending!";
  }

  static Map<ExpenseCategory, double> getCategoryBreakdown(
      List<Expense> expenses) {
    final breakdown = <ExpenseCategory, double>{};
    for (final expense in expenses) {
      breakdown[expense.category] =
          (breakdown[expense.category] ?? 0) + expense.amount;
    }
    return breakdown;
  }

  static String getTopCategory(List<Expense> expenses) {
    if (expenses.isEmpty) return "N/A";

    final breakdown = getCategoryBreakdown(expenses);
    final topCategory = breakdown.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return "${topCategory.emoji} ${topCategory.displayName}";
  }

  static String getMonthlyComparison(List<Expense> expenses) {
    final now = DateTime.now();
    final thisMonth = expenses
        .where((e) =>
            e.date.month == now.month && e.date.year == now.year)
        .fold<double>(0, (sum, e) => sum + e.amount);

    final lastMonth = expenses
        .where((e) =>
            e.date.month == (now.month - 1 == 0 ? 12 : now.month - 1) &&
            e.date.year == (now.month - 1 == 0 ? now.year - 1 : now.year))
        .fold<double>(0, (sum, e) => sum + e.amount);

    if (lastMonth == 0) {
      return "First month of tracking!";
    }

    final diff = thisMonth - lastMonth;
    final percent = ((diff / lastMonth) * 100).toStringAsFixed(1);

    if (diff > 0) {
      return "📈 $percent% more than last month";
    } else {
      return "📉 ${percent.replaceFirst('-', '')}% less than last month";
    }
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }
}
