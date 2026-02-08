import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../services/insights_service.dart';
import '../services/warning_service.dart';
import '../services/tips_service.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../utils/haptic_feedback.dart' as hf;
import '../widgets/common_widgets.dart';
import '../widgets/expense_widgets.dart';
import '../widgets/layout_widgets.dart';
import '../widgets/warning_widgets.dart';
import '../widgets/scan_widgets.dart';
import 'add_expense_screen.dart';
import 'budget_screen.dart';
import 'settings_screen.dart';
import 'scan_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hideWarning = false;
  bool _hideTip = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadData();
    });
  }

  void _showSnackbar(String message, {bool isError = false}) {
    hf.HapticService.light();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showUndoSnackbar() {
    hf.HapticService.success();
    final provider = context.read<ExpenseProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Expense deleted'),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.primary,
          onPressed: () {
            provider.undoDelete();
            _showSnackbar('Expense restored');
          },
        ),
        backgroundColor: AppColors.dark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showScanDialog() {
    hf.HapticService.medium();
    final provider = context.read<ExpenseProvider>();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ScanExpenseScreen(
          onExpenseScanned: (expense) async {
            await provider.addExpense(expense);
            if (mounted) {
              _showSnackbar('Expense added from scan! 📸');
            }
          },
        ),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpendWise'),
        elevation: 0,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: 'Menu',
            onSelected: (value) {
              hf.HapticService.light();
              if (value == 'scan') {
                _showScanDialog();
              } else if (value == 'budget') {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const BudgetScreen(),
                    transitionsBuilder: (_, animation, __, child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ),
                        ),
                        child: child,
                      );
                    },
                  ),
                );
              } else if (value == 'settings') {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const SettingsScreen(),
                    transitionsBuilder: (_, animation, __, child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ),
                        ),
                        child: child,
                      );
                    },
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'scan',
                child: Row(
                  children: [
                    Icon(Icons.camera_alt_rounded, size: 20),
                    const SizedBox(width: 12),
                    const Text('Scan Receipt'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'budget',
                child: Row(
                  children: [
                    Icon(Icons.wallet_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Budget & Stats'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget(
              message: 'Loading your expenses...',
            );
          }

          // Get warning level
          final warning = _hideWarning 
              ? null 
              : WarningService.getBudgetWarning(provider.totalSpent, provider.budget);
          
          // Get contextual tip
          final tip = _hideTip ? null : TipsService.generateContextualTip(provider.expenses);

          return RefreshIndicator(
            onRefresh: () => provider.loadData(),
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              children: [
                // Warning card (if any)
                if (warning != null)
                  WarningCard(
                    warning: warning,
                    onDismiss: () {
                      setState(() => _hideWarning = true);
                    },
                  )
                else
                  const SizedBox(height: 16),
                
                // Tip card (if any)
                if (tip != null && !_hideWarning)
                  TipCard(
                    tip: tip,
                    onDismiss: () {
                      setState(() => _hideTip = true);
                    },
                  ),

                // Main content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      _buildBudgetCard(provider),
                      const SizedBox(height: 32),
                      if (provider.expenses.isNotEmpty) ...[
                        _buildInsightsSection(provider),
                        const SizedBox(height: 32),
                        _buildStatsGrid(provider),
                        const SizedBox(height: 32),
                        _buildCategorySection(provider),
                        const SizedBox(height: 32),
                      ],
                      _buildRecentExpensesSection(provider),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          hf.HapticService.medium();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const AddExpenseScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: animation.drive(
                    Tween(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ),
                  ),
                  child: child,
                );
              },
            ),
          ).then((value) {
            if (value == true) {
              _showSnackbar('Expense added successfully! 🎉');
            }
          });
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildBudgetCard(ExpenseProvider provider) {
    final isOverBudget = provider.isOverBudget;
    final percentage = provider.budgetUsagePercentage / 100; // 0.0 to 1.0

    return GradientCard(
      gradient: isOverBudget
          ? LinearGradient(
              colors: [Color(0xFFF87171), Color(0xFFDC2626)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : AppColors.primaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Month',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOverBudget ? 'Over Budget' : 'On Track',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isOverBudget
                ? CurrencyFormatter.format(provider.overBudgetAmount)
                : CurrencyFormatter.format(provider.remainingBudgetSafe),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            isOverBudget
                ? 'over your budget'
                : 'remaining of ${CurrencyFormatter.format(provider.budget.monthlyLimit)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(
                Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.budgetUsagePercentage.toStringAsFixed(0)}% used',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(ExpenseProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Smart Insights'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.secondaryLight.withOpacity(0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InsightCard(
                icon: Icons.lightbulb_outline,
                text: InsightsService.getTrendInsight(provider.expenses),
                iconColor: AppColors.secondary.withOpacity(0.8),
              ),
              const SizedBox(height: 8),
              Container(
                height: 1,
                color: AppColors.secondary.withOpacity(0.1),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
              const SizedBox(height: 8),
              InsightCard(
                icon: Icons.trending_up,
                text: InsightsService.getMonthlyComparison(provider.expenses),
                iconColor: AppColors.secondary.withOpacity(0.8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(ExpenseProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Overview'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [
            StatCard(
              icon: Icons.wallet_rounded,
              label: 'Total Spent',
              value: CurrencyFormatter.format(provider.totalSpent),
              backgroundColor: AppColors.primaryLight.withOpacity(0.3),
              textColor: AppColors.primary,
            ),
            StatCard(
              icon: Icons.trending_down_rounded,
              label: 'Average',
              value: provider.expenses.isEmpty
                  ? '₹0'
                  : CurrencyFormatter.format(
                      provider.totalSpent / provider.expenses.length),
              backgroundColor: AppColors.accentLight.withOpacity(0.3),
              textColor: AppColors.accent,
            ),
            StatCard(
              icon: Icons.receipt_rounded,
              label: 'Entries',
              value: provider.expenses.length.toString(),
              backgroundColor: AppColors.secondaryLight.withOpacity(0.3),
              textColor: AppColors.secondary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection(ExpenseProvider provider) {
    final breakdown = InsightsService.getCategoryBreakdown(provider.expenses);
    
    if (breakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = provider.totalSpent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Spending by Category'),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: breakdown.length,
            itemBuilder: (_, index) {
              final entry = breakdown.entries.toList()[index];
              final percentage = (entry.value / total) * 100;
              
              return Padding(
                padding: EdgeInsets.only(
                  right: index == breakdown.length - 1 ? 0 : 12,
                ),
                child: CategoryBadge(
                  category: entry.key,
                  amount: entry.value,
                  percentage: percentage,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentExpensesSection(ExpenseProvider provider) {
    if (provider.expenses.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.receipt_long,
        title: 'No Expenses Yet',
        subtitle: 'Start tracking your spending by adding your first expense!',
        actionLabel: 'Add Expense',
        onAction: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddExpenseScreen(),
            ),
          );
        },
      );
    }

    final sorted = List<dynamic>.from(provider.expenses)..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Recent Expenses'),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sorted.length,
          itemBuilder: (_, index) {
            final expense = sorted[index];
            return ExpenseTile(
              expense: expense,
              index: index,
              onDelete: () {
                hf.HapticService.medium();
                final expenseIndex = provider.expenses.indexOf(expense);
                provider.deleteExpense(expenseIndex);
                _showUndoSnackbar();
              },
            );
          },
        ),
      ],
    );
  }
}
