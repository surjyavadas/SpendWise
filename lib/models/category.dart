enum ExpenseCategory {
  food('🍔', 'Food & Dining'),
  travel('✈️', 'Travel'),
  shopping('🛍️', 'Shopping'),
  entertainment('🎬', 'Entertainment'),
  utilities('💡', 'Utilities'),
  healthcare('🏥', 'Healthcare'),
  education('📚', 'Education'),
  fitness('🏋️', 'Fitness'),
  other('💰', 'Other');

  final String emoji;
  final String displayName;

  const ExpenseCategory(this.emoji, this.displayName);

  static ExpenseCategory fromString(String value) {
    try {
      return ExpenseCategory.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return ExpenseCategory.other;
    }
  }

  String toJson() => name;
}
