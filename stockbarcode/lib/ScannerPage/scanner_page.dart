import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockbarcode/ScannerPage/scanner_page_controller.dart';

class ScannerPage extends StatelessWidget {
  HomePage() {
    Get.put(ScannerPageController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // ignore: prefer_const_constructors
          title: Text('Separação'),
        ),
        body: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Valor do Código de Barras:',
                style: Get.theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              GetBuilder<ScannerPageController>(
                builder: (controller) {
                  return Text(
                    controller.valueCodeBar,
                    style: Get.theme.textTheme.headlineMedium,
                  );
                },
              ),

              // ignore: prefer_const_constructors
              SizedBox(
                height: 10,
              ),
              TextButton.icon(
                  icon: Image.asset('assets/icon.png', width: 50),
                  label: Text(
                    'Ler Código de Barras',
                    style: Get.theme.textTheme.headlineSmall,
                  ),
                  onPressed: () {
                    Get.find<ScannerPageController>().scanBarCode();
                  })
            ],
          ),
        ));
  }
}
