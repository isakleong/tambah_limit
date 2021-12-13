

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tambah_limit/models/resultModel.dart';

class Chat extends StatefulWidget {
  final Result result;

  const Chat({ Key key, this.result}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Result result;

  @override
  void initState() {
    result = widget.result;  
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _resultObject = jsonDecode(result.data.toString());

    return Scaffold(
      body: Container(
        child: Text("message content "),
      )
    );
  }
}