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

      try {

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

      } catch (e) {
        getBlockInfoSuccess = "Gagal terhubung dengan server";
        result = new Result(success: -1, message: "Gagal terhubung dengan server");
        print(e);
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

      var response;
      try {
        response = await client.get(url);

        printHelp("CEK YAAAAA "+ url);

        printHelp("status code "+response.statusCode.toString());
        printHelp("cek body "+response.body);

        printHelp(url);

        var parsedJson = jsonDecode(response.body);

        if(response.body.toString() != "false" && response.body.toString() != "otoritas") {
          customer = Customer.fromJson(parsedJson[0]);
          result = new Result(success: 1, message: "OK", data: response.body.toString());
        } else {
          if(response.body.toString() == "false") {
            result = new Result(success: 0, message: "Data Customer tidak ditemukan");
          } else if(jsonDecode(jsonEncode(response.body)).toString().trim() == "otoritas") {
            result = new Result(success: 0, message: "Anda tidak mempunyai otoritas untuk merubah limit pada pelanggan ini");
          }
        }
          
      } catch (e) {
        if(response.body.toString() == "otoritas") {
          result = new Result(success: 0, message: "Anda tidak mempunyai otoritas untuk merubah limit pada pelanggan ini");
        } else {
          result = new Result(success: -1, message: "Data Customer tidak ditemukan");
        }
        print(e);
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
      try {

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
            result = new Result(success: 0, message: "Anda tidak mempunyai otoritas untuk merubah limit pada pelanggan gabungan ini");
          }  
        }

      } catch (e) {
        result = new Result(success: -1, message: "Gagal terhubung dengan server");
        print(e);
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
    String url_address_1 = "", url_address_2 = "";

    url_address_1 = config.baseUrl + "/" + "tesIP.php" + (parameter == "" ? "" : "?" + parameter);
    url_address_2 = config.baseUrlAlt + "/" + "tesIP.php" + (parameter == "" ? "" : "?" + parameter);

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
      url = config.baseUrl + "/" + "updateBlock.php" + (parameter == "" ? "" : "?" + parameter);
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
      url = config.baseUrlAlt + "/" + "updateBlock.php" + (parameter == "" ? "" : "?" + parameter);
    }

    if(url != "") {

      try {

        final response = await client.get(url);

        printHelp("status code "+response.statusCode.toString());

        if(response.body.toString() != "false") {
          result = new Result(success: 1, message: "Ubah status Blocked berhasil");

        } else {
          result = new Result(success: 0, message: "Gagal terhubung dengan server");
        }

      } catch (e) {
        result = new Result(success: -1, message: "Gagal terhubung dengan server");
        print(e);
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
    String url_address_1 = "", url_address_2 = "";

    url_address_1 = config.baseUrl + "/" + "tesIP.php" + (parameter == "" ? "" : "?" + parameter);
    url_address_2 = config.baseUrlAlt + "/" + "tesIP.php" + (parameter == "" ? "" : "?" + parameter);

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
      url = config.baseUrl + "/" + "addRequestLimitCoba.php" + (parameter == "" ? "" : "?" + parameter);
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
      url = config.baseUrlAlt + "/" + "addRequestLimitCoba.php" + (parameter == "" ? "" : "?" + parameter);
    }

    if(url != "") {
      try {

        final response = await client.get(url);

        printHelp("status code "+response.statusCode.toString());

        printHelp("cek body "+response.body);

        if(response.body.toString() == "success") {
          isAddRequestLimitSuccess = "OK";
        
        } else {
          isAddRequestLimitSuccess = "Gagal terhubung dengan server";
        }

      } catch (e) {
        isAddRequestLimitSuccess = "Gagal terhubung dengan server";
        print(e);
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
    String url_address_1 = "", url_address_2 = "";

    url_address_1 = config.baseUrl + "/" + "tesIP.php" + (parameter == "" ? "" : "?" + parameter);
    url_address_2 = config.baseUrlAlt + "/" + "tesIP.php" + (parameter == "" ? "" : "?" + parameter);

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
      url = config.baseUrl + "/" + "addRequestLimitGCoba.php" + (parameter == "" ? "" : "?" + parameter);
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
      url = config.baseUrlAlt + "/" + "addRequestLimitsdsdGCoba.php" + (parameter == "" ? "" : "?" + parameter);
    }

    if(url != "") {
      try {
        final response = await client.get(url);

        printHelp("status code "+response.statusCode.toString());

        printHelp("cek body "+response.body);

        if(response.body.toString() == "success") {
          isAddRequestLimitSuccess = "OK";
        
        } else {
          isAddRequestLimitSuccess = "Gagal terhubung dengan server";
        }

      } catch (e) {
        isAddRequestLimitSuccess = "Gagal terhubung dengan server";
        print(e);
      }

    } else {
      isAddRequestLimitSuccess = "Gagal terhubung dengan server";
    }

    return isAddRequestLimitSuccess;

  }

  Future<String> updateLimitGabunganRequest(final context, {int command, String parameter=""}) async {
    String isChangeLimitSuccess = "";
    Customer customer;
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = "", url_address_2 = "";

    url_address_1 = config.baseUrl + "/" + "tesIP.php" + (parameter == "" ? "" : "?" + parameter);
    url_address_2 = config.baseUrlAlt + "/" + "tesIP.php" + (parameter == "" ? "" : "?" + parameter);

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
      if(command == 1) {
        url = config.baseUrl + "/" + "updateLimitCRequestCoba.php" + (parameter == "" ? "" : "?" + parameter);
      } else {
        url = config.baseUrl + "/" + "rejectLimitCRequestCoba.php" + (parameter == "" ? "" : "?" + parameter);
      }
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
      if(command == 1) {
        url = config.baseUrlAlt + "/" + "updateLimitCRequestCoba.php" + (parameter == "" ? "" : "?" + parameter);
      } else {
        url = config.baseUrlAlt + "/" + "rejectLimitCRequestCoba.php" + (parameter == "" ? "" : "?" + parameter);
      }
    }

    if(url != "") {
      if(command == 1) {
        try {
          final response = await client.get(url);

          printHelp("status code "+response.statusCode.toString());

          printHelp("cek body "+response.body);

          if(response.body.toString() == "success") {
            isChangeLimitSuccess = "OK";
          } else {
            isChangeLimitSuccess = "Limit tidak boleh melebihi " + response.body.toString();
          }

        } catch (e) {
          isChangeLimitSuccess = "Gagal terhubung dengan server";
          printHelp(e);
        }

      } else {
        try {
          final response = await client.get(url);

          printHelp("status code "+response.statusCode.toString());

          printHelp("cek body "+response.body);

          if(response.body.toString() == "success") {
            isChangeLimitSuccess = "OK";
          }
        } catch (e) {
          isChangeLimitSuccess = "Gagal terhubung dengan server";
          printHelp(e);
        }
      }

    } else {
      isChangeLimitSuccess = "Gagal terhubung dengan server";
    }

    return isChangeLimitSuccess;

  }

  Future<String> updateLimitRequest(final context, {int command, String parameter=""}) async {
    String isChangeLimitSuccess = "";
    Customer customer;
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = "", url_address_2 = "";

    url_address_1 = config.baseUrl + "/" + "tesIP.php" + (parameter == "" ? "" : "?" + parameter);
    url_address_2 = config.baseUrlAlt + "/" + "tesIP.php" + (parameter == "" ? "" : "?" + parameter);

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
      if(command == 1) {
        url = config.baseUrl + "/" + "updateLimitRequestCoba.php" + (parameter == "" ? "" : "?" + parameter);
      } else {
        url = config.baseUrl + "/" + "rejectLimitRequestCoba.php" + (parameter == "" ? "" : "?" + parameter);
      }
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
      if(command == 1) {
        url = config.baseUrlAlt + "/" + "updateLimitRequestCoba.php" + (parameter == "" ? "" : "?" + parameter);
      } else {
        url = config.baseUrlAlt + "/" + "rejectLimitRequestCoba.php" + (parameter == "" ? "" : "?" + parameter);
      }
    }

    if(url != "") {
      if(command == 1) {
        try {
          final response = await client.get(url);

          printHelp("status code "+response.statusCode.toString());

          printHelp("cek body "+response.body);

          if(response.body.toString() == "success") {
            isChangeLimitSuccess = "OK";
          } else {
            isChangeLimitSuccess = "Limit tidak boleh melebihi " + response.body.toString();
          }

        } catch (e) {
          isChangeLimitSuccess = "Gagal terhubung dengan server";
          print(e);
        }

      } else {
        try {
          final response = await client.get(url);

          printHelp("status code "+response.statusCode.toString());

          printHelp("cek body "+response.body);

          if(response.body.toString() == "success") {
            isChangeLimitSuccess = "OK";
          }

        } catch (e) {
          isChangeLimitSuccess = "Gagal terhubung dengan server";
          print(e);
        }
      }

    } else {
      isChangeLimitSuccess = "Gagal terhubung dengan server";
    }

    return isChangeLimitSuccess;

  }

  Future<String> changeLimit(final context, {String parameter=""}) async {
    String isChangeLimitSuccess = "";
    Customer customer;
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = "", url_address_2 = "";

    url_address_1 = config.baseUrl + "/" + "tesIP.php" + (parameter == "" ? "" : "?" + parameter);
    url_address_2 = config.baseUrlAlt + "/" + "tesIP.php" + (parameter == "" ? "" : "?" + parameter);

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
      url = config.baseUrl + "/" + "updateLimitCoba.php" + (parameter == "" ? "" : "?" + parameter);
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
      url = config.baseUrlAlt + "/" + "updateLimitCoba.php" + (parameter == "" ? "" : "?" + parameter);
    }

    if(url != "") {
      try {

        final response = await client.get(url);

        printHelp("status code "+response.statusCode.toString());

        printHelp("cek body "+response.body);

        if(response.body.toString() == "success") {
          isChangeLimitSuccess = "OK";
        } else if(response.body.toString() == "false") {
          isChangeLimitSuccess = "Limit tidak boleh dibawah NOL";
        } else {
          isChangeLimitSuccess = "Limit tidak boleh melebihi " + response.body.toString();
        }

      } catch (e) {
        isChangeLimitSuccess = "Gagal terhubung dengan server";
        print(e);
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
    String url_address_1 = "", url_address_2 = "";

    url_address_1 = config.baseUrl + "/" + "tesIP.php" + (parameter == "" ? "" : "?" + parameter);
    url_address_2 = config.baseUrlAlt + "/" + "tesIP.php" + (parameter == "" ? "" : "?" + parameter);

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
      url = config.baseUrl + "/" + "updateLimitGabunganCoba.php" + (parameter == "" ? "" : "?" + parameter);
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
      url = config.baseUrlAlt + "/" + "updateLimitGabunganCoba.php" + (parameter == "" ? "" : "?" + parameter);
    }

    if(url != "") {
      try {
        final response = await client.get(url);

        printHelp("status code "+response.statusCode.toString());

        printHelp("cek body "+response.body);

        if(response.body.toString() == "success") {
          isChangeLimitSuccess = "OK";
        } else if(response.body.toString() == "false") {
          isChangeLimitSuccess = "Limit tidak boleh dibawah NOL";
        } else {
          isChangeLimitSuccess = "Limit tidak boleh melebihi " + response.body.toString();
        }

      } catch (e) {
        isChangeLimitSuccess = "Gagal terhubung dengan server";
        print(e);
      }

    } else {
      isChangeLimitSuccess = "Gagal terhubung dengan server";
    }

    return isChangeLimitSuccess;

  }



}

final customerAPI = CustomerAPI();