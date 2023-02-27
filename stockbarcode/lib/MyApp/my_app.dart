import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockbarcode/HomePage/home_page.dart';
import 'package:stockbarcode/LoginPage/login_page.dart';
import 'package:stockbarcode/OrderPage/order_page_detail.dart';
import 'package:stockbarcode/WelcomePage/welcome_page.dart';







class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(name: '/', page: () => LoginPage())
      ],
    );
  }
}