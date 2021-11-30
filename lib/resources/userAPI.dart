import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' show Client;
import 'package:tambah_limit/models/resultModel.dart';

import 'package:tambah_limit/models/userModel.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';

class UserAPI{
  Client client = Client();

  Future<String> login(final context, {String parameter=""}) async {
    String isLoginSuccess;
    User user;
    String url = "";

    // http://192.168.10.213/dbrudie-2-0-0/getUser.php?json={ "user_code" : "isak", "user_pass" : "12345", "token" : "cobatoken" }

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = config.baseUrl + "/" + "getUser.php" + (parameter == "" ? "" : "?" + parameter);
    String url_address_2 = config.baseUrlAlt + "/" + "getUser.php" + (parameter == "" ? "" : "?" + parameter);

    try {
		  final conn_1 = await ConnectionTest(url_address_1, context);
      if(conn_1 == "OK"){
        isUrlAddress_1 = true;
      }
	  } on SocketException {
      isUrlAddress_1 = false;
      isLoginSuccess = "Gagal terhubung dengan server";
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
        isLoginSuccess = "Gagal terhubung dengan server";
        // throw Exception('No Internet connection');
      }
    }
    if(isUrlAddress_2){
      url = url_address_2;
    }

    if(url != "") {
      printHelp("GET CONN URL "+url);

      final response = await client.get(
        APIUrl(url, context: context, parameter:parameter)
      );

      printHelp("status code "+response.statusCode.toString());

      printHelp(APIUrl("getUser.php", context: context, parameter:parameter));

      printHelp("cek body "+response.body);
      var parsedJson = jsonDecode(response.body);
      if(response.body.toString() != "false") {
        user = User.fromJson(parsedJson[0]);
        printHelp("CEK LENGTH "+parsedJson.toString());

        if(user.Id != ""){
          isLoginSuccess = "OK";
        } 

      } else {
        isLoginSuccess = "Username atau Password salah";
      }

      // if(user.Id != ""){
      //   isLoginSuccess = "OK";
      // } else {
      //   isLoginSuccess = "Username atau Password salah";
      // }

      // printHelp("test Id coba"+user.Id);
      // printHelp("test MaxLimit coba"+user.MaxLimit);

    } else {
      isLoginSuccess = "Gagal terhubung dengan server";
    }

    return isLoginSuccess;

  }

}

final userAPI = UserAPI();