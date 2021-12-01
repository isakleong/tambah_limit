import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' show Client;
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/models/customerModel.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';

class CustomerAPI {
  Client client = Client();

  Future<Customer> getBlockInfo(final context, {String parameter=""}) async {
    String getBlockInfoSuccess = "";
    Customer customer;
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = config.baseUrl + "/" + "getBlock.php" + (parameter == "" ? "" : "?" + parameter);
    String url_address_2 = config.baseUrlAlt + "/" + "getBlock.php" + (parameter == "" ? "" : "?" + parameter);

    try {
		  final conn_1 = await ConnectionTest(url_address_1, context);
      if(conn_1 == "OK"){
        isUrlAddress_1 = true;
      }
	  } on SocketException {
      isUrlAddress_1 = false;
      getBlockInfoSuccess = "Gagal terhubung dengan server";
    }

    if(isUrlAddress_1) {
      url = url_address_1;
    } else {
      try {
        final conn_2 = await ConnectionTest(url_address_2, context);
        if(conn_2 == "OK"){
          isUrlAddress_2 = true;
        }
      } on SocketException {
        isUrlAddress_2 = false;
        getBlockInfoSuccess = "Gagal terhubung dengan server";
      }
    }
    if(isUrlAddress_2){
      url = url_address_2;
    }

    if(url != "") {
      final response = await client.get(url);

      printHelp("status code "+response.statusCode.toString());

      printHelp(APIUrl("getUser.php", context: context, parameter:parameter));

      printHelp("cek body "+response.body);
      var parsedJson = jsonDecode(response.body);
      if(response.body.toString() != "false") {
        customer = Customer.fromJson(parsedJson[0]);

        if(customer.Id != ""){
          getBlockInfoSuccess = "OK";
        } 

      } else {
        getBlockInfoSuccess = "Kode customer tidak ditemukan";
      }

    } else {
      getBlockInfoSuccess = "Gagal terhubung dengan server";
    }

    return customer;

  }

}

final customerAPI = CustomerAPI();