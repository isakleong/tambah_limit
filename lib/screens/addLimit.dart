import 'dart:async';
import 'package:http/http.dart' show Client;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/models/userModel.dart';
import 'package:tambah_limit/resources/userAPI.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';
import 'package:tambah_limit/widgets/EditText.dart';
import 'package:tambah_limit/widgets/TextView.dart';
import 'package:tambah_limit/widgets/button.dart';


class AddLimit extends StatefulWidget {
  final Result result;

  const AddLimit({Key key, this.result}) : super(key: key);

  @override
  AddLimitState createState() => AddLimitState();
}


class AddLimitState extends State<AddLimit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Text("AddLimit"),
      ),
    );
  }

}