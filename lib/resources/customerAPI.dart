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
        getBlockInfoSuccess = "Data Customer tidak ditemukan";
        result = new Result(success: 0, message: "Data Customer tidak ditemukan");
      }

    } else {
      getBlockInfoSuccess = "Gagal terhubung dengan server";
      result = new Result(success: -1, message: "Gagal terhubung dengan server");
    }

    return result;

  }

  Future<Result> getLimit(final context, {String parameter=""}) async {
    Result result;
    String url = "";
    Customer customer;

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    http://192.168.10.213/dbrudie-2-0-0/getLimit.php?json={ "user_code" : "isak", "kode_customer" : "01A01010001" }
    // String url_address_1 = config.baseUrl + "/" + "getLimit.php" + (parameter == "" ? "" : "?" + parameter);
    // String url_address_2 = config.baseUrlAlt + "/" + "getLimit.php" + (parameter == "" ? "" : "?" + parameter);

    String url_address_1 = config.baseUrl + "/" + "tesIP.php";
    String url_address_2 = config.baseUrlAlt + "/" + "tesIP.php";

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

    url = config.baseUrl + "/" + "getLimit.php" + (parameter == "" ? "" : "?" + parameter);

    if(url != "") {

      final response = await client.get(url);

      printHelp("status code "+response.statusCode.toString());
      printHelp("cek body "+response.body);

      var parsedJson = jsonDecode(response.body);

      if(response.body.toString() != "false") {
        customer = Customer.fromJson(parsedJson[0]);

        var resultObject = jsonEncode(response.body);
        result = new Result(success: 1, message: "OK", data: response.body.toString());

      } else {
        result = new Result(success: 0, message: "Data Customer tidak ditemukan");
      }

    } else {
      result = new Result(success: -1, message: "Gagal terhubung dengan server");
    }

    return result;
  }

  Future<Result> getLimitGabungan(final context, {String parameter=""}) async {
    Result result;
    String url = "";
    Customer customer;

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    http://192.168.10.213/dbrudie-2-0-0/getLimit.php?json={ "user_code" : "isak", "kode_customer" : "01A01010001" }
    // String url_address_1 = config.baseUrl + "/" + "getLimit.php" + (parameter == "" ? "" : "?" + parameter);
    // String url_address_2 = config.baseUrlAlt + "/" + "getLimit.php" + (parameter == "" ? "" : "?" + parameter);

    String url_address_1 = config.baseUrl + "/" + "tesIP.php";
    String url_address_2 = config.baseUrlAlt + "/" + "tesIP.php";

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

    url = config.baseUrl + "/" + "getLimitGabungan.php" + (parameter == "" ? "" : "?" + parameter);

    if(url != "") {

      final response = await client.get(url);

      printHelp("status code "+response.statusCode.toString());
      printHelp("cek body "+response.body);

      if(response.body.toString() != "false" && response.body.toString() != "otoritas") {
        var parsedJson = jsonDecode(response.body);

        customer = Customer.fromJson(parsedJson[0]);

        var resultObject = jsonEncode(response.body);
        result = new Result(success: 1, message: "OK", data: response.body.toString());

      } else {
        if(response.body.toString() == "false") {
          result = new Result(success: 0, message: "Data Customer Gabungan tidak ditemukan");
        } else if(response.body.toString() == "otoritas") {
          result = new Result(success: 0, message: "Maaf, Anda tidak mempunyai otoritas untuk merubah limit pada pelanggan gabungan ini");
        }  
      }

    } else {
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

  Future<String> addRequestLimit(final context, {String parameter=""}) async {
    String isAddRequestLimitSuccess = "";
    Customer customer;
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = config.baseUrl + "/" + "addRequestLimitCoba.php" + (parameter == "" ? "" : "?" + parameter);
    String url_address_2 = config.baseUrlAlt + "/" + "addRequestLimitCoba.php" + (parameter == "" ? "" : "?" + parameter);

    try {
		  final conn_1 = await ConnectionTest(url_address_1, context);
      if(conn_1 == "OK"){
        isUrlAddress_1 = true;
      }
	  } on SocketException {
      isUrlAddress_1 = false;
      isAddRequestLimitSuccess = "Gagal terhubung dengan server";
      // throw Exception('No Internet connection');
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
        isAddRequestLimitSuccess = "Gagal terhubung dengan server";
        // throw Exception('No Internet connection');
      }
    }
    if(isUrlAddress_2){
      url = url_address_2;
    }

    if(url != "") {
      String coba = config.baseUrlAlt + "/" + "addRequestLimitCoba.php" + (parameter == "" ? "" : "?" + parameter);

      final response = await client.get(url);

      printHelp("status code "+response.statusCode.toString());

      printHelp(APIUrl("addRequestLimitCoba.php", context: context, parameter:parameter));

      printHelp("cek body "+response.body);

      if(response.body.toString() == "success") {
        isAddRequestLimitSuccess = "OK";
      
      } else {
        isAddRequestLimitSuccess = "Gagal terhubung dengan server";
      }

    } else {
      isAddRequestLimitSuccess = "Gagal terhubung dengan server";
    }

    return isAddRequestLimitSuccess;

  }

  Future<String> addRequestLimitGabungan(final context, {String parameter=""}) async {
    String isAddRequestLimitSuccess = "";
    Customer customer;
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = config.baseUrl + "/" + "addRequestLimitGCoba.php" + (parameter == "" ? "" : "?" + parameter);
    String url_address_2 = config.baseUrlAlt + "/" + "addRequestLimitGCoba.php" + (parameter == "" ? "" : "?" + parameter);

    try {
		  final conn_1 = await ConnectionTest(url_address_1, context);
      if(conn_1 == "OK"){
        isUrlAddress_1 = true;
      }
	  } on SocketException {
      isUrlAddress_1 = false;
      isAddRequestLimitSuccess = "Gagal terhubung dengan server";
      // throw Exception('No Internet connection');
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
        isAddRequestLimitSuccess = "Gagal terhubung dengan server";
        // throw Exception('No Internet connection');
      }
    }
    if(isUrlAddress_2){
      url = url_address_2;
    }

    if(url != "") {
      String coba = config.baseUrlAlt + "/" + "addRequestLimitGCoba.php" + (parameter == "" ? "" : "?" + parameter);

      final response = await client.get(url);

      printHelp("status code "+response.statusCode.toString());

      printHelp(APIUrl("addRequestLimitGCoba.php", context: context, parameter:parameter));

      printHelp("cek body "+response.body);

      if(response.body.toString() == "success") {
        isAddRequestLimitSuccess = "OK";
      
      } else {
        isAddRequestLimitSuccess = "Gagal terhubung dengan server";
      }

    } else {
      isAddRequestLimitSuccess = "Gagal terhubung dengan server";
    }

    return isAddRequestLimitSuccess;

  }

  Future<String> changeLimit(final context, {String parameter=""}) async {
    String isChangeLimitSuccess = "";
    Customer customer;
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = config.baseUrl + "/" + "updateLimitCoba.php" + (parameter == "" ? "" : "?" + parameter);
    String url_address_2 = config.baseUrlAlt + "/" + "updateLimitCoba.php" + (parameter == "" ? "" : "?" + parameter);

    try {
		  final conn_1 = await ConnectionTest(url_address_1, context);
      if(conn_1 == "OK"){
        isUrlAddress_1 = true;
      }
	  } on SocketException {
      isUrlAddress_1 = false;
      isChangeLimitSuccess = "Gagal terhubung dengan server";
      // throw Exception('No Internet connection');
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
        isChangeLimitSuccess = "Gagal terhubung dengan server";
        // throw Exception('No Internet connection');
      }
    }
    if(isUrlAddress_2){
      url = url_address_2;
    }

    if(url != "") {
      String coba = config.baseUrlAlt + "/" + "updateLimitCoba.php" + (parameter == "" ? "" : "?" + parameter);

      final response = await client.get(url);

      printHelp("status code "+response.statusCode.toString());

      printHelp(APIUrl("updateLimitCoba.php", context: context, parameter:parameter));

      printHelp("cek body "+response.body);

      if(response.body.toString() == "success") {
        isChangeLimitSuccess = "OK";
      } else if(response.body.toString() == "false") {
        isChangeLimitSuccess = "Limit tidak boleh dibawah NOL";
      } else {
        isChangeLimitSuccess = "Limit tidak boleh melebihi " + response.body.toString();
      }

    } else {
      isChangeLimitSuccess = "Gagal terhubung dengan server";
    }

    return isChangeLimitSuccess;

  }

  Future<String> changeLimitGabungan(final context, {String parameter=""}) async {
    String isChangeLimitSuccess = "";
    Customer customer;
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = config.baseUrl + "/" + "updateLimitGabunganCoba.php" + (parameter == "" ? "" : "?" + parameter);
    String url_address_2 = config.baseUrlAlt + "/" + "updateLimitGabunganCoba.php" + (parameter == "" ? "" : "?" + parameter);

    try {
		  final conn_1 = await ConnectionTest(url_address_1, context);
      if(conn_1 == "OK"){
        isUrlAddress_1 = true;
      }
	  } on SocketException {
      isUrlAddress_1 = false;
      isChangeLimitSuccess = "Gagal terhubung dengan server";
      // throw Exception('No Internet connection');
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
        isChangeLimitSuccess = "Gagal terhubung dengan server";
        // throw Exception('No Internet connection');
      }
    }
    if(isUrlAddress_2){
      url = url_address_2;
    }

    if(url != "") {
      String coba = config.baseUrlAlt + "/" + "updateLimitGabunganCoba.php" + (parameter == "" ? "" : "?" + parameter);

      final response = await client.get(url);

      printHelp("status code "+response.statusCode.toString());

      printHelp(APIUrl("updateLimitGabunganCoba.php", context: context, parameter:parameter));

      printHelp("cek body "+response.body);

      if(response.body.toString() == "success") {
        isChangeLimitSuccess = "OK";
      } else if(response.body.toString() == "false") {
        isChangeLimitSuccess = "Limit tidak boleh dibawah NOL";
      } else {
        isChangeLimitSuccess = "Limit tidak boleh melebihi " + response.body.toString();
      }

    } else {
      isChangeLimitSuccess = "Gagal terhubung dengan server";
    }

    return isChangeLimitSuccess;

  }



}

final customerAPI = CustomerAPI();