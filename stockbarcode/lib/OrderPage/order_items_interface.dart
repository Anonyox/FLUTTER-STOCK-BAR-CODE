class OrderItems {

  late String product_id;
  late String product_Description;
  late String product_Quantity;

  OrderItems(String product_id, String product_Description, String product_Quantity) {
    this.product_id = product_id;
    this.product_Description = product_Description;
    this.product_Quantity = product_Quantity;
  }

  OrderItems.fromJson(Map json)
      : product_id = json['product_id'],
        product_Description = json['product_Description'],
        product_Quantity = json['product_Quantity'];
  
}