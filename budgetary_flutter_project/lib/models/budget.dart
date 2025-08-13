class Budget {
  final String id;
  final String category;
  double amount; // total allocated
  double spent; // amount spent
  List<BudgetExpense> expenses;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    this.spent = 0,
    List<BudgetExpense>? expenses,
  }) : expenses = expenses ?? [];
}

class BudgetExpense {
  final String id;
  final String description;
  final double amount;
  final DateTime date;

  BudgetExpense({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
  });
}

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  double currentAmount;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
  });
}
