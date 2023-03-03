class Order {
  String id;
  DateTime insertionDate;
  int quantity;

  Order({
    required this.id,
    required this.insertionDate,
    required this.quantity,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      insertionDate: DateTime.parse(json['insercion_Date']),
      quantity: json['quantity'],
    );
  }
}