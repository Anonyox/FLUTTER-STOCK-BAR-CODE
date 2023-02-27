import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../HomePage/home_page.dart';
import '../WelcomePage/welcome_page.dart';
import 'order_items_interface.dart';
import 'order_page_service.dart';

class OrderPageDetailView extends StatefulWidget {
  const OrderPageDetailView({super.key, required this.title});
  final String title;

  @override
  State<OrderPageDetailView> createState() => _OrderPageDetailViewState();
}

class _OrderPageDetailViewState extends State<OrderPageDetailView> {
  var orders = [];

  _getOrders() async {
    SharedPreferences sharedPreference = await SharedPreferences.getInstance();
    OrderPageService.getOrderItemsORder(
            sharedPreference.getString('order_Id').toString())
        .then((response) {
      setState(() {
        print(response.statusCode);

        if (response.body.isNotEmpty) {
          print(json.decode(response.body));
          Iterable orderlist = json.decode(response.body);

          orders = orderlist.toList();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(snackBarOrder);
        }
      });
    });
  }

  _OrderPageDetailViewState() {
    _getOrders();
  }

  @override
  Widget build(BuildContext context) {
    var order;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent.shade200,
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Show Snackbar',
              onPressed: () async { 
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                              title: "Menu Principal",
                            )));
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Show Snackbar',
              onPressed: () async {
                bool accessLogout = await logout();
                if (accessLogout) {
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);

                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => WelcomePage()));
                }
              },
            )
          ],
        ),
        body: listOrders()

        );
  }

  listOrders() {
    return ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
             orders[index]['product']['productDescription'],
            ),
            textColor: Colors.black,
            subtitle: Text("" +
                "Código : " +
                orders[index]['product']['productCod']),
            trailing: Container(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Qtd :    "),
                  IconButton(
                      icon: Icon(
                        Icons.qr_code_scanner,
                        color: Colors.blueAccent,
                      ),
                      onPressed: null),
                  // Text(orders[index].id),
                ],
              ),
            ),
          );
        });
  }
}

final snackBarOrder = SnackBar(
  content: Text(
    'Acesso Negado',
    textAlign: TextAlign.center,
  ),
  backgroundColor: Color.fromARGB(255, 228, 34, 34),
);

final snackBarOrderNotExist = SnackBar(
  content: Text(
    'Pedido não Encontrado',
    textAlign: TextAlign.center,
  ),
  backgroundColor: Color.fromARGB(255, 228, 34, 34),
);

final snackBarOrderCancel = SnackBar(
  content: Text(
    'Leitura do Pedido Cancelada',
    textAlign: TextAlign.center,
  ),
  backgroundColor: Color.fromARGB(255, 228, 34, 34),
);

Future<bool> logout() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.clear();
  return true;
}
