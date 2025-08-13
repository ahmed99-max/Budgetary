import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 6)
class NotificationModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? title;

  @HiveField(2)
  String? message;

  @HiveField(3)
  DateTime? createdAt;

  @HiveField(4)
  bool? isRead;

  NotificationModel({this.id, this.title, this.message, this.createdAt, this.isRead = false});
}