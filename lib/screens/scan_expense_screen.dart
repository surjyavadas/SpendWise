import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

import '../theme/app_theme.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../utils/currency_formatter.dart';
import '../utils/haptic_feedback.dart' as hf;

class ScanExpenseScreen extends StatefulWidget {
  final Function(Expense) onExpenseScanned;
  const ScanExpenseScreen({super.key, required this.onExpenseScanned});

  @override
  State<ScanExpenseScreen> createState() => _ScanExpenseScreenState();
}

class _ScanExpenseScreenState extends State<ScanExpenseScreen> {
  final ImagePicker _picker = ImagePicker();
  final textRecognizer = TextRecognizer();
  
  File? _selectedImage;
  bool _isProcessing = false;
  String _extractedText = '';
  double? _detectedAmount;
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
    textRecognizer.close();
    super.dispose();
  }

  Future<void> _captureImage() async {
    hf.HapticService.medium();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _selectedImage = File(image.path));
      _processImage(File(image.path));
    }
  }

  Future<void> _pickImage() async {
    hf.HapticService.medium();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _selectedImage = File(image.path));
      _processImage(File(image.path));
    }
  }

  Future<void> _processImage(File imageFile) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await textRecognizer.processImage(inputImage);

      _extractedText = recognizedText.text;
      _detectedAmount = _extractAmount(_extractedText);

      if (mounted) {
        setState(() => _isProcessing = false);
        
        // Auto-fill amount if detected
        if (_detectedAmount != null) {
          _amountController.text = _detectedAmount!.toStringAsFixed(2);
          hf.HapticService.success();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Detected: ₹${_detectedAmount!.toStringAsFixed(2)}'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Extract amount from OCR text using regex patterns
  double? _extractAmount(String text) {
    // Patterns for currency amounts
    final patterns = [
      RegExp(r'₹\s*([\d,]+\.?\d*)'),
      RegExp(r'Rs\s*[.:]*\s*([\d,]+\.?\d*)'),
      RegExp(r'\$([\d,]+\.?\d*)'),
      RegExp(r'amount[:\s]+([\d,]+\.?\d*)'),
      RegExp(r'total[:\s]+([\d,]+\.?\d*)'),
      RegExp(r'^([\d,]+\.?\d*)$', multiLine: true),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        final amountStr = match.group(1)?.replaceAll(',', '') ?? '';
        final amount = double.tryParse(amountStr);
        if (amount != null && amount > 0 && amount < 1000000) {
          return amount;
        }
      }
    }
    return null;
  }

  void _saveExpense() {
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
    hf.HapticService.success();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        elevation: 0,
      ),
      body: _selectedImage == null
          ? _buildCameraSelector()
          : _buildOCRResultForm(isDark),
    );
  }

  Widget _buildCameraSelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_rounded,
            size: 80,
            color: AppColors.primary.withOpacity(0.6),
          ),
          const SizedBox(height: 24),
          Text(
            'Capture Receipt',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Photograph your receipt to extract amount and details automatically',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _captureImage,
                icon: const Icon(Icons.camera_rounded),
                label: const Text('Take Photo'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image_rounded),
                label: const Text('From Gallery'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOCRResultForm(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Preview
          if (_selectedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _selectedImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 20),

          // Processing Indicator
          if (_isProcessing)
            Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(
                    'Extracting receipt data...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )
          else ...[
            // Extracted Text Display
            if (_extractedText.isNotEmpty) ...[
              Text('Extracted Text:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
                  ),
                ),
                child: Text(
                  _extractedText,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Amount Field
            Text('Amount *', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter amount (₹)',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Category Selector
            Text('Category *', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
            const SizedBox(height: 16),

            // Note Field
            Text('Note (Optional)', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Add a note...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                        _extractedText = '';
                        _detectedAmount = null;
                        _amountController.clear();
                        _noteController.clear();
                        _selectedCategory = null;
                      });
                    },
                    child: const Text('Retake Photo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveExpense,
                    child: const Text('Save Expense'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
