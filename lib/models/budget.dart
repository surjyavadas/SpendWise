class Budget {
  final double monthlyLimit;
  final DateTime updatedAt;

  Budget({
    required this.monthlyLimit,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'monthlyLimit': monthlyLimit,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      monthlyLimit: (json['monthlyLimit'] as num?)?.toDouble() ?? 5000.0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Budget copyWith({
    double? monthlyLimit,
    DateTime? updatedAt,
  }) {
    return Budget(
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
