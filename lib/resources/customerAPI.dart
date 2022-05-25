import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' show Client;
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/models/customerModel.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';

class CustomerAPI {
  Client client = Client();

  Future<Result> getBlockInfo(final context, {String parameter=""}) async {
    Result result;
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    // String url_address_1 = config.baseUrl + "/" + "getBlockData.php" + (parameter == "" ? "" : "?" + parameter);
    // String url_address_2 = config.baseUrlAlt + "/" + "getBlockData.php" + (parameter == "" ? "" : "?" + parameter);

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
      url = config.baseUrl + "/" + "getBlockData.php" + (parameter == "" ? "" : "?" + parameter);
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
      url = config.baseUrlAlt + "/" + "getBlockData.php" + (parameter == "" ? "" : "?" + parameter);
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
        var urlData = Uri.parse(url);
        final response = await client.get(urlData);
        final responseData = decryptData(response.body.toString());

        if(responseData != "false" && responseData != "otoritas") {
          if(responseData.toLowerCase().contains("connection")) {
            result = new Result(success: 0, message: responseData);
          } else {
            result = new Result(success: 1, message: "OK", data: responseData);
          }
        } else {
          if(responseData == "false") {
            result = new Result(success: 0, message: "Data Customer tidak ditemukan");
          } else if(responseData == "otoritas") {
            result = new Result(success: 0, message: "Anda tidak mempunyai otoritas untuk melihat status blocked pelanggan ini");
          }
        }
      } catch (e) {
        result = new Result(success: -1, message: e.toString());
        print(e.toString());
      }
    } else {
      result = new Result(success: -1, message: "Gagal terhubung dengan server");
    }

    return result;
  }

  Future<Result> getLimit(final context, {String parameter=""}) async {
    Result result;
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    //http://192.168.10.213/dbrudie-2-0-0/getLimit.php?json={ "user_code" : "isak", "kode_customer" : "01A01010001" }
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
      url = config.baseUrl + "/" + "getLimitData.php" + (parameter == "" ? "" : "?" + parameter);
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
      url = config.baseUrlAlt + "/" + "getLimitData.php" + (parameter == "" ? "" : "?" + parameter);
    }

    if(url != "") {
      var response;
      try {
        var urlData = Uri.parse(url);
        response = await client.get(urlData);
        final responseData = decryptData(response.body.toString());

        if(responseData != "false" && responseData != "otoritas") {
          if(responseData.toLowerCase().contains("connection")) {
            result = new Result(success: 0, message: responseData);
          } else {
            if(!responseData.contains("corporate")) {
              result = new Result(success: 1, message: "OK", data: responseData);
            } else {
                var str_split = responseData.split('|');
                result = new Result(success: 0, message: "Customer ini memiliki kode corporate " + str_split[1] + ". Proses tambah limit akan dilanjutkan menggunakan kode corporate tersebut", data: str_split[1]); 
            }
          }
        } else {
          if(responseData == "false") {
            result = new Result(success: 0, message: "Data Customer tidak ditemukan");
          } else if(responseData == "otoritas") {
            result = new Result(success: 0, message: "Anda tidak mempunyai otoritas untuk merubah limit pada pelanggan ini");
          }
        }
      } catch (e) {
        result = new Result(success: -1, message: e.toString());
        print(e.toString());
      }
    } else {
      result = new Result(success: -1, message: "Gagal terhubung dengan server");
    }

    return result;
  }

  Future<Result> getLimitGabungan(final context, {String parameter=""}) async {
    Result result;
    String url = "";

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
      url = config.baseUrl + "/" + "getLimitGabunganData.php" + (parameter == "" ? "" : "?" + parameter);
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
      url = config.baseUrlAlt + "/" + "getLimitGabunganData.php" + (parameter == "" ? "" : "?" + parameter);
    }

    if(url != "") {
      try {
        var urlData = Uri.parse(url);
        final response = await client.get(urlData);
        final responseData = decryptData(response.body.toString());

        if(responseData != "false" && responseData != "otoritas") {
          if(responseData.toLowerCase().contains("connection")) {
            result = new Result(success: 0, message: responseData);
          } else {
            result = new Result(success: 1, message: "OK", data: responseData);
          }
        } else {
          if(responseData == "false") {
            result = new Result(success: 0, message: "Data Customer Gabungan tidak ditemukan");
          } else if(responseData == "otoritas") {
            result = new Result(success: 0, message: "Anda tidak mempunyai otoritas untuk merubah limit pada pelanggan gabungan ini");
          }  
        }

      } catch (e) {
        result = new Result(success: -1, message: e.toString());
        print(e.toString());
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
      url = config.baseUrl + "/" + "updateBlockData.php" + (parameter == "" ? "" : "?" + parameter);
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
      url = config.baseUrlAlt + "/" + "updateBlockData.php" + (parameter == "" ? "" : "?" + parameter);
    }

    if(url != "") {

      try {
        var urlData = Uri.parse(url);
        final response = await client.get(urlData);
        final responseData = decryptData(response.body.toString());

        if(responseData != "false") {
          if(responseData.toLowerCase().contains("connection")) {
            result = new Result(success: 1, message: responseData);
          } else {
            result = new Result(success: 1, message: "Ubah status Blocked berhasil");
          }
        } else {
          result = new Result(success: 0, message: "Gagal terhubung dengan server"); //not needed
        }

      } catch (e) {
        result = new Result(success: -1, message: "Gagal terhubung dengan server");
        print(e.toString());
      }

    } else {
      result = new Result(success: -1, message: "Gagal terhubung dengan server");
    }

    return result;
  }

  Future<String> addRequestLimit(final context, {String parameter=""}) async {
    String isAddRequestLimitSuccess = "";
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
      url = config.baseUrl + "/" + "addRequestLimitData.php" + (parameter == "" ? "" : "?" + parameter);
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
      url = config.baseUrlAlt + "/" + "addRequestLimitData.php" + (parameter == "" ? "" : "?" + parameter);
    }

    if(url != "") {
      try {
        var urlData = Uri.parse(url);
        final response = await client.get(urlData);
        final responseData = decryptData(response.body.toString());

        if(responseData == "success") {
          isAddRequestLimitSuccess = "OK";
        
        } else {
          if(responseData.toLowerCase().contains("connection")) {
            isAddRequestLimitSuccess = responseData;
          } else {
            isAddRequestLimitSuccess = "ACC permintaan limit ini telah diajukan sebelumnya\n\nMohon menunggu permintaan limit ini di-review oleh Sales Director";
          }
        }

      } catch (e) {
        isAddRequestLimitSuccess = e.toString();
        print(e.toString());
      }

    } else {
      isAddRequestLimitSuccess = "Gagal terhubung dengan server";
    }

    return isAddRequestLimitSuccess;

  }

  Future<String> addRequestLimitGabungan(final context, {String parameter=""}) async {
    String isAddRequestLimitSuccess = "";
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
      url = config.baseUrl + "/" + "addRequestLimitGData.php" + (parameter == "" ? "" : "?" + parameter);
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
      url = config.baseUrlAlt + "/" + "addRequestLimitGData.php" + (parameter == "" ? "" : "?" + parameter);
    }

    if(url != "") {
      try {
        var urlData = Uri.parse(url);
        final response = await client.get(urlData);
        final responseData = decryptData(response.body.toString());

        if(responseData == "success") {
          isAddRequestLimitSuccess = "OK";
        
        } else {
          if(responseData.toLowerCase().contains("connection")) {
            isAddRequestLimitSuccess = responseData;
          } else {
            isAddRequestLimitSuccess = "ACC permintaan limit ini telah diajukan sebelumnya\n\nMohon menunggu permintaan limit ini di-review terlebih dahulu";
          }
        }

      } catch (e) {
        isAddRequestLimitSuccess = e.toString();
        print(e.toString());
      }

    } else {
      isAddRequestLimitSuccess = "Gagal terhubung dengan server";
    }

    return isAddRequestLimitSuccess;

  }

  Future<String> updateLimitGabunganRequest(final context, {int command, String parameter=""}) async {
    String isChangeLimitSuccess = "";
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
        url = config.baseUrl + "/" + "updateLimitCRequestData.php" + (parameter == "" ? "" : "?" + parameter);
      } else {
        url = config.baseUrl + "/" + "rejectLimitCRequestData.php" + (parameter == "" ? "" : "?" + parameter);
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
        url = config.baseUrlAlt + "/" + "updateLimitCRequestData.php" + (parameter == "" ? "" : "?" + parameter);
      } else {
        url = config.baseUrlAlt + "/" + "rejectLimitCRequestData.php" + (parameter == "" ? "" : "?" + parameter);
      }
    }

    if(url != "") {
      if(command == 1) {
        try {
          var urlData = Uri.parse(url);
          final response = await client.get(urlData);
          final responseData = decryptData(response.body.toString());

          if(responseData == "success") {
            isChangeLimitSuccess = "OK";
          } else {
            if(responseData.toLowerCase().contains("connection")) {
              isChangeLimitSuccess = responseData;
            } else {
              isChangeLimitSuccess = "Limit tidak boleh melebihi " + responseData;
            }
          }

        } catch (e) {
          isChangeLimitSuccess = e.toString();
          printHelp(e.toString());
        }

      } else {
        try {
          var urlData = Uri.parse(url);
          final response = await client.get(urlData);
          final responseData = decryptData(response.body.toString());

          if(responseData == "success") {
            isChangeLimitSuccess = "OK";
          } else {
            isChangeLimitSuccess = responseData;
          }
        } catch (e) {
          isChangeLimitSuccess = e;
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
        url = config.baseUrl + "/" + "updateLimitRequestData.php" + (parameter == "" ? "" : "?" + parameter);
      } else {
        url = config.baseUrl + "/" + "rejectLimitRequestData.php" + (parameter == "" ? "" : "?" + parameter);
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
        url = config.baseUrlAlt + "/" + "updateLimitRequestData.php" + (parameter == "" ? "" : "?" + parameter);
      } else {
        url = config.baseUrlAlt + "/" + "rejectLimitRequestData.php" + (parameter == "" ? "" : "?" + parameter);
      }
    }

    if(url != "") {
      if(command == 1) {
        try {
          var urlData = Uri.parse(url);
          final response = await client.get(urlData);
          final responseData = decryptData(response.body.toString());

          if(responseData == "success") {
            isChangeLimitSuccess = "OK";
          } else {
            if(responseData.toLowerCase().contains("connection")) {
              isChangeLimitSuccess = responseData;
            } else {
              isChangeLimitSuccess = "Limit tidak boleh melebihi " + responseData;
            }
          }

        } catch (e) {
          isChangeLimitSuccess = e.toString();
          print(e.toString());
        }

      } else {
        try {
          var urlData = Uri.parse(url);
          final response = await client.get(urlData);
          final responseData = decryptData(response.body.toString());

          if(responseData == "success") {
            isChangeLimitSuccess = "OK";
          } else {
            isChangeLimitSuccess = responseData;
          }

        } catch (e) {
          isChangeLimitSuccess = e;
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
      url = config.baseUrl + "/" + "updateLimitData.php" + (parameter == "" ? "" : "?" + parameter);
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
      url = config.baseUrlAlt + "/" + "updateLimitData.php" + (parameter == "" ? "" : "?" + parameter);
    }

    if(url != "") {
      print("url sent "+url);
      try {
        var urlData = Uri.parse(url);
        final response = await client.get(urlData);
        final responseData = decryptData(response.body.toString());

        print("get data "+responseData);

        if(responseData == "success") {
          isChangeLimitSuccess = "OK";
        } else if(responseData == "false") {
          isChangeLimitSuccess = "Limit tidak boleh dibawah NOL";
        } else if(responseData.toLowerCase().contains("connection")) {
          isChangeLimitSuccess = responseData;
        } else {
          isChangeLimitSuccess = "Limit tidak boleh melebihi " + responseData;
        }

      } catch (e) {
        isChangeLimitSuccess = e.toString();
        print(e.toString());
      }

    } else {
      isChangeLimitSuccess = "Gagal terhubung dengan server";
    }

    return isChangeLimitSuccess;

  }

  Future<String> changeLimitGabungan(final context, {String parameter=""}) async {
    String isChangeLimitSuccess = "";
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
      url = config.baseUrl + "/" + "updateLimitGabunganData.php" + (parameter == "" ? "" : "?" + parameter);
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
      url = config.baseUrlAlt + "/" + "updateLimitGabunganData.php" + (parameter == "" ? "" : "?" + parameter);
    }

    if(url != "") {
      try {
        var urlData = Uri.parse(url);
        final response = await client.get(urlData);
        final responseData = decryptData(response.body.toString());

        if(responseData == "success") {
          isChangeLimitSuccess = "OK";
        } else if(responseData == "false") {
          isChangeLimitSuccess = "Limit tidak boleh dibawah NOL";
        } else if(responseData.toLowerCase().contains("connection")){
          isChangeLimitSuccess = responseData;
        } else {
          isChangeLimitSuccess = "Limit tidak boleh melebihi " + responseData;
        }

      } catch (e) {
        isChangeLimitSuccess = e.toString();
        print(e.toString());
      }

    } else {
      isChangeLimitSuccess = "Gagal terhubung dengan server";
    }

    return isChangeLimitSuccess;

  }



}

final customerAPI = CustomerAPI();