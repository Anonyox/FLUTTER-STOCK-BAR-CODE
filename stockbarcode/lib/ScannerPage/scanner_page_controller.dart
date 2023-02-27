import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';

class ScannerPageController extends GetxController {
 var valueCodeBar = ''; 

 void scanBarCode () async{
    String barCodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666','Cancelar',true,ScanMode.BARCODE);

    if(barCodeScanRes == '-1'){
      Get.snackbar('Cancelado', 'Leitura Cancelada');
    }else{
      valueCodeBar = barCodeScanRes;
      update();
    }


 }

//  void scanBarCode () async{
//     String barCodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666','Cancelar',true,ScanMode.BarCode);

//     if(barCodeScanRes == '-1'){
//       Get.snackbar('Cancelado', 'Leitura Cancelada');
//     }else{
//       valueCodeBar = barCodeScanRes;
//       update();
//     }


//  }
}