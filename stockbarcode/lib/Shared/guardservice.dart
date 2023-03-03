import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockbarcode/Shared/requisition_center.dart';

import '../LoginPage/login_page.dart';

class TokenService {
  static const int _refreshInterval = 10; // tempo em segundos para verificar o token
  final BuildContext context;
  Timer? _timer;

  TokenService(this.context) {
    // inicia o timer
    _timer = Timer.periodic(Duration(seconds: _refreshInterval), (timer) async {
      final token = await _getToken();
      if (token == null) {
        // Navega para a tela de login se o token for nulo
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        _timer?.cancel(); // Para o timer se a navegação for realizada
      }
    });
  }

  // obtém o token armazenado no Shared Preferences
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var responsePing = await REST.ping();
    if(responsePing.statusCode == 200) {
      return prefs.getString('token');
    } else {
      prefs.remove('token');
      prefs.remove('order_Id');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sessão finalizada'),
          backgroundColor: Colors.blue,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      _timer?.cancel(); // Para o timer se a navegação for realizada
      return null;
    }
  }

  // cancela o timer quando não for mais necessário
  void dispose() {
    _timer?.cancel();
  }
}