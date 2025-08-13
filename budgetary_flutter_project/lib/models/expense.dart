class Expense {
  final String id;
  final String category;
  final String title;
  final String note;
  final String paymentMethod;
  final double amount;
  final DateTime date;

  Expense({
    required this.id,
    required this.category,
    required this.title,
    required this.note,
    required this.paymentMethod,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'note': note,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      title: map['title'] ?? '',
      note: map['note'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }
}
