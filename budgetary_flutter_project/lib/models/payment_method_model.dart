class PaymentMethodModel {
  final String id;
  final String name;
  final String icon;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory PaymentMethodModel.fromMap(Map<String, dynamic> map) {
    return PaymentMethodModel(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }
}
