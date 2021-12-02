import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' show Client, Request;
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/models/customerModel.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';

class CustomerAPI {
  Client client = Client();

  Future<Result> getBlockInfo(final context, {String parameter=""}) async {
    Result result;
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
      result = new Result(success: -1, message: "Gagal terhubung dengan server");
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
        result = new Result(success: -1, message: "Gagal terhubung dengan server");
      }
    }
    if(isUrlAddress_2){
      url = url_address_2;
    }

    if(url != "") {

      //finalize
      // final request = new Request('GET', Uri.parse(url))..followRedirects = false;
      // final response = await client.send(request).timeout(
      //   Duration(seconds: 60),
      //     onTimeout: () {
      //       // time has run out, do what you wanted to do
      //       return null;
      //     },
      // );

      // printHelp("cek debug "+url.toString()+"-----"+response.statusCode.toString());

      // if(response.statusCode == 200){
      // } else {
      // }

      final response = await client.get(url);

      printHelp("status code "+response.statusCode.toString());

      printHelp("cek body "+response.body);
      var parsedJson = jsonDecode(response.body);

      if(response.body.toString() != "false") {
        customer = Customer.fromJson(parsedJson[0]);

        if(customer.No_ != ""){
          getBlockInfoSuccess = "OK";
        }

        var resultObject = jsonEncode(response.body);
        result = new Result(success: 1, message: "OK", data: response.body.toString());

      } else {
        getBlockInfoSuccess = "Kode customer tidak ditemukan";
        result = new Result(success: 0, message: "Kode customer tidak ditemukan");
      }

    } else {
      getBlockInfoSuccess = "Gagal terhubung dengan server";
      result = new Result(success: -1, message: "Gagal terhubung dengan server");
    }

    return result;

  }

  Future<Result> updateBlock(final context, {String parameter=""}) async {
    Result result;
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = config.baseUrl + "/" + "updateBlock.php" + (parameter == "" ? "" : "?" + parameter);
    String url_address_2 = config.baseUrlAlt + "/" + "updateBlock.php" + (parameter == "" ? "" : "?" + parameter);

    try {
		  final conn_1 = await ConnectionTest(url_address_1, context);
      if(conn_1 == "OK"){
        isUrlAddress_1 = true;
      }
	  } on SocketException {
      isUrlAddress_1 = false;
      result = new Result(success: -1, message: "Gagal terhubung dengan server");
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
        result = new Result(success: -1, message: "Gagal terhubung dengan server");
      }
    }
    if(isUrlAddress_2){
      url = url_address_2;
    }

    if(url != "") {

      final response = await client.get(url);

      printHelp("status code "+response.statusCode.toString());

      if(response.body.toString() != "false") {
        result = new Result(success: 1, message: "Ubah status Blocked berhasil");

      } else {
        result = new Result(success: 0, message: "Gagal terhubung dengan server");
      }

    } else {
      result = new Result(success: -1, message: "Gagal terhubung dengan server");
    }

    return result;
  }



}

final customerAPI = CustomerAPI();