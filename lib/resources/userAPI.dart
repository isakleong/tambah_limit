import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' show Client;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tambah_limit/models/userModel.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';

Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();

class UserAPI {
  Client client = Client();

  Future<String> checkAuth(final context, {String parameter=""}) async {
    String isAuthorized = "";
    User user;
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = config.baseUrl + "/" + "authorizeData.php" + (parameter == "" ? "" : "?" + parameter);
    String url_address_2 = config.baseUrlAlt + "/" + "authorizeData.php" + (parameter == "" ? "" : "?" + parameter);

    try {
		  final conn_1 = await ConnectionTest(url_address_1, context);
      printHelp("GET STATUS 1 "+conn_1);
      if(conn_1 == "OK"){
        isUrlAddress_1 = true;
      }
	  } on SocketException {
      isUrlAddress_1 = false;
      isAuthorized = "Gagal terhubung dengan server";
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
        isAuthorized = "Gagal terhubung dengan server";
      }
    }
    if(isUrlAddress_2){
      url = url_address_2;
    }

    if(url != "") {
      try {
        var urlData = Uri.parse(url);
        final response = await client.get(urlData);
        final responseData = decryptData(response.body.toString());

        if(responseData != "false") {
          if(responseData.toLowerCase().contains("connection")) {
            isAuthorized = responseData;
          } else {
            isAuthorized = "OK";
          }
        } else {
          isAuthorized = "Anda tidak lagi memiliki izin untuk menggunakan aplikasi ini";
        }
      } catch (e) {
        isAuthorized = e;
        printHelp(e);
      }
    } else {
      isAuthorized = "Gagal terhubung dengan server";
    }

    return isAuthorized;
  }

  Future<String> login(final context, {String parameter=""}) async {
    String isLoginSuccess = "";
    User user;
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = config.baseUrl + "/" + "getUserData.php" + (parameter == "" ? "" : "?" + parameter);
    String url_address_2 = config.baseUrlAlt + "/" + "getUserData.php" + (parameter == "" ? "" : "?" + parameter);

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
        var urlData = Uri.parse(url);
        final response = await client.get(urlData);
        final responseData = decryptData(response.body.toString());

        if(responseData == "restricted") {
          isLoginSuccess = "Cabang Anda belum dapat menggunakan aplikasi ini";
        } else {
          if(responseData != "false") {
            if(responseData == "autolimit") {
              isLoginSuccess = "Untuk menaikkan limit dapat menggunakan Program Utility NAV";
            } else {
              if(responseData.toLowerCase().contains("connection")) {
                isLoginSuccess = responseData;
              } else {
                var parsedJson = jsonDecode(responseData);
                user = User.fromJson(parsedJson[0]);

                if(user.Id != ""){
                  isLoginSuccess = "OK";
                  await saveToLocalStorage(context, user);
                }
              }    
            }
          } else {
            isLoginSuccess = "Username atau Password salah";
          }
        }
      } catch (e) {
        isLoginSuccess = e;
        printHelp(e);
      }
    } else {
      isLoginSuccess = "Gagal terhubung dengan server";
    }

    return isLoginSuccess;
  }

  Future<String> changePassword(final context, {String parameter=""}) async {
    String isChangePasswordSuccess = "";
    String url = "";

    bool isUrlAddress_1 = false, isUrlAddress_2 = false;
    String url_address_1 = config.baseUrl + "/" + "updatePasswordData.php" + (parameter == "" ? "" : "?" + parameter);
    String url_address_2 = config.baseUrlAlt + "/" + "updatePasswordData.php" + (parameter == "" ? "" : "?" + parameter);

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
        var urlData = Uri.parse(url);
        final response = await client.get(urlData);
        final responseData = decryptData(response.body.toString());

        if(responseData == "success") {
          isChangePasswordSuccess = "OK";
        
        } else {
          isChangePasswordSuccess = responseData;
        }

      } catch (e) {
        isChangePasswordSuccess = e;
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
    String url_address_1 = config.baseUrl + "/" + "getPassData.php" + (parameter == "" ? "" : "?" + parameter);
    String url_address_2 = config.baseUrlAlt + "/" + "getPassData.php" + (parameter == "" ? "" : "?" + parameter);

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
        var urlData = Uri.parse(url);
        final response = await client.get(urlData);
        final responseData = decryptData(response.body.toString());

        if(responseData != "false") {
          if(responseData.toLowerCase().contains("connection")) {
            isGetPasswordSuccess = responseData;
          } else{
            var parsedJson = jsonDecode(responseData);
            user = User.fromJson(parsedJson[0]);

            if(user.Id != ""){
              isGetPasswordSuccess = "OK";
              await saveToLocalStorage(context, user);
            }
          }
        } else {
          isGetPasswordSuccess = "Password Lama Salah";
        }
       } catch (e) {
         isGetPasswordSuccess = e;
       }

    } else {
      isGetPasswordSuccess = "Gagal terhubung dengan server";
    }

    return isGetPasswordSuccess;
  }

  saveToLocalStorage(final context, User user) async {
    final SharedPreferences sharedPreferences = await _sharedPreferences;
    await sharedPreferences.setString("get_user_login", user.Id);
    await sharedPreferences.setString("user_code", user.Id);
    if(user.NIK!="") {
      await sharedPreferences.setString("nik", user.NIK);
    }
    
    await sharedPreferences.setInt("max_limit", int.parse(user.MaxLimit));
    await sharedPreferences.setStringList("module_privilege", user.ModuleId);
  }

}

final userAPI = UserAPI();