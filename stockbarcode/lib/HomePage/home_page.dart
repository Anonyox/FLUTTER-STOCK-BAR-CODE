import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockbarcode/OrderPage/order_page.dart';

import '../WelcomePage/welcome_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blueAccent.shade200,
          title: Text(widget.title),
          actions: <Widget>[
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
            ),
          ]),
      body: Center(
        child: SizedBox(
          width: 200.0,
          height: 200.0,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 180,
                  height: 180,
                  child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrderPageView()));
                      },
                      child: Text('')),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/monitorando.png"),
                    ),
                  ),
                ),
                Text(
                  "Pedidos",
                  style: TextStyle(fontSize: 17),
                )
              ]),
        ),
      ),
    );
    // This trailing comma makes auto-formatting nicer for build methods.
  }
}

final snackBar = SnackBar(
  content: Text(
    'Sessão Finalizada',
    textAlign: TextAlign.center,
  ),
  backgroundColor: Colors.blueAccent,
);

Future<bool> logout() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.clear();
  return true;
}
