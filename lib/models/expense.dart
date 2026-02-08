import 'category.dart';

class Expense {
  final String id;
  final double amount;
  final String note;
  final ExpenseCategory category;
  final DateTime date;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.amount,
    required this.note,
    required this.category,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'category': category.toJson(),
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] ?? '',
      category: ExpenseCategory.fromString(json['category'] ?? 'other'),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Expense copyWith({
    String? id,
    double? amount,
    String? note,
    ExpenseCategory? category,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
