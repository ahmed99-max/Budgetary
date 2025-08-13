import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 4)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? icon;

  @HiveField(3)
  String? color;

  CategoryModel({this.id, this.name, this.icon, this.color});
}