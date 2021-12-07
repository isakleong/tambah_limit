import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' show Client;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tambah_limit/models/limitHistoryModel.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/models/userModel.dart';
import 'package:tambah_limit/resources/customerAPI.dart';
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

  bool requestLimitHistoryListLoading = true;
  bool approvedLimitHistoryListLoading = true;
  bool rejectedLimitHistoryListLoading = true;

  List<LimitHistory> requestLimitHistoryList = [];
  List<LimitHistory> approvedLimitHistoryList = [];
  List<LimitHistory> rejectedLimitHistoryList = [];

  

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    if(requestLimitHistoryListLoading){
      getRequestHistoryList(1);
    }

    if(approvedLimitHistoryListLoading){
      getRequestHistoryList(2);
    }

    if(rejectedLimitHistoryListLoading){
      getRequestHistoryList(3);
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
                 title: TextView('Riwayat Permintaan Limit', 1),
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
              requestLimitHistoryListLoading
              ?
              loadingRequestHistory()
              :
              requestHistoryWidgetList.length != 0
              ?
              ListView(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                physics: ScrollPhysics(),
                shrinkWrap: true,
                children: requestHistoryWidgetList,
              )
              :
              Container(),

              approvedLimitHistoryListLoading
              ?
              loadingRequestHistory()
              :
              approvedHistoryWidgetList.length != 0
              ?
              ListView(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                physics: ScrollPhysics(),
                shrinkWrap: true,
                children: approvedHistoryWidgetList,
              )
              :
              Container(),

              
              rejectedLimitHistoryListLoading
              ?
              loadingRequestHistory()
              :
              rejectedHistoryWidgetList.length != 0
              ?
              ListView(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                physics: ScrollPhysics(),
                shrinkWrap: true,
                children: rejectedHistoryWidgetList,
              )
              :
              Container(),
            ],
          ),
        ),
      )
    );
  }

  getRequestHistoryList(int type) async {
    Configuration config = Configuration.of(context);

    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
    final SharedPreferences sharedPreferences = await _sharedPreferences;
    String user_code = sharedPreferences.getString('user_code');

    if(type == 1) {
      setState(() {
        requestLimitHistoryListLoading = true;
      });

      requestLimitHistoryList = await limitHistoryAPI.getLimitRequestHistoryList(context, type, parameter: 'json={"user_code":"${user_code}"}');

      setState(() {
        requestLimitHistoryList = requestLimitHistoryList;
        requestLimitHistoryListLoading = false;
      });
    } else if (type == 2) {
      setState(() {
        approvedLimitHistoryListLoading = true;
      });

      approvedLimitHistoryList = await limitHistoryAPI.getLimitRequestHistoryList(context, type, parameter: 'json={"user_code":"${user_code}"}');

      setState(() {
        approvedLimitHistoryList = approvedLimitHistoryList;
        approvedLimitHistoryListLoading = false;
      });
    } else if (type == 3) {
      setState(() {
        rejectedLimitHistoryListLoading = true;
      });

      rejectedLimitHistoryList = await limitHistoryAPI.getLimitRequestHistoryList(context, type, parameter: 'json={"user_code":"${user_code}"}');

      setState(() {
        rejectedLimitHistoryList = rejectedLimitHistoryList;
        rejectedLimitHistoryListLoading = false;
      });
    }
  }

  loadingRequestHistory() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[100],
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: 15,
          itemBuilder: (context, index){
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children : [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    width: 90,
                    height: 25,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        width: 175,
                        height: 25,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        width: 100,
                        height: 25,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
  
  showRequestHistory(Configuration config) {
    List<Widget> tempWidgetList = [];

    final currencyFormatter = NumberFormat('#,##0', 'ID');

    for(int i = 0; i < requestLimitHistoryList.length; i++){
      tempWidgetList.add(
        GestureDetector(
          onTap: (){
            goToHistoryLimitDetail(requestLimitHistoryList[i]);
          },
          child: Card(
            margin: EdgeInsets.only(top: 20),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListTile(
                title: TextView(requestLimitHistoryList[i].customer_code, 4),
                subtitle: TextView(requestLimitHistoryList[i].customer_name, 4),
                trailing: TextView("Rp " + currencyFormatter.format(int.parse(requestLimitHistoryList[i].limit)), 4),
              ),
            ),
          ),
        ),
      );
    }

    return tempWidgetList;

  }

  void goToHistoryLimitDetail(LimitHistory tempLimitHistory) async {
    Result result_;
    if(tempLimitHistory.customer_code.length == 12) {
      result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"${tempLimitHistory.customer_code}","user_code":"${tempLimitHistory.user_code}"}');

      printHelp("get data "+ result_.success.toString());

      Navigator.pushNamed(
        context,
        "getHistoryLimitGabunganDetail",
        arguments: result_
      );

    } else if(tempLimitHistory.customer_code.length == 11) {
      result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"${tempLimitHistory.customer_code}","user_code":"${tempLimitHistory.user_code}"}');

      printHelp("get data "+ result_.success.toString());

      Navigator.pushNamed(
        context,
        "getHistoryLimitDetail",
        arguments: result_
      );

    }

    // var tempResultData = [];
    // tempResultData.add(requestLimitHistoryList[i].toJson());
    // printHelp(jsonEncode(tempResultData));
    // var parsedJson = jsonEncode(tempResultData);
    // Result tempResult = new Result(success: 1, data: parsedJson);

  }

  showApprovedHistory(Configuration config) {
    List<Widget> tempWidgetList = [];

    final currencyFormatter = NumberFormat('#,##0', 'ID');

    for(int i = 0; i < approvedLimitHistoryList.length; i++){
      tempWidgetList.add(
        InkWell(
          child: Card(
            margin: EdgeInsets.only(top: 20),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListTile(
                title: TextView(approvedLimitHistoryList[i].customer_code, 4),
                subtitle: TextView(approvedLimitHistoryList[i].customer_name, 4),
                trailing: TextView("Rp " + currencyFormatter.format(int.parse(approvedLimitHistoryList[i].limit)), 4),
              ),
            ),
          ),
        ),
      );
    }

    return tempWidgetList;

  }

  showRejectedHistory(Configuration config) {
    List<Widget> tempWidgetList = [];

    final currencyFormatter = NumberFormat('#,##0', 'ID');

    for(int i = 0; i < rejectedLimitHistoryList.length; i++){
      tempWidgetList.add(
        InkWell(
          child: Card(
            margin: EdgeInsets.only(top: 20),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListTile(
                title: TextView(rejectedLimitHistoryList[i].customer_code, 4),
                subtitle: TextView(rejectedLimitHistoryList[i].customer_name, 4),
                trailing: TextView("Rp " + currencyFormatter.format(int.parse(rejectedLimitHistoryList[i].limit)), 4),
              ),
            ),
          ),
        ),
      );
    }

    return tempWidgetList;

  }

}