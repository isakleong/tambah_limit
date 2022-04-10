import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' show Client;
import 'package:tambah_limit/models/limitHistoryModel.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';

class LimitHistoryAPI {
  Client client = Client();

  // Future<Result> getLimitRequestHistory(final context, {String parameter=""}) async {
  //   Result result;
  //   String getLimitRequestHistorySuccess = "";
  //   LimitHistory limitHistory;
  //   String url = "";

  //   bool isUrlAddress_1 = false, isUrlAddress_2 = false;
  //   String url_address_1 = config.baseUrl + "/" + "getLimitReqHist.php" + (parameter == "" ? "" : "?" + parameter);
  //   String url_address_2 = config.baseUrlAlt + "/" + "getLimitReqHist.php" + (parameter == "" ? "" : "?" + parameter);

  //   try {
	// 	  final conn_1 = await ConnectionTest(url_address_1, context);
  //     if(conn_1 == "OK"){
  //       isUrlAddress_1 = true;
  //     }
	//   } on SocketException {
  //     isUrlAddress_1 = false;
  //     getLimitRequestHistorySuccess = "Gagal terhubung dengan server";
  //     result = new Result(success: -1, message: "Gagal terhubung dengan server");
  //   }

  //   if(isUrlAddress_1) {
  //     url = url_address_1;
  //   } else {
  //     try {
  //       final conn_2 = await ConnectionTest(url_address_2, context);
  //       if(conn_2 == "OK"){
  //         isUrlAddress_2 = true;
  //       }
  //     } on SocketException {
  //       isUrlAddress_2 = false;
  //       getLimitRequestHistorySuccess = "Gagal terhubung dengan server";
  //       result = new Result(success: -1, message: "Gagal terhubung dengan server");
  //     }
  //   }
  //   if(isUrlAddress_2){
  //     url = url_address_2;
  //   }

  //   if(url != "") {
  //     try {
  //       final response = await client.get(url);

  //       printHelp("status code "+response.statusCode.toString());

  //       printHelp("cek body "+response.body);
  //       var parsedJson = jsonDecode(response.body);

  //       if(response.body.toString() != "false") {
  //         limitHistory = LimitHistory.fromJson(parsedJson[0]);

  //         if(limitHistory.customer_code != ""){
  //           getLimitRequestHistorySuccess = "OK";
  //         }

  //         var resultObject = jsonEncode(response.body);
  //         result = new Result(success: 1, message: "OK", data: response.body.toString());

  //       } else {
  //         getLimitRequestHistorySuccess = "Data tidak ditemukan";
  //         result = new Result(success: 0, message: "Data tidak ditemukan");
  //       }

  //     } catch (e) {
  //       getLimitRequestHistorySuccess = "Gagal terhubung dengan server";
  //       result = new Result(success: -1, message: "Gagal terhubung dengan server");
  //       print(e);
  //     }

  //   } else {
  //     getLimitRequestHistorySuccess = "Gagal terhubung dengan server";
  //     result = new Result(success: -1, message: "Gagal terhubung dengan server");
  //   }

  //   return result;

  // }

  Future<String> getLimitRequestApprovalStatus(final context, {String parameter=""}) async {
    String isGetLimitRequestApprovalStatusSuccess = "";
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
      isGetLimitRequestApprovalStatusSuccess = "Gagal terhubung dengan server";
      // throw Exception('No Internet connection');
    }

    if(isUrlAddress_1) {
      url = config.baseUrl + "/" + "getLimitRequestApprovalStatus.php" + (parameter == "" ? "" : "?" + parameter);
    } else {
      try {
        final conn_2 = await ConnectionTest(url_address_2, context);
        if(conn_2 == "OK"){
          isUrlAddress_2 = true;
        }
      } on SocketException {
        isUrlAddress_2 = false;
        isGetLimitRequestApprovalStatusSuccess = "Gagal terhubung dengan server";
        // throw Exception('No Internet connection');
      }
    }
    if(isUrlAddress_2){
      url = config.baseUrlAlt + "/" + "getLimitRequestApprovalStatus.php" + (parameter == "" ? "" : "?" + parameter);
    }

