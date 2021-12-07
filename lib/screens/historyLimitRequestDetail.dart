import 'package:flutter/material.dart';
import 'package:tambah_limit/models/limitHistoryModel.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/widgets/TextView.dart';

class HistoryLimitRequestDetail extends StatefulWidget {
  final LimitHistory model;

  HistoryLimitRequestDetail({Key key, this.model}) : super(key: key);

  @override
  HistoryLimitRequestDetailState createState() => HistoryLimitRequestDetailState();
}


class HistoryLimitRequestDetailState extends State<HistoryLimitRequestDetail> {



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: TextView("Request Limit", 1),
          // leading: IconButton(
          //   icon: Icon(Icons.arrow_back, color: Colors.white),
          //   onPressed: () => Navigator.pop(context),
          // ),
        ),
        body: Container(),
      )
    );
  }

}