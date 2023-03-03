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

import '../Shared/guardservice.dart';
import 'order_page_service.dart';

class OrderPageView extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPageView> {
  var orders = <Order>[];
  late TokenService _tokenService;

  @override
  void initState() {
    super.initState();
    _tokenService = TokenService(context);
  }

  @override
  void dispose() {
    _tokenService.dispose();
    super.dispose();
  }

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
                          Map<String, dynamic> dados =
                              json.decode(response.body);
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
                                    builder: (context) => OrderPageDetailView(
                                          title: "Pedido Nº: " +
                                              dados['order_Cod'],
                                        )));
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
