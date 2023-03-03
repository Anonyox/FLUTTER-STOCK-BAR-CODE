import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const API_PATH = "http://10.0.0.108:5000/";

class REST {
  static Future get(var route) async {
    // ignore: unused_local_variable
    SharedPreferences sharedPreference = await SharedPreferences.getInstance();

    var url = Uri.parse(API_PATH + route);
    return await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader:
          // ignore: prefer_interpolation_to_compose_strings
          'bearer ' + sharedPreference.getString('token').toString()
    });
  }

  static Future getById(var route, var id) async {
    SharedPreferences sharedPreference = await SharedPreferences.getInstance();
    var url = Uri.parse(API_PATH + route + '/' + id);
    return await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader:
          // ignore: prefer_interpolation_to_compose_strings
          'bearer ' + sharedPreference.getString('token').toString()
    });
  }

  static Future ping() async {
    SharedPreferences sharedPreference = await SharedPreferences.getInstance();
    var url = Uri.parse(API_PATH + 'auth/ping');
    return await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.authorizationHeader:
          // ignore: prefer_interpolation_to_compose_strings
          'bearer ' + sharedPreference.getString('token').toString()
    });
  }

  static Future post(var route, var body) async {
    SharedPreferences sharedPreference = await SharedPreferences.getInstance();
    var url = Uri.parse(API_PATH + route);
    return await http.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.authorizationHeader:
            'bearer ' + sharedPreference.getString('token').toString()
      },
      body: json.encode(body),
    );
  }
}
