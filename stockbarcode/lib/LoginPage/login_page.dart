import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../HomePage/home_page.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // @override
  // Widget build(BuildContext context) {
  //   // ignore: prefer_const_constructors
  //   return Scaffold(
  //     body: Form(
  //       key: _formkey,

  //       // ignore: avoid_unnecessary_containers

  //       child: Center(
  //         child: SingleChildScrollView(
  //           padding: EdgeInsets.symmetric(horizontal: 16),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.spaceAround,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               const Image(image: AssetImage('assets/logo.png')),
  //               ElevatedButton(
  //                 onPressed: () async {
  //                   FocusScopeNode currentFocus = FocusScope.of(context);
  //                   if (_formkey.currentState!.validate()) {
  //                     bool accessTokenTrue = await login();
  //                     if (!currentFocus.hasPrimaryFocus) {
  //                       currentFocus.unfocus();
  //                     }
  //                     if (accessTokenTrue) {
  //                       // ignore: use_build_context_synchronously
  //                       Navigator.pushReplacement(
  //                           context,
  //                           MaterialPageRoute(
  //                               builder: (context) => HomePage(title: "Menu")));
  //                     } else {
  //                       _passwordController.clear();
  //                       ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //                     }
  //                   }
  //                 },
  //                 child: Text('Acessar'),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // // ignore: prefer_const_constructors
  // final snackBar = SnackBar(
  //   content: Text(
  //     'Código QR Inválido',
  //     textAlign: TextAlign.center,
  //   ),
  //   backgroundColor: Colors.redAccent,
  // );

  // Future<bool> login() async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   var valueCodeBar = '';
  //   String barCodeScanRes = await FlutterBarcodeScanner.scanBarcode(
  //       '#ff6666', 'Cancelar', true, ScanMode.QR);

  //   if (barCodeScanRes == '-1') {
  //     Get.snackbar('Cancelado', 'Leitura Cancelada');
  //     return false;
  //   } else {
  //     valueCodeBar = barCodeScanRes;
  //     await sharedPreferences.setString('token', "${barCodeScanRes}");
  //     return true;
  //   }
  // }

    @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return Scaffold(
        body: Form(
          
      key: _formkey,
    
      
      // ignore: avoid_unnecessary_containers
     
       
        
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Image(image: AssetImage(
                  'assets/logo.png')
                  
                  ),
                TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (email) {
                      if (email == null || email.isEmpty) {
                        return 'Por favor, digite seu email';
                      } else if (!RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(_emailController.text)) {
                        return 'Por favor, digite um e-mail correto';
                      }
                      return null;
                    }),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Senha'),
                  controller: _passwordController,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  validator: (senha) {
                    if (senha == null || senha.isEmpty) {
                      return 'Por favor, digite sua senha';
                    } else if (senha.length < 6) {
                      return 'Por favor, digite uma senha maior que 6 caracteres';
                    }
                    return null;
                  },
                ),

                ElevatedButton(
                  
                  onPressed: () async {
                    
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (_formkey.currentState!.validate()) {
                      bool accessTokenTrue = await login();
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      if (accessTokenTrue) {
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage(title: "Menu Principal")));
                      } else {
                          final player = AudioCache();
                            player.play('error.wav');
                        _passwordController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                  },
                  child: Text('Acessar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ignore: prefer_const_constructors
  final snackBar = SnackBar(
    content: Text(
      'Usuário ou senha são inválidos',
      textAlign: TextAlign.center,
    ),
    backgroundColor: Colors.redAccent,
  );

  Future<bool> login() async {
    // ignore: unused_local_variable
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.0.108:5000/auth/login');
    final access = jsonEncode({
      'username': _emailController.text,
      'password': _passwordController.text
    });
    var response = await http.post(url,
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
        body: access);
    if (response.statusCode == 200) {
      await sharedPreferences.setString('token', "${jsonDecode(response.body)['accessToken']}");
      // print(jsonDecode(response.body)['accessToken']);
      return true;
    } else {
      print(jsonDecode(response.body));
      return false;
    }
  }



}
