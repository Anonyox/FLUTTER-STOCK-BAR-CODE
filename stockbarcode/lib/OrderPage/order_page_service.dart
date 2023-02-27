import 'package:stockbarcode/Shared/requisition_center.dart';

class OrderPageService {

  static Future listOrders() async {
    // ignore: unused_local_variable
    return await REST.get("basic/Order");
  }

  static Future getOrder(var id) async {
    return await REST.getById("basic/Order",id);
  }

  static Future getOrderItemsORder(var id) async {
    return await REST.get("basic/OrderItems/orderid/" + id);
}

  
}
