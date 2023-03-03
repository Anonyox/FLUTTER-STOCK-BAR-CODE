import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../HomePage/home_page.dart';
import '../Shared/guardservice.dart';
import '../WelcomePage/welcome_page.dart';
import 'order_interface.dart';
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

  late TokenService _tokenService;

  var product_Id = "";
  var batch_Id = "";
  var order_Id = "";
  var quantitySeparate = 0;
  int sales_Quantity = 0;
  int quantityContain = 0;

  int _defaultQuantity = 1;

  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();

  Timer? _timer;

  _getOrders() async {
    SharedPreferences sharedPreference = await SharedPreferences.getInstance();
    try {
      final orderList = await OrderPageService.getOrdersSeparation(sharedPreference.getString("order_Id"));
      setState(() {
        orders = orderList;
      });
    } catch (error) {
      // Cancela o timer em caso de erro na requisição
      _timer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao obter ordens de separação'),
        ),
      );
    }
  }

  _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _getOrders();
    });
  }

  _OrderPageDetailViewState() {
    _getOrders();
    _startTimer();
  }

  @override
  void initState() {
    super.initState();
    _tokenService = TokenService(context);
  }

  @override
  void dispose() {
    // Cancela o timer quando o widget é destruído
    _tokenService.dispose();
    _timer?.cancel();
    super.dispose();
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
        body: listOrders());
  }

  listOrders() {
    Map<String, num> productQuantities = {};

// percorre a lista de pedidos e agrupa por id do produto
    for (final order in orders) {
      final productId = order['batch']['product']['id'];
      final quantity = order['quantity'];
      productQuantities[productId] =
          (productQuantities[productId] ?? 0) + quantity;
    }

// cria a lista a partir do Map de quantidades
    final List<Widget> productItems = productQuantities.entries.map((entry) {
      final productId = entry.key;
      final quantity = entry.value;

      // busca a descrição e código do produto
      final productDescription = orders.firstWhere(
              (order) => order['batch']['product']['id'] == productId)['batch']
          ['product']['productDescription'];
      final productCod = orders.firstWhere(
              (order) => order['batch']['product']['id'] == productId)['batch']
          ['product']['productCod'];
      final int sales_Quantity = orders.firstWhere((order) =>
          order['batch']['product']['id'] == productId)['salesQuantity'];

      // cria o ListTile com as informações do produto e quantidade total
      return ListTile(
        title: Text("$productDescription"),
        subtitle: Text("Código: $productCod"),
        trailing: SizedBox(
          width: 170, // largura fixa
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Qtd P/S: $sales_Quantity | ",
              ),
              Text(
                "Qtd: $quantity",
                style: TextStyle(color: Colors.green),
              ),
              IconButton(
                icon: Icon(Icons.qr_code_scanner, color: Colors.blueAccent),
                onPressed: () async {
                  bool qr =
                      await scanOrderItem(productId, sales_Quantity, quantity);
                  if (qr) {
                    final player = AudioCache();
                    player.play('Scan.wav');
                    _showQuantityDialog();
                  }
                },
              ),
            ],
          ),
        ),
      );
    }).toList();

