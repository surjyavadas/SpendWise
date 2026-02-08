import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../utils/datetime_utils.dart';
import '../utils/currency_formatter.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDate;
  final int index;

  const ExpenseTile({
    super.key,
    required this.expense,
    this.onTap,
    this.onDelete,
    this.showDate = true,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      child: AnimatedSlide(
        offset: Offset.zero,
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.dark.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              onTap: onTap,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    expense.category.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              title: Text(
                expense.note.isNotEmpty
                    ? expense.note
                    : expense.category.displayName,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${expense.category.displayName}${showDate ? ' • ${DateTimeUtils.formatRelativeDate(expense.date)}' : ''}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              trailing: Text(
                CurrencyFormatter.format(expense.amount),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryBadge extends StatelessWidget {
  final ExpenseCategory category;
  final double amount;
  final double percentage;

  const CategoryBadge({
    super.key,
    required this.category,
    required this.amount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dark.withOpacity(0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Center(
              child: Text(
                category.emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.displayName.split(' ').first,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatCompactAmount(amount),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
