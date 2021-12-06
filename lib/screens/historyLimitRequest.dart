import 'dart:async';
import 'package:http/http.dart' show Client;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tambah_limit/models/limitHistoryModel.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/models/userModel.dart';
import 'package:tambah_limit/resources/limitHistoryAPI.dart';
import 'package:tambah_limit/resources/userAPI.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';
import 'package:tambah_limit/widgets/EditText.dart';
import 'package:tambah_limit/widgets/TextView.dart';
import 'package:tambah_limit/widgets/button.dart';


class HistoryLimitRequest extends StatefulWidget {
  final Result result;

  const HistoryLimitRequest({Key key, this.result}) : super(key: key);

  @override
  HistoryLimitRequestState createState() => HistoryLimitRequestState();
}


class HistoryLimitRequestState extends State<HistoryLimitRequest> {

  Result result;

  bool requestHistoryListLoading = true;
  bool approvedHistoryListLoading = true;
  bool rejectHistoryListLoading = true;

  List<LimitHistory> requestHistoryList = [];

  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    if(requestHistoryListLoading){
      getRequestHistoryList();
    }
    
  }
  
  @override
  Widget build(BuildContext context) {

    List<Widget> requestHistoryWidgetList = showRequestHistory(config);
    List<Widget> approvedHistoryWidgetList = showApprovedHistory(config);
    List<Widget> rejectedHistoryWidgetList = showRejectedHistory(config);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
               new SliverAppBar(
                 title: Text('Tambah Limit Detail'),
                 pinned: true,
                 floating: true,
                 bottom: TabBar(
                   indicatorColor: Colors.amber,
                   indicatorWeight: 3,
                   tabs: [
                     Tab(icon: Icon(Icons.request_quote), child: TextView("Permintaan", 3)),
                     Tab(icon: Icon(Icons.check), child: TextView("Disetujui", 3)),
                     Tab(icon: Icon(Icons.close), child: TextView("Ditolak", 3)),
                    ],
                  ),
               )
            ];
          },
          body: TabBarView(
            children: [
              requestHistoryWidgetList.length != 0
              ?
              ListView(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.all(0),
                physics: ScrollPhysics(),
                shrinkWrap: true,
                children: requestHistoryWidgetList,
              )
              :
              Container(),
              Container(),
              Container(),
            ],
          ),
        ),
      )
    );
  }

  getRequestHistoryList() async {
    Configuration config = Configuration.of(context);

    setState(() {
      requestHistoryListLoading = true;
    });

    // Alert(context: context, loading: true, disableBackButton: true);

    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
    final SharedPreferences sharedPreferences = await _sharedPreferences;
    String user_code = sharedPreferences.getString('user_code');

    Result result_ = await limitHistoryAPI.getLimitRequestHistory(context, parameter: 'json={"user_code":"${user_code}"}');

    // requestHistoryList = await limitHistoryAPI.getLimitRequestHistoryList(context, parameter: 'json={"user_code":"${user_code}"}');

    // Navigator.of(context).pop();

    setState(() {
      requestHistoryList = requestHistoryList;
      requestHistoryListLoading = false;
    });

    // if(result_.success == 1){
    //   setState(() {
    //     result = result_;
    //   });
    // }
  }
  

  showRequestHistory(Configuration config) {
    List<Widget> tempWidgetList = [];

    final currencyFormatter = NumberFormat('#,##0', 'ID');

    for(int i = 0; i < requestHistoryList.length; i++){
      tempWidgetList.add(
        Container(
          child: Text(requestHistoryList[i].customer_name),
        ),
      );
    }

    

  
    
    return tempWidgetList;

  }

  showApprovedHistory(Configuration config) {
    List<Widget> tempWidgetList = [];

    final currencyFormatter = NumberFormat('#,##0', 'ID');

    tempWidgetList.add(
      Container(),
    );

  
    
    return tempWidgetList;

  }

  showRejectedHistory(Configuration config) {
    List<Widget> tempWidgetList = [];

    final currencyFormatter = NumberFormat('#,##0', 'ID');

    tempWidgetList.add(
      Container(),
    );

  
    
    return tempWidgetList;

  }

}