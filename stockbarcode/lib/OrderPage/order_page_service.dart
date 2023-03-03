import 'dart:convert';

import 'package:stockbarcode/Shared/requisition_center.dart';

import 'order_interface.dart';

class OrderPageService {
  static Future listOrders() async {
    return await REST.get("basic/Order");
  }

  static Future                                                                                                                                                                                                                                                                                                                                                                                              getOrder(var id) async {
    return await REST.getById("basic/Order", id);
  }

  static Future getOrderItemsORder(var id) async {
    return await REST.get("basic/OrderItems/orderid/" + id);
  }

  static Future createSeparationItem(var orderData) async {
    return await REST.post("ConnectionTables/OrderSeparation", orderData);
  }

  static Future<List<dynamic>> getOrdersSeparation(var id) async {
    final response =
        await REST.get('ConnectionTables/OrderSeparation/order/' + id);

    if (response.statusCode == 200) {
      final ordersJson = jsonDecode(response.body) as List<dynamic>;
      return ordersJson;
    } else {
      throw Exception('Failed to load orders');
    }
  }

  static Future getBatchByCode(String code) async {
    final response = await REST.get('basic/Batch/batchNumber/'+code);


    if (response.statusCode == 200) {
      final lotJson = jsonDecode(response.body) as List<dynamic>;
      return lotJson;
    } else {
      throw Exception('Failed to load lot');
    }
  }
}