// ordena a lista de produtos pelo código do produto
    productItems.sort((a, b) {
      final aCod =
          (a as ListTile).subtitle.toString().replaceAll('Código: ', '');
      final bCod =
          (b as ListTile).subtitle.toString().replaceAll('Código: ', '');
      return bCod.compareTo(aCod);
    });

    return Column(
      children: [
        // ... outros Widgets ...
        Expanded(
          child: ListView(
            children: productItems,
          ),
        ),
      ],
    );
  }

  void _showQuantityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quantidade'),
          content: TextFormField(
            keyboardType: TextInputType.number,
            controller: _quantityController..text = _defaultQuantity.toString(),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                ScaffoldMessenger.of(context).showSnackBar(snackBarNotQuantity);
                final player = AudioCache();
                player.play('error.wav');
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Informe a quantidade',
            ),
            onChanged: (value) {
              if (value.isEmpty) {
                _defaultQuantity = 1;
              } else {
                _defaultQuantity = int.parse(value);
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                child: Text('Separar'),
                onPressed: () async {
                  int quantityTotal = quantityContain +
                      (int.tryParse(_quantityController.text) ?? 1);

                  if (quantityTotal > sales_Quantity) {
                    // Se a soma for maior que sales_Quantity, exibe uma mensagem ou faz outra ação necessária
                    ScaffoldMessenger.of(context)
                        .showSnackBar(snackBarSeparationMax);
                    final player = AudioCache();
                    player.play('error.wav');
                    Navigator.of(context).pop();
                  } else {
                    // Monta o objeto e faz o post
                    final orderItem = {
                      'product_id': product_Id,
                      'batch_id': batch_Id,
                      'order_id': order_Id,
                      'quantity': int.tryParse(_quantityController.text) ?? 1,
                      'salesQuantity': sales_Quantity,
                    };
                    print(orderItem);
                    //Faz o post com o objeto orderItem
                    final separation =
                        await OrderPageService.createSeparationItem(orderItem);
                    _getOrders();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(snackProductSeparated);
                    Navigator.of(context).pop();
                  }
                }),
          ],
        );
      },
    );
  }

  Future<bool> scanOrderItem(
      String product_Id, int sales_Quantity, var quantity) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    var valueCodeBar = '';
    String barCodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancelar', true, ScanMode.BARCODE);

    if (barCodeScanRes == '-1') {
      ScaffoldMessenger.of(context).showSnackBar(snackBarOrderCancel);
      final player = AudioCache();
      player.play('error.wav');
      return false;
    } else {
      valueCodeBar = barCodeScanRes;

      print(product_Id);
      print(sales_Quantity);
      print(quantity);

      print(valueCodeBar);

      try {
        final lot = await OrderPageService.getBatchByCode(valueCodeBar);
        // print(lot[0]['product']['id']);

        if (product_Id == lot[0]['product']['id']) {
          this.product_Id = lot[0]['product']['id'];
          this.batch_Id = lot[0]['id'];
          this.order_Id = sharedPreferences.getString("order_Id").toString();
          this.sales_Quantity = sales_Quantity;
          this.quantityContain = quantity;
          return true;
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(snackBarOrderItemNotValid);
          final player = AudioCache();
          player.play('error.wav');
          return false;
        }

        // Resto do código
      } catch (e) {
        return false;
      }
    }
  }
}

final snackBarOrder = SnackBar(
  content: Text(
    'Acesso Negado.',
    textAlign: TextAlign.center,
  ),
  backgroundColor: Color.fromARGB(255, 228, 34, 34),
);

final snackBarNotQuantity = SnackBar(
  content: Text(
    'Insira a quantidade.',
    textAlign: TextAlign.center,
  ),
  backgroundColor: Color.fromARGB(255, 228, 34, 34),
);

final snackBarOrderNotExist = SnackBar(
  content: Text(
    'Pedido não Encontrado.',
    textAlign: TextAlign.center,
  ),
  backgroundColor: Color.fromARGB(255, 228, 34, 34),
);

final snackBarOrderItemNotValid = SnackBar(
  content: Text(
    'Produto não correspondente com o Lote.',
    textAlign: TextAlign.center,
  ),
  backgroundColor: Color.fromARGB(255, 228, 34, 34),
);

final snackProductSeparated = SnackBar(
    content: Text(
      'Produto Separado.',
      textAlign: TextAlign.center,
    ),
    backgroundColor: Color.fromARGB(143, 49, 255, 60));

final snackBarSeparationMax = SnackBar(
  content: Text(
    'Não é possível separar uma quantidade maior do que a quantidade de venda.',
    textAlign: TextAlign.center,
  ),
  backgroundColor: Color.fromARGB(255, 228, 34, 34),
);

final snackBarOrderCancel = SnackBar(
  content: Text(
    'Leitura do Pedido Cancelada.',
    textAlign: TextAlign.center,
  ),
  backgroundColor: Color.fromARGB(255, 228, 34, 34),
);

Future<bool> logout() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.clear();
  return true;
}
