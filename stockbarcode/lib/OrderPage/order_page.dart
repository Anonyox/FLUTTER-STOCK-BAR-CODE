import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockbarcode/HomePage/home_page.dart';
import 'package:stockbarcode/OrderPage/order_interface.dart';
import 'package:stockbarcode/OrderPage/order_page_detail.dart';
import 'package:stockbarcode/Shared/requisition_center.dart';

import 'package:stockbarcode/WelcomePage/welcome_page.dart';

import 'order_page_service.dart';

class OrderPageView extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPageView> {
  var orders = <Order>[];

  // _getOrders() {
  //   OrderPageService.listOrders().then((response) {
  //     setState(() {
  //       print(response.statusCode);

  //       if (response.body.isNotEmpty) {
  //         Iterable orderlist = json.decode(response.body);

  //         orders = orderlist.map((model) => Order.fromJson(model)).toList();
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(snackBarOrder);
  //       }
  //     });
  //   });
  // }

  // _OrderPageState() {
  //   _getOrders();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent.shade200,
        title: Text('Pedido para Separar'),
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
      body: Form(
        // ignore: avoid_unnecessary_containers

        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton.icon(
                    icon: Image.asset('assets/icon.png', width: 100),
                    label: Text(
                      '',
                      style: Get.theme.textTheme.headlineSmall,
                    ),
                    onPressed: () async {
                      bool qr = await scanOrder();

                      if (qr) {
                        SharedPreferences sharedPreference =
                            await SharedPreferences.getInstance();
                        OrderPageService.getOrder(sharedPreference
                                .getString('order_Id')
                                .toString())
                            .then((response) {
                          
                         Map<String, dynamic> dados = json.decode(response.body);
                         print(dados);
                         print(dados['order_Cod']);
                           print(dados['id']);

                         
                          print((response.statusCode));
                          // sharedPreference.setString('order_Cod', response.body.order_Cod);
                          if (response.statusCode == 200) {
                            final player = AudioCache();
                            player.play('Scan.wav');
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        OrderPageDetailView(title: "Pedido Nº: " + dados['order_Cod'],)));
                          } else if (response.statusCode == 401) {
                            final player = AudioCache();
                            player.play('error.wav');
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBarOrder);
                          } else if (response.statusCode == 404) {
                            final player = AudioCache();
                            player.play('error.wav');
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBarOrderNotExist);
                          }
                        });
                      }
                    }), 
                Text(
                  "Ler pedido para separar",
                  style: TextStyle(fontSize: 17),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // listOrders() {
  //   return ListView.builder(
  //       itemCount: orders.length,
  //       itemBuilder: (context, index) {
  //         return ListTile(
  //           title: Text(
  //             orders[index].orderType,
  //           ),
  //           trailing: Container(
  //             width: 100,
  //             child: Row(
  //               children: [
  //                 Text(orders[index].order_Cod),
  //                 // Text(orders[index].id),
  //               ],
  //             ),
  //           ),

  //           // title: Column(
  //           //   crossAxisAlignment: CrossAxisAlignment.start,
  //           //   children: [
  //           //     Row(
  //           //       mainAxisAlignment: MainAxisAlignment.start,
  //           //       children: [
  //           //         Text(orders[index].orderType),
  //           //       ],
  //           //     ),
  //           //     Row(
  //           //       mainAxisAlignment: MainAxisAlignment.center,
  //           //       children: [
  //           //         Text(orders[index].order_Cod),
  //           //       ],
  //           //     )
  //           //   ],
  //           // ),
  //         );
  //       });
  // }

  Future<bool> scanOrder() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('order_Id');
    var valueCodeBar = '';
    String barCodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancelar', true, ScanMode.QR);

    if (barCodeScanRes == '-1') {
      ScaffoldMessenger.of(context).showSnackBar(snackBarOrderCancel);
      return false;
    } else {
      valueCodeBar = barCodeScanRes;
      print(valueCodeBar);
      await sharedPreferences.setString('order_Id', "${barCodeScanRes}");

      return true;
    }
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
