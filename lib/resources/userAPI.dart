import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' show Client;
import 'package:tambah_limit/models/resultModel.dart';

import 'package:tambah_limit/models/userModel.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/tools/function.dart';

class UserAPI{
  Client client = Client();

  Future<Result> login(final context, {String parameter=""}) async {
    Result result;

    // http://192.168.10.213/dbrudie-2-0-0/getUser.php?json={ "user_code" : "isak", "user_pass" : "12345", "token" : "cobatoken" }

    final response = await client.get(
      APIUrl("getUser.php", context: context, parameter:parameter)
    );

    printHelp(APIUrl("getUser.php", context: context, parameter:parameter));

    var parsedJson = jsonDecode(response.body);
    result = Result.fromJson(parsedJson);
    
    print("object api");
    printHelp(result.success);

    // if(result.success == 1) {
    //   User user = User.fromJson(result.data);

    //   List<String> loginUserList = await getUserLoginList();
    //   loginUserList.add(json.encode(user.toJson()));
    //   await prefs.setStringList("loginUserList", loginUserList);

    // }

    return result;
  }

}

final userAPI = UserAPI();