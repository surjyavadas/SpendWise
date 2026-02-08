import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../utils/haptic_feedback.dart' as hf;

/// Dialog for scanning receipts (scaffolding for OCR)
class ScanReceiptDialog extends StatefulWidget {
  final Function(Expense) onExpenseScanned;

  const ScanReceiptDialog({
    super.key,
    required this.onExpenseScanned,
  });

  @override
  State<ScanReceiptDialog> createState() => _ScanReceiptDialogState();
}

class _ScanReceiptDialogState extends State<ScanReceiptDialog> {
  bool _isScanning = false;
  ExpenseCategory? _selectedCategory;
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    hf.HapticService.medium();
    
    setState(() => _isScanning = true);

    // TODO: Integrate camera + ML Kit OCR here
    // For MVP: Show placeholder dialog
    await Future.delayed(const Duration(seconds: 1)); // Simulate scanning

    if (mounted) {
      setState(() => _isScanning = false);
      
      // Show snackbar that OCR is coming soon
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('OCR scanning coming soon. Please enter details manually.'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _createExpense() {
    hf.HapticService.light();

    final amount = double.tryParse(_amountController.text.trim());
    final category = _selectedCategory;

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      note: _noteController.text.trim(),
      category: category,
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );

    widget.onExpenseScanned(expense);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Expense',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Camera section (OCR placeholder)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.camera_alt_rounded,
                      size: 40,
                      color: AppColors.primary.withOpacity(0.6),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Scan Receipt\n(Coming Soon)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.gray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isScanning ? null : _openCamera,
                      icon: _isScanning
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.camera_rounded, size: 18),
                      label: Text(_isScanning ? 'Scanning...' : 'Open Camera'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Manual entry form
              Text(
                'Manual Entry',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),

              // Amount field
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Amount (₹)',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Category selector
              Text(
                'Category',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ExpenseCategory.values.map((category) {
                  return FilterChip(
                    label: Text('${category.emoji} ${category.displayName}'),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                      hf.HapticService.light();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Note field
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: 'Note (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _createExpense,
                      child: const Text('Add Expense'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
