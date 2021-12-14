import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' show Client;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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

Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();

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
      child: Builder(builder: (BuildContext context) {
        // print('Current Index: ${DefaultTabController.of(context).index}');
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                new SliverAppBar(
                  title: TextView('Riwayat Permintaan Limit', 1),
                  pinned: true,
                  floating: true,
                  bottom: TabBar(
                    indicatorColor: Colors.white,
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
                SmartRefresher(
                  onRefresh: _onRequestRefresh,
                  controller: _refreshRequestController,
                  physics: BouncingScrollPhysics(),
                  header: WaterDropMaterialHeader(),
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    children: requestHistoryWidgetList,
                  ),
                )
                :
                SmartRefresher(
                  onRefresh: _onRequestRefresh,
                  controller: _refreshRequestController,
                  physics: BouncingScrollPhysics(),
                  header: WaterDropMaterialHeader(),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Image.asset("assets/illustration/request-history.png", alignment: Alignment.center, fit: BoxFit.fill, scale: 2.75)
                        ),
                        SizedBox(height: 30),
                        Container(
                          child: TextView("Tidak ada data permintaan limit\nyang diminta", 3, color: config.grayColor, align: TextAlign.center),
                        )
                      ],
                    )
                  ),
                ),
            
                approvedLimitHistoryListLoading
                ?
                loadingRequestHistory()
                :
                approvedHistoryWidgetList.length != 0
                ?
                SmartRefresher(
                  onRefresh: _onApprovedRefresh,
                  controller: _refreshApprovedController,
                  physics: BouncingScrollPhysics(),
                  header: WaterDropMaterialHeader(),
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    children: approvedHistoryWidgetList,
                  ),
                )
                :
                SmartRefresher(
                  onRefresh: _onApprovedRefresh,
                  controller: _refreshApprovedController,
                  physics: BouncingScrollPhysics(),
                  header: WaterDropMaterialHeader(),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Image.asset("assets/illustration/accepted-history.png", alignment: Alignment.center, fit: BoxFit.fill, scale: 2.75)
                        ),
                        SizedBox(height: 30),
                        Container(
                          child: TextView("Tidak ada data permintaan limit\nyang disetujui", 3, color: config.grayColor, align: TextAlign.center),
                        )
                      ],
                    )
                  ),
                ),
            
                
                rejectedLimitHistoryListLoading
                ?
                loadingRequestHistory()
                :
                rejectedHistoryWidgetList.length != 0
                ?
                SmartRefresher(
                  onRefresh: _onRejectedRefresh,
                  controller: _refreshRejectedController,
                  physics: BouncingScrollPhysics(),
                  header: WaterDropMaterialHeader(),
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    children: rejectedHistoryWidgetList,
                  ),
                )
                :
                SmartRefresher(
                  onRefresh: _onRejectedRefresh,
                  controller: _refreshRejectedController,
                  physics: BouncingScrollPhysics(),
                  header: WaterDropMaterialHeader(),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Image.asset("assets/illustration/rejected-history.png", alignment: Alignment.center, fit: BoxFit.fill, scale: 2.75)
                        ),
                        SizedBox(height: 30),
                        Container(
                          child: TextView("Tidak ada data permintaan limit\nyang ditolak", 3, color: config.grayColor, align: TextAlign.center),
                        )
                      ],
                    )
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      
      
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
        Card(
          margin: EdgeInsets.only(top: 20),
          elevation: 3,
          child: InkWell(
            onTap: () {
              goToHistoryLimitDetail(requestLimitHistoryList[i], 1);
            },
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

  void goToHistoryLimitDetail(LimitHistory tempLimitHistory, int type) async {
    Result result_;

    if(tempLimitHistory.customer_code.length > 11) {
      Alert(context: context, loading: true, disableBackButton: true);

      result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"${tempLimitHistory.customer_code}","user_code":"${tempLimitHistory.user_code}"}');

      final SharedPreferences sharedPreferences = await _sharedPreferences;
      await sharedPreferences.setInt("request_limit", int.parse(tempLimitHistory.limit));
      await sharedPreferences.setString("user_code_request", tempLimitHistory.user_code);

      Navigator.of(context).pop();

      if(type == 1) {
        Navigator.popAndPushNamed(
          context,
          "historyLimitRequestDetail/${tempLimitHistory.id}/4",
          arguments: result_,
        );
      } else if(type == 2) {
        Navigator.popAndPushNamed(
          context,
          "historyLimitRequestDetail/${tempLimitHistory.id}/5",
          arguments: result_,
        );
      } else {
        Navigator.popAndPushNamed(
          context,
          "historyLimitRequestDetail/${tempLimitHistory.id}/6",
          arguments: result_,
        );
      }

    } else {
      Alert(context: context, loading: true, disableBackButton: true);

      result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"${tempLimitHistory.customer_code}","user_code":"${tempLimitHistory.user_code}"}');

      // final SharedPreferences sharedPreferences = await _sharedPreferences;
      // await sharedPreferences.setInt("request_limit", int.parse(tempLimitHistory.limit));
      // await sharedPreferences.setString("user_code_request", tempLimitHistory.user_code);

      Navigator.of(context).pop();

      Navigator.popAndPushNamed(
        context,
        "historyLimitRequestDetail/${tempLimitHistory.id}/$type",
        arguments: result_,
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
        Card(
          margin: EdgeInsets.only(top: 20),
          elevation: 3,
          child: InkWell(
            onTap: (){
              goToHistoryLimitDetail(approvedLimitHistoryList[i], 2);
            },
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
        Card(
          margin: EdgeInsets.only(top: 20),
          elevation: 3,
          child: InkWell(
            onTap: (){
              goToHistoryLimitDetail(rejectedLimitHistoryList[i], 3);
            },
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

  RefreshController _refreshRequestController =
      RefreshController(initialRefresh: false);

  void _onRequestRefresh() async{
    setState(() {
      requestLimitHistoryListLoading = true;
      // approvedLimitHistoryListLoading = true;
      // rejectedLimitHistoryListLoading = true;
    });

    if(requestLimitHistoryListLoading){
      getRequestHistoryList(1);
    }

    // if(approvedLimitHistoryListLoading){
    //   getRequestHistoryList(2);
    // }

    // if(rejectedLimitHistoryListLoading){
    //   getRequestHistoryList(3);
    // }
  }

  RefreshController _refreshApprovedController =
      RefreshController(initialRefresh: false);

  void _onApprovedRefresh() async{
    setState(() {
      // requestLimitHistoryListLoading = true;
      approvedLimitHistoryListLoading = true;
      // rejectedLimitHistoryListLoading = true;
    });

    // if(requestLimitHistoryListLoading){
    //   getRequestHistoryList(1);
    // }

    if(approvedLimitHistoryListLoading){
      getRequestHistoryList(2);
    }

    // if(rejectedLimitHistoryListLoading){
    //   getRequestHistoryList(3);
    // }
  }

  RefreshController _refreshRejectedController =
      RefreshController(initialRefresh: false);

  void _onRejectedRefresh() async{
    setState(() {
      // requestLimitHistoryListLoading = true;
      // approvedLimitHistoryListLoading = true;
      rejectedLimitHistoryListLoading = true;
    });

    // if(requestLimitHistoryListLoading){
    //   getRequestHistoryList(1);
    // }

    // if(approvedLimitHistoryListLoading){
    //   getRequestHistoryList(2);
    // }

    if(rejectedLimitHistoryListLoading){
      getRequestHistoryList(3);
    }
  }

}