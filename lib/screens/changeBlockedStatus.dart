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


class ChangeBlockedStatus extends StatefulWidget {
  final Result result;

  const ChangeBlockedStatus({Key key, this.result}) : super(key: key);

  @override
  ChangeBlockedStatusState createState() => ChangeBlockedStatusState();
}


class ChangeBlockedStatusState extends State<ChangeBlockedStatus> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Text("ChangeBlockedStatus"),
      ),
    );
  }

}