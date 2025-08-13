import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 5)
class BudgetModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? categoryId;

  @HiveField(2)
  double? amount;

  @HiveField(3)
  double? spent;

  @HiveField(4)
  DateTime? month;

  BudgetModel({this.id, this.categoryId, this.amount, this.spent, this.month});

  static BudgetModel empty() => BudgetModel(amount: 0, spent: 0);
}