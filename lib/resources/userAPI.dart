import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' show Client, Request;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tambah_limit/models/resultModel.dart';

import 'package:tambah_limit/models/userModel.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';

Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();

class UserAPI {
  Client client = Client();

  Future<String> login(final context, {String parameter=""}) async {
    String isLoginSuccess = "";
    User user;
    String url = "";

    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
    final SharedPreferences sharedPreferences = _sharedPreferences;

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = config.baseUrl + "/" + "getUserCoba.php" + (parameter == "" ? "" : "?" + parameter);
    String url_address_2 = config.baseUrlAlt + "/" + "getUserCoba.php" + (parameter == "" ? "" : "?" + parameter);

    try {
		  final conn_1 = await ConnectionTest(url_address_1, context);
      printHelp("GET STATUS 1 "+conn_1);
      if(conn_1 == "OK"){
        isUrlAddress_1 = true;
      }
	  } on SocketException {
      isUrlAddress_1 = false;
      isLoginSuccess = "Gagal terhubung dengan server";
    }

    if(isUrlAddress_1) {
      url = url_address_1;
    } else {
      try {
        final conn_2 = await ConnectionTest(url_address_2, context);
        printHelp("GET STATUS 2 "+conn_2);
        if(conn_2 == "OK"){
          isUrlAddress_2 = true;
        }
      } on SocketException {
        isUrlAddress_2 = false;
        isLoginSuccess = "Gagal terhubung dengan server";
      }
    }
    if(isUrlAddress_2){
      url = url_address_2;
    }

    if(url != "") {
      try {
        // final response = await client.get(url);

        final response = await client.get(url);

        var parsedJson = jsonDecode(response.body);
        if(response.body.toString() != "false") {
          user = User.fromJson(parsedJson[0]);

          if(user.Id != ""){
            isLoginSuccess = "OK";
            await saveToLocalStorage(context, user);
          } 

        } else {
          isLoginSuccess = "Username atau Password salah";
        }
      } catch (e) {
        isLoginSuccess = "Gagal terhubung dengan server";
        printHelp(e);
      }
    } else {
      isLoginSuccess = "Gagal terhubung dengan server";
    }

    return isLoginSuccess;
  }

  Future<String> changePassword(final context, {String parameter=""}) async {
    String isChangePasswordSuccess = "";
    User user;
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = config.baseUrl + "/" + "updatePasswordCoba.php" + (parameter == "" ? "" : "?" + parameter);
    String url_address_2 = config.baseUrlAlt + "/" + "updatePasswordCoba.php" + (parameter == "" ? "" : "?" + parameter);

    try {
		  final conn_1 = await ConnectionTest(url_address_1, context);
      if(conn_1 == "OK"){
        isUrlAddress_1 = true;
      }
	  } on SocketException {
      isUrlAddress_1 = false;
      isChangePasswordSuccess = "Gagal terhubung dengan server";
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
        isChangePasswordSuccess = "Gagal terhubung dengan server";
      }
    }
    if(isUrlAddress_2){
      url = url_address_2;
    }

    if(url != "") {
      try {
        final response = await client.get(url);

        if(response.body.toString() == "success") {
          isChangePasswordSuccess = "OK";
        
        } else {
          isChangePasswordSuccess = "Gagal terhubung dengan server";
        }

      } catch (e) {
        isChangePasswordSuccess = "Gagal terhubung dengan server";
        printHelp(e);
      }

    } else {
      isChangePasswordSuccess = "Gagal terhubung dengan server";
    }

    return isChangePasswordSuccess;
  }

  Future<String> getPassword(final context, {String parameter=""}) async {
    String isGetPasswordSuccess = "";
    User user;
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = config.baseUrl + "/" + "getPassCoba.php" + (parameter == "" ? "" : "?" + parameter);
    String url_address_2 = config.baseUrlAlt + "/" + "getPassCoba.php" + (parameter == "" ? "" : "?" + parameter);

    try {
		  final conn_1 = await ConnectionTest(url_address_1, context);
      if(conn_1 == "OK"){
        isUrlAddress_1 = true;
      }
	  } on SocketException {
      isUrlAddress_1 = false;
      isGetPasswordSuccess = "Gagal terhubung dengan server";
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
        isGetPasswordSuccess = "Gagal terhubung dengan server";
      }
    }
    if(isUrlAddress_2){
      url = url_address_2;
    }

    if(url != "") {
      try {
         final response = await client.get(url);
         var parsedJson = jsonDecode(response.body);

        if(response.body.toString() != "false") {
          user = User.fromJson(parsedJson[0]);
          printHelp("CEK LENGTH "+parsedJson.toString());

          if(user.Id != ""){
            isGetPasswordSuccess = "OK";
            await saveToLocalStorage(context, user);
          } 

        } else {
          isGetPasswordSuccess = "Password Lama Salah";
        }

       } catch (e) {
         isGetPasswordSuccess = "Gagal terhubung dengan server";
         printHelp(e)   ;
       }

    } else {
      isGetPasswordSuccess = "Gagal terhubung dengan server";
    }

    return isGetPasswordSuccess;
  }

  saveToLocalStorage(final context, User user) async {
    Configuration config = Configuration.of(context);

    final SharedPreferences sharedPreferences = await _sharedPreferences;
    await sharedPreferences.setString("user_code", user.Id);
    await sharedPreferences.setInt("max_limit", int.parse(user.MaxLimit));
  }

}

final userAPI = UserAPI();