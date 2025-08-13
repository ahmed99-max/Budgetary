import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 1)
enum ExpenseType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
  @HiveField(2)
  transfer,
}

@HiveType(typeId: 2)
enum RecurrenceType {
  @HiveField(0)
  none,
  @HiveField(1)
  daily,
  @HiveField(2)
  weekly,
  @HiveField(3)
  monthly,
  @HiveField(4)
  yearly,
}

@HiveType(typeId: 3)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? userId;

  @HiveField(2)
  String? title;

  @HiveField(3)
  String? description;

  @HiveField(4)
  double? amount;

  @HiveField(5)
  String? categoryId;

  @HiveField(6)
  String? categoryName;

  @HiveField(7)
  String? categoryIcon;

  @HiveField(8)
  ExpenseType? type;

  @HiveField(9)
  DateTime? date;

  @HiveField(10)
  String? paymentMethod;

  @HiveField(11)
  String? location;

  @HiveField(12)
  List<String>? tags;

  @HiveField(13)
  String? receiptUrl;

  @HiveField(14)
  String? receiptText;

  @HiveField(15)
  bool? isRecurring;

  @HiveField(16)
  RecurrenceType? recurrenceType;

  @HiveField(17)
  DateTime? recurrenceEndDate;

  @HiveField(18)
  String? currency;

  @HiveField(19)
  double? exchangeRate;

  @HiveField(20)
  DateTime? createdAt;

  @HiveField(21)
  DateTime? updatedAt;

  @HiveField(22)
  Map<String, dynamic>? metadata;

  @HiveField(23)
  bool? isSynced;

  @HiveField(24)
  String? notes;

  @HiveField(25)
  double? latitude;

  @HiveField(26)
  double? longitude;

  ExpenseModel({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.amount,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.type = ExpenseType.expense,
    this.date,
    this.paymentMethod,
    this.location,
    this.tags,
    this.receiptUrl,
    this.receiptText,
    this.isRecurring = false,
    this.recurrenceType = RecurrenceType.none,
    this.recurrenceEndDate,
    this.currency = 'USD',
    this.exchangeRate = 1.0,
    this.createdAt,
    this.updatedAt,
    this.metadata,
    this.isSynced = false,
    this.notes,
    this.latitude,
    this.longitude,
  });

  bool get isIncome => type == ExpenseType.income;
  bool get isExpense => type == ExpenseType.expense;
  bool get isTransfer => type == ExpenseType.transfer;

  String get formattedAmount {
    final symbol = _getCurrencySymbol(currency ?? 'USD');
    return '$symbol${amount?.toStringAsFixed(2) ?? '0.00'}';
  }

  String get formattedDate {
    if (date == null) return '';
    return '${date!.day}/${date!.month}/${date!.year}';
  }

  bool get hasLocation => latitude != null && longitude != null;

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'JPY': return '¥';
      case 'INR': return '₹';
      case 'CAD': return 'C\$';
      case 'AUD': return 'A\$';
      default: return '\$';
    }
  }

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      description: data['description'],
      amount: (data['amount'] ?? 0).toDouble(),
      categoryId: data['categoryId'],
      categoryName: data['categoryName'],
      categoryIcon: data['categoryIcon'],
      type: ExpenseType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ExpenseType.expense,
      ),
      date: data['date']?.toDate(),
      paymentMethod: data['paymentMethod'],
      location: data['location'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      receiptUrl: data['receiptUrl'],
      receiptText: data['receiptText'],
      isRecurring: data['isRecurring'] ?? false,
      recurrenceType: data['recurrenceType'] != null
        ? RecurrenceType.values.firstWhere(
            (e) => e.name == data['recurrenceType'],
            orElse: () => RecurrenceType.none,
          )
        : RecurrenceType.none,
      recurrenceEndDate: data['recurrenceEndDate']?.toDate(),
      currency: data['currency'] ?? 'USD',
      exchangeRate: (data['exchangeRate'] ?? 1.0).toDouble(),
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
      metadata: data['metadata'] != null 
        ? Map<String, dynamic>.from(data['metadata']) 
        : null,
      isSynced: data['isSynced'] ?? false,
      notes: data['notes'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'amount': amount,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'type': type?.name,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'paymentMethod': paymentMethod,
      'location': location,
      'tags': tags,
      'receiptUrl': receiptUrl,
      'receiptText': receiptText,
      'isRecurring': isRecurring,
      'recurrenceType': recurrenceType?.name,
      'recurrenceEndDate': recurrenceEndDate != null 
        ? Timestamp.fromDate(recurrenceEndDate!) 
        : null,
      'currency': currency,
      'exchangeRate': exchangeRate,
      'createdAt': createdAt != null 
        ? Timestamp.fromDate(createdAt!) 
        : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'metadata': metadata,
      'isSynced': isSynced,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  ExpenseModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    double? amount,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    ExpenseType? type,
    DateTime? date,
    String? paymentMethod,
    String? location,
    List<String>? tags,
    String? receiptUrl,
    String? receiptText,
    bool? isRecurring,
    RecurrenceType? recurrenceType,
    DateTime? recurrenceEndDate,
    String? currency,
    double? exchangeRate,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    bool? isSynced,
    String? notes,
    double? latitude,
    double? longitude,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      type: type ?? this.type,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      receiptText: receiptText ?? this.receiptText,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      currency: currency ?? this.currency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      isSynced: isSynced ?? this.isSynced,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() {
    return 'ExpenseModel(id: $id, title: $title, amount: $formattedAmount)';
  }
}