    if(url != "") {
      try {
        var urlData = Uri.parse(url);
        final response = await client.get(urlData);

        printHelp("status code "+response.statusCode.toString());

        printHelp("cek body "+response.body);

        isGetLimitRequestApprovalStatusSuccess = response.body.toString();

      } catch (e) {
        isGetLimitRequestApprovalStatusSuccess = "Gagal terhubung dengan server";
        print(e);
      }

    } else {
      isGetLimitRequestApprovalStatusSuccess = "Gagal terhubung dengan server";
    }

    return isGetLimitRequestApprovalStatusSuccess;

  }

  Future<List<LimitHistory>> getLimitRequestHistoryList(final context, int type, {String parameter = ""}) async {
    
    Result result;
    List<LimitHistory> limitHistoryList =[];

    String getLimitRequestHistorySuccess = "";
    String url = "";

    String url_address_1 = "", url_address_2 = "";
    bool isUrlAddress_1 = false, isUrlAddress_2 = false;

    if(type == 1) {
      url_address_1 = config.baseUrl + "/" + "getLimitReqHistCoba.php" + (parameter == "" ? "" : "?" + parameter);
      url_address_2 = config.baseUrlAlt + "/" + "getLimitReqHistCoba.php" + (parameter == "" ? "" : "?" + parameter);
    } else if(type == 2) {
      url_address_1 = config.baseUrl + "/" + "getLimitDoneHistCoba.php" + (parameter == "" ? "" : "?" + parameter);
      url_address_2 = config.baseUrlAlt + "/" + "getLimitDoneHistCoba.php" + (parameter == "" ? "" : "?" + parameter);
    } else if(type == 3) {
      url_address_1 = config.baseUrl + "/" + "getLimitRejectHistCoba.php" + (parameter == "" ? "" : "?" + parameter);
      url_address_2 = config.baseUrlAlt + "/" + "getLimitRejectHistCoba.php" + (parameter == "" ? "" : "?" + parameter);
    }

    try {
		  final conn_1 = await ConnectionTest(url_address_1, context);
      if(conn_1 == "OK"){
        isUrlAddress_1 = true;
      }
	  } on SocketException {
      isUrlAddress_1 = false;
      getLimitRequestHistorySuccess = "Gagal terhubung dengan server";
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
        getLimitRequestHistorySuccess = "Gagal terhubung dengan server";
        result = new Result(success: -1, message: "Gagal terhubung dengan server");
      }
    }
    if(isUrlAddress_2){
      url = url_address_2;
    }

    if(url != ""){
      try {
        var urlData = Uri.parse(url);
        final response = await client.get(urlData);

        printHelp("status code "+response.statusCode.toString());
        printHelp("cek body "+response.body);

        var parsedJson = jsonDecode(response.body);

        if(response.body.toString() != "false") {
          printHelp("masuk sini 1");
          // limitHistory = LimitHistory.fromJson(response.body);

          // if(limitHistory.customer_code != ""){
          //   printHelp("masuk sini 2 "+limitHistory.customer_code);
          //   getLimitRequestHistorySuccess = "OK";
          // }

          result = new Result(success: 1, message: "OK", data: parsedJson);

          // final parsedJson = jsonDecode(response.body);
          // result = Result.fromJson(parsedJson);
          result.data.map((item) {
              limitHistoryList.add(LimitHistory.fromJson(item));
            }).toList();

          // var resultObject = jsonDecode(result.data.toString());
          // limitHistoryList.add(LimitHistory.fromJson(parsedJson))

          printHelp("cek list length "+ limitHistoryList.length.toString());

          // if (result.success == 1) {
          //   if (result.data[0] != null) {
          //     result.data[0].map((item) {
          //       limitHistoryList.add(LimitHistory.fromJson(item));
          //     }).toList();
          //   }
          // }

        } else {
          getLimitRequestHistorySuccess = "Data tidak ditemukan";
          result = new Result(success: 0, message: "Data tidak ditemukan");
        }

      } catch (e) {
        getLimitRequestHistorySuccess = "Gagal terhubung dengan server";
        result = new Result(success: -1, message: "Gagal terhubung dengan server");
        print(e);
      }

    } else {
      getLimitRequestHistorySuccess = "Gagal terhubung dengan server";
      result = new Result(success: -1, message: "Gagal terhubung dengan server");
    }

    return limitHistoryList;
  }

}

final limitHistoryAPI = LimitHistoryAPI();