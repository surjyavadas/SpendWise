import '../models/expense.dart';
import '../models/category.dart';

/// Scanned receipt data (scaffolding for OCR integration)
class ScannedReceipt {
  final double? amount;
  final DateTime? date;
  final String? merchantName;
  final double confidence; // 0.0 to 1.0

  ScannedReceipt({
    this.amount,
    this.date,
    this.merchantName,
    this.confidence = 0.0,
  });

  /// Check if scan has enough confidence for most fields
  bool get hasGoodConfidence => confidence >= 0.7;

  /// Convert to expense (user must provide category)
  Expense toExpense(ExpenseCategory category) {
    return Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount ?? 0.0,
      note: merchantName ?? 'Scanned receipt',
      category: category,
      date: date ?? DateTime.now(),
      createdAt: DateTime.now(),
    );
  }
}

/// Service for receipt scanning (scaffolding for ML Kit OCR)
/// 
/// SCAFFOLDING NOTES:
/// - This service is prepared for ML Kit integration
/// - Future: Use firebase_ml_vision or google_mlkit_text_recognition
/// - For MVP: Manual entry only with scanning UI
class ReceiptScannerService {
  /// Mock OCR result (placeholder for ML Kit integration)
  /// In production, this would use actual device camera and ML Kit
  static Future<ScannedReceipt?> scanReceipt() async {
    // TODO: Integrate with google_mlkit_text_recognition or firebase_ml_vision
    // - Capture image from device camera
    // - Extract text using OCR
    // - Parse amount, date, merchant
    // - Return ScannedReceipt with confidence scores
    
    // For MVP, return null to indicate no OCR available yet
    return null;
  }

  /// Parse amount from text (helper for future OCR)
  static double? extractAmount(String text) {
    // TODO: Implement currency parsing logic
    // Look for patterns like ₹XXX, $XXX, XXX INR, etc.
    final patterns = [
      RegExp(r'₹\s*([\d,]+\.?\d*)'),
      RegExp(r'\$\s*([\d,]+\.?\d*)'),
      RegExp(r'([\d,]+\.?\d*)\s*INR'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        final amountStr = match.group(1)?.replaceAll(',', '') ?? '';
        return double.tryParse(amountStr);
      }
    }
    return null;
  }

  /// Parse date from text (helper for future OCR)
  static DateTime? extractDate(String text) {
    // TODO: Implement date parsing logic
    // Look for patterns like DD/MM/YYYY, MM-DD-YYYY, etc.
    return null;
  }
}
