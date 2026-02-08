class Expense {
  final double amount;
  final String note;
  final String category;
  final DateTime date;

  Expense({
    required this.amount,
    required this.note,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'note': note,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      amount: json['amount'],
      note: json['note'],
      category: json['category'],
      date: DateTime.parse(json['date']),
    );
  }
}
