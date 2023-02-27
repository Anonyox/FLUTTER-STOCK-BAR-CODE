class Order {

  late String id;
  late String order_Cod;
  late String orderType;

  Order(String id, String order_Cod, String orderType) {
    this.id = id;
    this.order_Cod = order_Cod;
    this.orderType = orderType;
  }

  Order.fromJson(Map json)
      : id = json['id'],
        order_Cod = json['order_Cod'],
        orderType = json['orderType'];
  
}