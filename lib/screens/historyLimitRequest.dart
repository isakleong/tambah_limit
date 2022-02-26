import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' show Client;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tambah_limit/models/limitHistoryModel.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/models/userModel.dart';
import 'package:tambah_limit/resources/customerAPI.dart';
import 'package:tambah_limit/resources/limitHistoryAPI.dart';
import 'package:tambah_limit/resources/userAPI.dart';
import 'package:tambah_limit/screens/historyLimitRequestDetail.dart';
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

  List<bool> selectedLimitRequestHistoryData = [true, false, false];
  List<bool> selectedLimitApprovedHistoryData = [true, false, false];
  List<bool> selectedLimitRejectedHistoryData = [true, false, false];
  FocusNode focusNodeButton1 = FocusNode();
  FocusNode focusNodeButton2 = FocusNode();
  FocusNode focusNodeButton3 = FocusNode();
  List<FocusNode> focusToggle;

  String user_login = "";

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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_login = prefs.getString("get_user_login");  
    });
  }
  
  var top;
  @override
  Widget build(BuildContext context) {

    List<Widget> requestHistoryWidgetList = showRequestHistory(config);
    List<Widget> approvedHistoryWidgetList = showApprovedHistory(config);
    List<Widget> rejectedHistoryWidgetList = showRejectedHistory(config);

    List<bool> selectionDataRequestHistory = List.generate(3, (index) => false);

    return DefaultTabController(
      length: 3,
      child: Builder(builder: (BuildContext context) {
        // print('Current Index: ${DefaultTabController.of(context).index}');
        return Scaffold(
          resizeToAvoidBottomInset: true,
          // appBar: PreferredSize(
          // preferredSize: Size.fromHeight(140),
          // child: AppBar(
          //   flexibleSpace: SafeArea(
          //     child: Container(
          //       margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             children: [
          //               TextView("Selamat Datang, " + user_login.toUpperCase(), 3),
          //               InkWell(
          //                 onTap: () {
          //                   Alert(
          //                     context: context,
          //                     title: "Konfirmasi,",
          //                     content: Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
          //                     cancel: true,
          //                     type: "warning",
          //                     defaultAction: () async {
          //                       SharedPreferences prefs = await SharedPreferences.getInstance();
          //                       await prefs.remove("limit_dmd");
          //                       await prefs.remove("request_limit");
          //                       await prefs.remove("user_code_request");
          //                       await prefs.remove("user_code");
          //                       await prefs.remove("max_limit");
          //                       await prefs.remove("fcmToken");
          //                       await prefs.remove("get_user_login");
          //                       await FirebaseMessaging.instance.deleteToken();
          //                       await prefs.clear();
          //                       Navigator.pushReplacementNamed(
          //                         context,
          //                         "login",
          //                       );
          //                     }
          //                   );
          //               },
          //               child: Container(
          //                 child:Icon (Icons.logout, size: 30, color: Colors.white),
          //                 ),
          //               ),
          //             ],
          //           ),
          //           Container(
          //             child: TextView("Riwayat Permintaan Limit", 1)
          //           ),

          //         ],
          //       ),
          //     ),
          //   ),
          //   automaticallyImplyLeading: false,
          //   ),
          // ),
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                new SliverAppBar(
                  expandedHeight: 150,
                  // flexibleSpace: LayoutBuilder(builder: (context, constraints) {
                  //   top = constraints.biggest.height;
                  //   print(top);
                  //   return SafeArea(
                  //     child: Container(
                  //       margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  //       child: Column(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               TextView("Selamat Datang, " + user_login.toUpperCase(), 3),
                  //               InkWell(
                  //                 onTap: () {
                  //                   Alert(
                  //                     context: context,
                  //                     title: "Konfirmasi,",
                  //                     content: Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
                  //                     cancel: true,
                  //                     type: "warning",
                  //                     defaultAction: () async {
                  //                       SharedPreferences prefs = await SharedPreferences.getInstance();
                  //                       await prefs.remove("limit_dmd");
                  //                       await prefs.remove("request_limit");
                  //                       await prefs.remove("user_code_request");
                  //                       await prefs.remove("user_code");
                  //                       await prefs.remove("max_limit");
                  //                       await prefs.remove("fcmToken");
                  //                       await prefs.remove("get_user_login");
                  //                       await FirebaseMessaging.instance.deleteToken();
                  //                       await prefs.clear();
                  //                       Navigator.pushReplacementNamed(
                  //                         context,
                  //                         "login",
                  //                       );
                  //                     }
                  //                   );
                  //               },
                  //               child: Container(
                  //                 child:Icon (Icons.logout, size: 30, color: Colors.white),
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //           Container(
                  //             child: TextView("Riwayat Permintaan Limit", 1)
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   );
                  // }),

                  // flexibleSpace: SafeArea(
                  //   child: Container(
                  //     margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //           children: [
                  //             TextView("Selamat Datang, " + user_login.toUpperCase(), 3),
                  //             InkWell(
                  //               onTap: () {
                  //                 Alert(
                  //                   context: context,
                  //                   title: "Konfirmasi,",
                  //                   content: Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
                  //                   cancel: true,
                  //                   type: "warning",
                  //                   defaultAction: () async {
                  //                     SharedPreferences prefs = await SharedPreferences.getInstance();
                  //                     await prefs.remove("limit_dmd");
                  //                     await prefs.remove("request_limit");
                  //                     await prefs.remove("user_code_request");
                  //                     await prefs.remove("user_code");
                  //                     await prefs.remove("max_limit");
                  //                     await prefs.remove("fcmToken");
                  //                     await prefs.remove("get_user_login");
                  //                     await FirebaseMessaging.instance.deleteToken();
                  //                     await prefs.clear();
                  //                     Navigator.pushReplacementNamed(
                  //                       context,
                  //                       "login",
                  //                     );
                  //                   }
                  //                 );
                  //             },
                  //             child: Container(
                  //               child:Icon (Icons.logout, size: 30, color: Colors.white),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //         // Container(
                  //         //   child: TextView("Riwayat Permintaan Limit", 1)
                  //         // ),
                          
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  
                  title: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextView("Selamat Datang, " + user_login.toUpperCase(), 3),
                          InkWell(
                            onTap: () {
                              Alert(
                                context: context,
                                title: "Konfirmasi,",
                                content: Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
                                cancel: true,
                                type: "warning",
                                defaultAction: () async {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await prefs.remove("limit_dmd");
                                  await prefs.remove("request_limit");
                                  await prefs.remove("user_code_request");
                                  await prefs.remove("user_code");
                                  await prefs.remove("max_limit");
                                  await prefs.remove("fcmToken");
                                  await prefs.remove("get_user_login");
                                  await FirebaseMessaging.instance.deleteToken();
                                  await prefs.clear();
                                  Navigator.pushReplacementNamed(
                                    context,
                                    "login",
                                  );
                                }
                              );
                          },
                          child: Container(
                            child:Icon (Icons.logout, size: 30, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      // TextView('Riwayat Permintaan Limit', 1),
                    ],
                  ),
                  pinned: true,
                  floating: true,
                  bottom: TabBar(
                    isScrollable: true,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
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
                !user_login.toLowerCase().contains("dsd")
                ?
                requestHistoryWidgetList.length != 0
                ?
                SmartRefresher(
                  onRefresh: _onHistoryRefresh,
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
                  onRefresh: _onHistoryRefresh,
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
                )
                :
                requestHistoryWidgetList.length > 1
                ?
                SmartRefresher(
                  onRefresh: _onHistoryRefresh,
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
                requestHistoryWidgetList.length == 1 ?
                SmartRefresher(
                  onRefresh: _onHistoryRefresh,
                  controller: _refreshRequestController,
                  physics: BouncingScrollPhysics(),
                  header: WaterDropMaterialHeader(),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ToggleButtons(  
                              fillColor: config.lightOpactityBlueColor,
                              borderColor: config.darkOpacityBlueColor,
                              borderWidth: 2,
                              selectedBorderColor: config.darkOpacityBlueColor,        
                              borderRadius: BorderRadius.circular(30),
                              focusNodes: focusToggle,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Container(
                                    child: TextView("Semua Data", 5, color: selectedLimitRequestHistoryData[0] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Container(
                                    child: TextView("Permintaan BM", 5, color: selectedLimitRequestHistoryData[1] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Container(
                                    child: TextView("Permintaan Saya", 5, color: selectedLimitRequestHistoryData[2] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                                  ),
                                ),
                                // Icon(Icons.format_italic),
                                // Icon(Icons.link),
                              ],
                              isSelected: selectedLimitRequestHistoryData,
                              onPressed: (int index) {
                                setState(() {
                                  for (int indexBtn = 0;indexBtn < selectedLimitRequestHistoryData.length;indexBtn++) {
                                    if (indexBtn == index) {
                                      selectedLimitRequestHistoryData[indexBtn] = true;
                                    } else {
                                      selectedLimitRequestHistoryData[indexBtn] = false;
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Image.asset("assets/illustration/request-history.png", alignment: Alignment.center, fit: BoxFit.fill, scale: 2.75)
                            ),
                            SizedBox(height: 30),
                            Container(
                              child: TextView("Tidak ada data permintaan limit\nyang diterima", 3, color: config.grayColor, align: TextAlign.center),
                            )
                          ],
                        ),
                        Container(),
                      ],
                    )
                  ),
                )
                :
                SmartRefresher(
                  onRefresh: _onHistoryRefresh,
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

                // requestHistoryWidgetList.length > 1
                // ?
                // SmartRefresher(
                //   onRefresh: _onHistoryRefresh,
                //   controller: _refreshRequestController,
                //   physics: BouncingScrollPhysics(),
                //   header: WaterDropMaterialHeader(),
                //   child: ListView(
                //     scrollDirection: Axis.vertical,
                //     padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                //     physics: ScrollPhysics(),
                //     shrinkWrap: true,
                //     children: requestHistoryWidgetList,
                //   ),
                // )
                // :
                // requestHistoryWidgetList.length == 1 ?
                // SmartRefresher(
                //   onRefresh: _onHistoryRefresh,
                //   controller: _refreshRequestController,
                //   physics: BouncingScrollPhysics(),
                //   header: WaterDropMaterialHeader(),
                //   child: Container(
                //     margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Center(
                //           child: SingleChildScrollView(
                //             scrollDirection: Axis.horizontal,
                //             child: ToggleButtons(  
                //               fillColor: config.lightOpactityBlueColor,
                //               borderColor: config.darkOpacityBlueColor,
                //               borderWidth: 2,
                //               selectedBorderColor: config.darkOpacityBlueColor,        
                //               borderRadius: BorderRadius.circular(30),
                //               focusNodes: focusToggle,
                //               children: <Widget>[
                //                 Padding(
                //                   padding: EdgeInsets.all(8),
                //                   child: Container(
                //                     child: TextView("Semua Data", 5, color: selectedLimitRequestHistoryData[0] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                //                   ),
                //                 ),
                //                 Padding(
                //                   padding: EdgeInsets.all(8),
                //                   child: Container(
                //                     child: TextView("Permintaan BM", 5, color: selectedLimitRequestHistoryData[1] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                //                   ),
                //                 ),
                //                 Padding(
                //                   padding: EdgeInsets.all(8),
                //                   child: Container(
                //                     child: TextView("Permintaan Saya", 5, color: selectedLimitRequestHistoryData[2] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                //                   ),
                //                 ),
                //                 // Icon(Icons.format_italic),
                //                 // Icon(Icons.link),
                //               ],
                //               isSelected: selectedLimitRequestHistoryData,
                //               onPressed: (int index) {
                //                 setState(() {
                //                   for (int indexBtn = 0;indexBtn < selectedLimitRequestHistoryData.length;indexBtn++) {
                //                     if (indexBtn == index) {
                //                       selectedLimitRequestHistoryData[indexBtn] = true;
                //                     } else {
                //                       selectedLimitRequestHistoryData[indexBtn] = false;
                //                     }
                //                   }
                //                 });
                //               },
                //             ),
                //           ),
                //         ),
                //         Column(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Container(
                //               child: Image.asset("assets/illustration/request-history.png", alignment: Alignment.center, fit: BoxFit.fill, scale: 2.75)
                //             ),
                //             SizedBox(height: 30),
                //             Container(
                //               child: TextView("Tidak ada data permintaan limit\nyang diterimahuhuh", 3, color: config.grayColor, align: TextAlign.center),
                //             )
                //           ],
                //         ),
                //         Container(),
                //       ],
                //     )
                //   ),
                // )
                // :
                // SmartRefresher(
                //   onRefresh: _onHistoryRefresh,
                //   controller: _refreshRequestController,
                //   physics: BouncingScrollPhysics(),
                //   header: WaterDropMaterialHeader(),
                //   child: Container(
                //     margin: EdgeInsets.symmetric(horizontal: 15),
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Container(
                //           child: Image.asset("assets/illustration/request-history.png", alignment: Alignment.center, fit: BoxFit.fill, scale: 2.75)
                //         ),
                //         SizedBox(height: 30),
                //         Container(
                //           child: TextView("Tidak ada data permintaan limit\nyang diminta", 3, color: config.grayColor, align: TextAlign.center),
                //         )
                //       ],
                //     )
                //   ),
                // ),
            
                approvedLimitHistoryListLoading
                ?
                loadingRequestHistory()
                :
                !user_login.toLowerCase().contains("dsd")
                ?
                approvedHistoryWidgetList.length != 0
                ?
                SmartRefresher(
                  onRefresh: _onHistoryRefresh,
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
                  onRefresh: _onHistoryRefresh,
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
                )
                :
                approvedHistoryWidgetList.length > 1
                ?
                SmartRefresher(
                  onRefresh: _onHistoryRefresh,
                  controller: _refreshApprovedController,
                  physics: BouncingScrollPhysics(),
                  header: WaterDropMaterialHeader(),
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    physics: ScrollPhysics(),
                    // shrinkWrap: true,
                    children: approvedHistoryWidgetList,
                  ),
                )
                :
                approvedHistoryWidgetList.length == 1 ?
                SmartRefresher(
                  onRefresh: _onHistoryRefresh,
                  controller: _refreshApprovedController,
                  physics: BouncingScrollPhysics(),
                  header: WaterDropMaterialHeader(),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ToggleButtons(  
                              fillColor: config.lightOpactityBlueColor,
                              borderColor: config.darkOpacityBlueColor,
                              borderWidth: 2,
                              selectedBorderColor: config.darkOpacityBlueColor,        
                              borderRadius: BorderRadius.circular(30),
                              focusNodes: focusToggle,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Container(
                                    child: TextView("Semua Data", 5, color: selectedLimitApprovedHistoryData[0] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Container(
                                    child: TextView("Permintaan BM", 5, color: selectedLimitApprovedHistoryData[1] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Container(
                                    child: TextView("Permintaan Saya", 5, color: selectedLimitApprovedHistoryData[2] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                                  ),
                                ),
                                // Icon(Icons.format_italic),
                                // Icon(Icons.link),
                              ],
                              isSelected: selectedLimitApprovedHistoryData,
                              onPressed: (int index) {
                                setState(() {
                                  for (int indexBtn = 0;indexBtn < selectedLimitApprovedHistoryData.length;indexBtn++) {
                                    if (indexBtn == index) {
                                      selectedLimitApprovedHistoryData[indexBtn] = true;
                                    } else {
                                      selectedLimitApprovedHistoryData[indexBtn] = false;
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        Column(
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
                        ),
                        Container(),
                      ],
                    )
                  ),
                )
                :
                SmartRefresher(
                  onRefresh: _onHistoryRefresh,
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
                !user_login.toLowerCase().contains("dsd")
                ?
                rejectedHistoryWidgetList.length != 0
                ?
                SmartRefresher(
                  onRefresh: _onHistoryRefresh,
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
                  onRefresh: _onHistoryRefresh,
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
                )
                :
                rejectedHistoryWidgetList.length > 1
                ?
                SmartRefresher(
                  onRefresh: _onHistoryRefresh,
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
                rejectedHistoryWidgetList.length == 1 ?
                SmartRefresher(
                  onRefresh: _onHistoryRefresh,
                  controller: _refreshRejectedController,
                  physics: BouncingScrollPhysics(),
                  header: WaterDropMaterialHeader(),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ToggleButtons(  
                              fillColor: config.lightOpactityBlueColor,
                              borderColor: config.darkOpacityBlueColor,
                              borderWidth: 2,
                              selectedBorderColor: config.darkOpacityBlueColor,        
                              borderRadius: BorderRadius.circular(30),
                              focusNodes: focusToggle,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Container(
                                    child: TextView("Semua Data", 5, color: selectedLimitRejectedHistoryData[0] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Container(
                                    child: TextView("Permintaan BM", 5, color: selectedLimitRejectedHistoryData[1] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Container(
                                    child: TextView("Permintaan Saya", 5, color: selectedLimitRejectedHistoryData[2] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                                  ),
                                ),
                                // Icon(Icons.format_italic),
                                // Icon(Icons.link),
                              ],
                              isSelected: selectedLimitRejectedHistoryData,
                              onPressed: (int index) {
                                setState(() {
                                  for (int indexBtn = 0;indexBtn < selectedLimitRejectedHistoryData.length;indexBtn++) {
                                    if (indexBtn == index) {
                                      selectedLimitRejectedHistoryData[indexBtn] = true;
                                    } else {
                                      selectedLimitRejectedHistoryData[indexBtn] = false;
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        Column(
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
                        ),
                        Container(),
                      ],
                    )
                  ),
                )
                :
                SmartRefresher(
                  onRefresh: _onHistoryRefresh,
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

    if(user_login.toLowerCase().contains("dsd")) {
      tempWidgetList.add(
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ToggleButtons(  
              fillColor: config.lightOpactityBlueColor,
              borderColor: config.darkOpacityBlueColor,
              borderWidth: 2,
              selectedBorderColor: config.darkOpacityBlueColor,        
              borderRadius: BorderRadius.circular(30),
              focusNodes: focusToggle,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    child: TextView("Semua Data", 5, color: selectedLimitRequestHistoryData[0] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    child: TextView("Permintaan BM", 5, color: selectedLimitRequestHistoryData[1] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    child: TextView("Permintaan Saya", 5, color: selectedLimitRequestHistoryData[2] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                  ),
                ),
                // Icon(Icons.format_italic),
                // Icon(Icons.link),
              ],
              isSelected: selectedLimitRequestHistoryData,
              onPressed: (int index) {
                setState(() {
                  for (int indexBtn = 0;indexBtn < selectedLimitRequestHistoryData.length;indexBtn++) {
                    if (indexBtn == index) {
                      selectedLimitRequestHistoryData[indexBtn] = true;
                    } else {
                      selectedLimitRequestHistoryData[indexBtn] = false;
                    }
                  }
                });
              },
            ),
          ),
        )
      );

      if(selectedLimitRequestHistoryData[0]) {
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextView(requestLimitHistoryList[i].customer_name, 4, align: TextAlign.center),
                      SizedBox(height: 5),
                      TextView("("+requestLimitHistoryList[i].customer_code+")", 4, align: TextAlign.center),
                      SizedBox(height: 10),
                      TextView("Rp " + currencyFormatter.format(int.parse(requestLimitHistoryList[i].limit)), 4, align: TextAlign.center),
                    ]
                  ),
                ),
              ),
            ),
          );
        }

      } else if(selectedLimitRequestHistoryData[1]) {
        printHelp("YOI");
        for(int i = 0; i < requestLimitHistoryList.length; i++){
          if(requestLimitHistoryList[i].user_code.toLowerCase().contains("kc")){
            tempWidgetList.add(
              Card(
                margin: EdgeInsets.only(top: 20),
                elevation: 3,
                child: InkWell(
                  onTap: () {
                    goToHistoryLimitDetail(requestLimitHistoryList[i], 1);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextView(requestLimitHistoryList[i].customer_name, 4, align: TextAlign.center),
                        SizedBox(height: 5),
                        TextView("("+requestLimitHistoryList[i].customer_code+")", 4, align: TextAlign.center),
                        SizedBox(height: 10),
                        TextView("Rp " + currencyFormatter.format(int.parse(requestLimitHistoryList[i].limit)), 4, align: TextAlign.center),
                      ]
                    ),
                  ),
                ),
              ),
            );
          }
        }

      } else {
        for(int i = 0; i < requestLimitHistoryList.length; i++){
          if(requestLimitHistoryList[i].user_code.contains(user_login)){
            tempWidgetList.add(
              Card(
                margin: EdgeInsets.only(top: 20),
                elevation: 3,
                child: InkWell(
                  onTap: () {
                    goToHistoryLimitDetail(requestLimitHistoryList[i], 1);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextView(requestLimitHistoryList[i].customer_name, 4, align: TextAlign.center),
                        SizedBox(height: 5),
                        TextView("("+requestLimitHistoryList[i].customer_code+")", 4, align: TextAlign.center),
                        SizedBox(height: 10),
                        TextView("Rp " + currencyFormatter.format(int.parse(requestLimitHistoryList[i].limit)), 4, align: TextAlign.center),
                      ]
                    ),
                  ),
                ),
              ),
            );
          }
        }
      }

    } else {
      for(int i=0; i<requestLimitHistoryList.length; i++) {
        tempWidgetList.add(
          Card(
            margin: EdgeInsets.only(top: 20),
            elevation: 3,
            child: InkWell(
              onTap: () {
                goToHistoryLimitDetail(requestLimitHistoryList[i], 1);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextView(requestLimitHistoryList[i].customer_name, 4, align: TextAlign.center),
                    SizedBox(height: 5),
                    TextView("("+requestLimitHistoryList[i].customer_code+")", 4, align: TextAlign.center),
                    SizedBox(height: 10),
                    TextView("Rp " + currencyFormatter.format(int.parse(requestLimitHistoryList[i].limit)), 4, align: TextAlign.center),
                  ]
                ),
              ),
            ),
          ),
        );
      }
    }

    return tempWidgetList;

  }

  void goToHistoryLimitDetail(LimitHistory tempLimitHistory, int type) async {
    Result result_;

    if(tempLimitHistory.customer_code.length > 11) {
      Alert(context: context, loading: true, disableBackButton: true);

      result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"${tempLimitHistory.customer_code}","user_code":"$user_login"}');

      final SharedPreferences sharedPreferences = await _sharedPreferences;
      await sharedPreferences.setInt("request_limit", int.parse(tempLimitHistory.limit));
      await sharedPreferences.setString("user_code_request", tempLimitHistory.user_code);

      Navigator.of(context).pop();

      if(result_.success == 1) {
        if(type == 1) {
          Navigator.pushNamed(
            context,
            "historyLimitRequestDetail/${tempLimitHistory.id}/4",
            arguments: result_,
          );
        } else if(type == 2) {
          Navigator.pushNamed(
            context,
            "historyLimitRequestDetail/${tempLimitHistory.id}/5",
            arguments: result_,
          );
        } else {
          Navigator.pushNamed(
            context,
            "historyLimitRequestDetail/${tempLimitHistory.id}/6",
            arguments: result_,
          );
        }
      } else {
        Alert(
          context: context,
          title: "Maaf,",
          content: Text(result_.message),
          cancel: false,
          type: "error",
          defaultAction: () {}
        );
      }

    } else {
      Alert(context: context, loading: true, disableBackButton: true);

      result_ = await customerAPI.getLimit(context, parameter: 'json={"guest_mode":"true","kode_customer":"${tempLimitHistory.customer_code}","user_code":"$user_login"}');

      final SharedPreferences sharedPreferences = await _sharedPreferences;
      await sharedPreferences.setInt("request_limit", int.parse(tempLimitHistory.limit));
      try {
        await sharedPreferences.setInt("request_limit_dmd", int.parse(tempLimitHistory.limit_dmd));
      } catch(e) {

      }
      await sharedPreferences.setString("user_code_request", tempLimitHistory.user_code);

      Navigator.of(context).pop();

      if(result_.success == 1) {
        Navigator.pushNamed(
          context,
          "historyLimitRequestDetail/${tempLimitHistory.id}/$type",
          arguments: result_,
        );
      } else {
        Alert(
          context: context,
          title: "Maaf,",
          content: Text(result_.message),
          cancel: false,
          type: "error",
          defaultAction: () {}
        );
      }
    }
  }

  showApprovedHistory(Configuration config) {
    List<Widget> tempWidgetList = [];

    final currencyFormatter = NumberFormat('#,##0', 'ID');

    if(user_login.toLowerCase().contains("dsd")) {
      tempWidgetList.add(
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ToggleButtons(  
              fillColor: config.lightOpactityBlueColor,
              borderColor: config.darkOpacityBlueColor,
              borderWidth: 2,
              selectedBorderColor: config.darkOpacityBlueColor,        
              borderRadius: BorderRadius.circular(30),
              focusNodes: focusToggle,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    child: TextView("Semua Data", 5, color: selectedLimitApprovedHistoryData[0] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    child: TextView("Permintaan BM", 5, color: selectedLimitApprovedHistoryData[1] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    child: TextView("Permintaan Saya", 5, color: selectedLimitApprovedHistoryData[2] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                  ),
                ),
                // Icon(Icons.format_italic),
                // Icon(Icons.link),
              ],
              isSelected: selectedLimitApprovedHistoryData,
              onPressed: (int index) {
                setState(() {
                  for (int indexBtn = 0;indexBtn < selectedLimitApprovedHistoryData.length;indexBtn++) {
                    if (indexBtn == index) {
                      selectedLimitApprovedHistoryData[indexBtn] = true;
                    } else {
                      selectedLimitApprovedHistoryData[indexBtn] = false;
                    }
                  }
                });
              },
            ),
          ),
        )
      );


      if(selectedLimitApprovedHistoryData[0]) {
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextView(approvedLimitHistoryList[i].customer_name, 4, align: TextAlign.center),
                      SizedBox(height: 5),
                      TextView("("+approvedLimitHistoryList[i].customer_code+")", 4, align: TextAlign.center),
                      SizedBox(height: 10),
                      TextView("Rp " + currencyFormatter.format(int.parse(approvedLimitHistoryList[i].limit)), 4, align: TextAlign.center),
                    ]
                  ),
                ),
              ),
            ),
          );
        }

      } else if(selectedLimitApprovedHistoryData[1]) {
        for(int i = 0; i < approvedLimitHistoryList.length; i++){
          if(approvedLimitHistoryList[i].user_code.toLowerCase().contains("kc")){
            tempWidgetList.add(
              Card(
                margin: EdgeInsets.only(top: 20),
                elevation: 3,
                child: InkWell(
                  onTap: (){
                    goToHistoryLimitDetail(approvedLimitHistoryList[i], 2);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextView(approvedLimitHistoryList[i].customer_name, 4, align: TextAlign.center),
                        SizedBox(height: 5),
                        TextView("("+approvedLimitHistoryList[i].customer_code+")", 4, align: TextAlign.center),
                        SizedBox(height: 10),
                        TextView("Rp " + currencyFormatter.format(int.parse(approvedLimitHistoryList[i].limit)), 4, align: TextAlign.center),
                      ]
                    ),
                  ),
                ),
              ),
            );
          }
        }

      } else {
        for(int i = 0; i < approvedLimitHistoryList.length; i++){
          if(approvedLimitHistoryList[i].user_code.contains(user_login)){
            tempWidgetList.add(
              Card(
                margin: EdgeInsets.only(top: 20),
                elevation: 3,
                child: InkWell(
                  onTap: (){
                    goToHistoryLimitDetail(approvedLimitHistoryList[i], 2);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextView(approvedLimitHistoryList[i].customer_name, 4, align: TextAlign.center),
                        SizedBox(height: 5),
                        TextView("("+approvedLimitHistoryList[i].customer_code+")", 4, align: TextAlign.center),
                        SizedBox(height: 10),
                        TextView("Rp " + currencyFormatter.format(int.parse(approvedLimitHistoryList[i].limit)), 4, align: TextAlign.center),
                      ]
                    ),
                  ),
                ),
              ),
            );
          }
        }
      }

    } else {
      for(int i=0; i<approvedLimitHistoryList.length; i++) {
        tempWidgetList.add(
          Card(
            margin: EdgeInsets.only(top: 20),
            elevation: 3,
            child: InkWell(
              onTap: (){
                goToHistoryLimitDetail(approvedLimitHistoryList[i], 2);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextView(approvedLimitHistoryList[i].customer_name, 4, align: TextAlign.center),
                    SizedBox(height: 5),
                    TextView("("+approvedLimitHistoryList[i].customer_code+")", 4, align: TextAlign.center),
                    SizedBox(height: 10),
                    TextView("Rp " + currencyFormatter.format(int.parse(approvedLimitHistoryList[i].limit)), 4, align: TextAlign.center),
                  ]
                ),
              ),
            ),
          ),
        );
      }
    }

    return tempWidgetList;

  }

  showRejectedHistory(Configuration config) {
    List<Widget> tempWidgetList = [];

    final currencyFormatter = NumberFormat('#,##0', 'ID');

    if(user_login.toLowerCase().contains("dsd")) {
      tempWidgetList.add(
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ToggleButtons(  
              fillColor: config.lightOpactityBlueColor,
              borderColor: config.darkOpacityBlueColor,
              borderWidth: 2,
              selectedBorderColor: config.darkOpacityBlueColor,        
              borderRadius: BorderRadius.circular(30),
              focusNodes: focusToggle,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    child: TextView("Semua Data", 5, color: selectedLimitRejectedHistoryData[0] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    child: TextView("Permintaan BM", 5, color: selectedLimitRejectedHistoryData[1] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    child: TextView("Permintaan Saya", 5, color: selectedLimitRejectedHistoryData[2] ? config.darkOpacityBlueColor : config.grayNonActiveColor),
                  ),
                ),
                // Icon(Icons.format_italic),
                // Icon(Icons.link),
              ],
              isSelected: selectedLimitRejectedHistoryData,
              onPressed: (int index) {
                setState(() {
                  for (int indexBtn = 0;indexBtn < selectedLimitRejectedHistoryData.length;indexBtn++) {
                    if (indexBtn == index) {
                      selectedLimitRejectedHistoryData[indexBtn] = true;
                    } else {
                      selectedLimitRejectedHistoryData[indexBtn] = false;
                    }
                  }
                });
              },
            ),
          ),
        )
      );

      if(selectedLimitRejectedHistoryData[0]) {
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextView(rejectedLimitHistoryList[i].customer_name, 4, align: TextAlign.center),
                      SizedBox(height: 5),
                      TextView("("+rejectedLimitHistoryList[i].customer_code+")", 4, align: TextAlign.center),
                      SizedBox(height: 10),
                      TextView("Rp " + currencyFormatter.format(int.parse(rejectedLimitHistoryList[i].limit)), 4, align: TextAlign.center),
                    ]
                  ),
                ),
              ),
            ),
          );
        }

      } else if(selectedLimitRejectedHistoryData[1]) {
        for(int i = 0; i < rejectedLimitHistoryList.length; i++){
          if(rejectedLimitHistoryList[i].user_code.toLowerCase().contains("kc")){
            tempWidgetList.add(
              Card(
                margin: EdgeInsets.only(top: 20),
                elevation: 3,
                child: InkWell(
                  onTap: (){
                    goToHistoryLimitDetail(rejectedLimitHistoryList[i], 3);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextView(rejectedLimitHistoryList[i].customer_name, 4, align: TextAlign.center),
                        SizedBox(height: 5),
                        TextView("("+rejectedLimitHistoryList[i].customer_code+")", 4, align: TextAlign.center),
                        SizedBox(height: 10),
                        TextView("Rp " + currencyFormatter.format(int.parse(rejectedLimitHistoryList[i].limit)), 4, align: TextAlign.center),
                      ]
                    ),
                  ),
                ),
              ),
            );
          }
        }

      } else {
        for(int i = 0; i < rejectedLimitHistoryList.length; i++){
          if(rejectedLimitHistoryList[i].user_code.contains(user_login)){
            tempWidgetList.add(
              Card(
                margin: EdgeInsets.only(top: 20),
                elevation: 3,
                child: InkWell(
                  onTap: (){
                    goToHistoryLimitDetail(rejectedLimitHistoryList[i], 3);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextView(rejectedLimitHistoryList[i].customer_name, 4, align: TextAlign.center),
                        SizedBox(height: 5),
                        TextView("("+rejectedLimitHistoryList[i].customer_code+")", 4, align: TextAlign.center),
                        SizedBox(height: 10),
                        TextView("Rp " + currencyFormatter.format(int.parse(rejectedLimitHistoryList[i].limit)), 4, align: TextAlign.center),
                      ]
                    ),
                  ),
                ),
              ),
            );
          }
        }
      }

    } else {
      for(int i=0; i<rejectedLimitHistoryList.length; i++) {
        tempWidgetList.add(
          Card(
            margin: EdgeInsets.only(top: 20),
            elevation: 3,
            child: InkWell(
              onTap: (){
                goToHistoryLimitDetail(rejectedLimitHistoryList[i], 3);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextView(rejectedLimitHistoryList[i].customer_name, 4, align: TextAlign.center),
                    SizedBox(height: 5),
                    TextView("("+rejectedLimitHistoryList[i].customer_code+")", 4, align: TextAlign.center),
                    SizedBox(height: 10),
                    TextView("Rp " + currencyFormatter.format(int.parse(rejectedLimitHistoryList[i].limit)), 4, align: TextAlign.center),
                  ]
                ),
              ),
            ),
          ),
        );
      }
    }

    return tempWidgetList;

  }

  RefreshController _refreshRequestController =
      RefreshController(initialRefresh: false);

  void _onHistoryRefresh() async{
    setState(() {
      requestLimitHistoryListLoading = true;
      approvedLimitHistoryListLoading = true;
      rejectedLimitHistoryListLoading = true;
    });

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

  RefreshController _refreshApprovedController =
      RefreshController(initialRefresh: false);

  RefreshController _refreshRejectedController =
      RefreshController(initialRefresh: false);

}