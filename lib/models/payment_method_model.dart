import 'package:hive/hive.dart';

part 'payment_method_model.g.dart';

@HiveType(typeId: 7)
class PaymentMethodModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? type;

  @HiveField(3)
  String? icon;

  PaymentMethodModel({this.id, this.name, this.type, this.icon});
}