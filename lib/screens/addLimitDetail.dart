import 'dart:async';
import 'dart:convert';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/resources/customerAPI.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';
import 'package:tambah_limit/widgets/TextView.dart';
import 'package:tambah_limit/widgets/button.dart';
import 'package:tambah_limit/widgets/circularModal.dart';
import 'package:tambah_limit/widgets/modalPageView.dart';

Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();

class AddLimitDetail extends StatefulWidget {
  final Result model;
  final String callMode;

  AddLimitDetail({Key key, this.model, this.callMode}) : super(key: key);

  @override
  AddLimitDetailState createState() => AddLimitDetailState();
}

class AddLimitDetailState extends State<AddLimitDetail> {
  Result result;
  String callMode;

  final _AddLimitFormKey = GlobalKey<FormState>();
  final limitDMDController = TextEditingController();
  final limitRequestController = TextEditingController();
  var resultObject;

  String currentLimitDMD = "";

  final _HistoryLimitFormKey = GlobalKey<FormState>();

  bool limitDMDValid = false;
  bool limitRequestValid = false;
  bool changeLimitLoading = false;

  String user_login = "";

  final currencyFormatter = NumberFormat('#,##0', 'ID');

  final ScrollController _scrollController = ScrollController();

  Future<Null> setSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    resultObject = jsonDecode(result.data.toString());
    prefs.setInt("limit_dmd", resultObject[0]["limit_dmd"]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    limitRequestController.text = "0";

    result = widget.model;
    callMode = widget.callMode;

    final _resultObject = jsonDecode(result.data.toString());

    if (widget.callMode == "historyLimitGabunganDetail") {
      final _newValue = _resultObject[0]["old_limit"].toString();
      limitDMDController.value = TextEditingValue(
        text: _newValue,
        selection: TextSelection.fromPosition(
          TextPosition(offset: _newValue.length),
        ),
      );
    } else {
      final _newValue = _resultObject[0]["limit_dmd"].toString();
      limitDMDController.value = TextEditingValue(
        text: _newValue,
        selection: TextSelection.fromPosition(
          TextPosition(offset: _newValue.length),
        ),
      );
    }

    setState(() {
      resultObject = _resultObject;
    });
    setSharedPrefs();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_login = prefs.getString("get_user_login");
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> changeLimitWidgetList = showChangeLimit(config);
    List<Widget> informationDetailWidgetList = showInformationDetail(config);

    final currencyFormatter = NumberFormat('#,##0', 'ID');
    final resultObject = jsonDecode(result.data.toString());

    return Container(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  new SliverAppBar(
                    title: TextView('Tambah Limit Detail', 1),
                    pinned: true,
                    floating: true,
                    bottom: TabBar(
                      isScrollable: true,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: [
                        Tab(
                          icon: Icon(Icons.book_rounded),
                          child: TextView("Ubah Limit", 3)
                        ),
                        Tab(
                          icon: Icon(Icons.info_rounded),
                          child: TextView("Detail Informasi", 3)
                        ),
                      ],
                    ),
                  )
                ];
              },
              body: TabBarView(
                children: [
                  changeLimitWidgetList.length == 0 ?
                  Container()
                  :
                  ListView(
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.all(8),
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    children: changeLimitWidgetList,
                  ),
                  //Detail Informasi section
                  SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: TextView("Ketepatan Waktu Pembayaran", 1, color: config.blueColor)
                          ),
                          Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    child: Column(
                                      children: [
                                        Card(
                                          child: InkWell(
                                            onTap: () {
                                              //bottom sheet
                                              resultObject[1]["pembayaranc1"] != 0 || resultObject[1]["pembayaranc2"] != 0 || resultObject[1]["pembayaranc3"] != 0 || resultObject[1]["pembayaranc4"] != 0 ?
                                              showAvatarModalBottomSheet(
                                                expand: true,
                                                context: context,
                                                backgroundColor: Colors.transparent,
                                                builder: (context) => ModalWithPageView(
                                                  modalTitle: "Rentang Pembayaran",
                                                  modalContent: [
                                                    Padding(
                                                      padding:const EdgeInsets.symmetric(horizontal: 20, vertical:15),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment .start,
                                                        children: [
                                                          Container(
                                                            child: TextView("Rentang Cat 1 (0 - ${resultObject[3]["top_cat"].toString()})", 3, color: Colors .black),
                                                          ),
                                                          SizedBox(height: 30),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              TextView("Rp " + currencyFormatter.format(resultObject[1]["pembayaranc1"]), 4),
                                                              TextView(resultObject[1]["pembayaranc1"] != 0 ? "100%" : "0%", 4),
                                                            ],
                                                          ),
                                                          Divider(
                                                            height: 60,
                                                            thickness: 4,
                                                            color: config.lighterGrayColor,
                                                          ),
                                                          Container(
                                                            child: TextView("Rentang Cat 2 (${resultObject[3]["top_cat"] + 1} - 70)", 3, color: Colors.black),
                                                          ),
                                                          SizedBox(height: 30),
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              TextView("Rp " + currencyFormatter.format(resultObject[1]["pembayaranc2"]), 4),
                                                              TextView(resultObject[1]["pembayaranc2"] != 0 ? "100%" : "0%", 4),
                                                            ],
                                                          ),
                                                          Divider(
                                                            height: 60,
                                                            thickness: 4,
                                                            color: config.lighterGrayColor,
                                                          ),
                                                          Container(
                                                            child: TextView("Rentang Cat 3 (71 - 90)", 3, color: Colors.black),
                                                          ),
                                                          SizedBox(height: 30),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              TextView("Rp " + currencyFormatter.format(resultObject[1]["pembayaranc3"]), 4),
                                                              TextView(resultObject[1]["pembayaranc3"] != 0 ? "100%" : "0%", 4),
                                                            ],
                                                          ),
                                                          Divider(
                                                            height: 60,
                                                            thickness: 4,
                                                            color: config.lighterGrayColor),
                                                            Container(
                                                              child: TextView("Rentang Cat 4 (> 90)", 3, color: Colors.black),
                                                            ),
                                                            SizedBox(height: 30),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                TextView("Rp " + currencyFormatter.format(resultObject[1]["pembayaranc4"]), 4),
                                                                TextView(resultObject[1]["pembayaranc4"] != 0 ? "100%" : "0%", 4),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                                : Alert(
                                                  context: context,
                                                  title: "Info,",
                                                  content: Text("Tidak ada data"),
                                                  cancel: false, type: "warning"
                                                );
                                            },
                                            child: Container(
                                              height: 75,
                                              width: 75,
                                              child: Center(
                                                child: Image.asset("assets/illustration/varnish.png", alignment: Alignment.center, fit: BoxFit.contain, height: 50),
                                              ),
                                            ),
                                          ),
                                          elevation: 3,
                                          shadowColor: config.grayNonActiveColor,
                                          margin: EdgeInsets.all(20),
                                          shape: CircleBorder(
                                            side: BorderSide(width: 1, color: Colors.white),
                                            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        ),
                                        Text("Cat"),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Card(
                                            child: InkWell(
                                              onTap: () {
                                                resultObject[7]["pembayaranb1"] != 0 || resultObject[7]["pembayaranb2"] != 0 || resultObject[7]["pembayaranb3"] != 0 || resultObject[7]["pembayaranb4"] != 0 ?
                                                showAvatarModalBottomSheet(
                                                  expand: true,
                                                  context: context,
                                                  backgroundColor: Colors.transparent,
                                                  builder: (context) => ModalWithPageView(
                                                    modalTitle: "Rentang Pembayaran",
                                                    modalContent: [
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              child: TextView("Rentang BB 1 (0 - ${resultObject[3]["top_cat"].toString()})", 3, color: Colors.black),
                                                            ),
                                                            SizedBox(height: 30),
                                                            Row(
                                                              mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                TextView("Rp " + currencyFormatter.format(resultObject[7]["pembayaranb1"]), 4),
                                                                TextView(resultObject[7]["pembayaranb1"] != 0 ? "100%" : "0%", 4),
                                                              ],
                                                            ),
                                                            Divider(
                                                              height: 60,
                                                              thickness: 4,
                                                              color: config.lighterGrayColor,
                                                            ),
                                                            Container(
                                                              child: TextView("Rentang BB 2 (${resultObject[3]["top_cat"] + 1} - 70)", 3, color: Colors.black),
                                                            ),
                                                            SizedBox(height: 30),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                TextView("Rp " + currencyFormatter.format(resultObject[7]["pembayaranb2"]), 4),
                                                                TextView(resultObject[7]["pembayaranb2"] != 0 ? "100%" : "0%", 4),
                                                              ],
                                                            ),
                                                            Divider(
                                                              height: 60,
                                                              thickness: 4,
                                                              color: config.lighterGrayColor,
                                                            ),
                                                            Container(
                                                              child: TextView("Rentang BB 3 (71 - 90)", 3, color: Colors.black),
                                                            ),
                                                            SizedBox(height: 30),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                TextView("Rp " + currencyFormatter.format(resultObject[7]["pembayaranb3"]), 4),
                                                                TextView(resultObject[7]["pembayaranb3"] != 0 ? "100%" : "0%", 4),
                                                              ],
                                                            ),
                                                            Divider(
                                                              height: 60,
                                                              thickness: 4,
                                                              color: config.lighterGrayColor,
                                                            ),
                                                            Container(
                                                              child: TextView("Rentang BB 4 (> 90)", 3,
                                                              color: Colors.black),
                                                            ),
                                                            SizedBox(height: 30),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                TextView("Rp " + currencyFormatter.format(resultObject[7]["pembayaranb4"]), 4),
                                                                TextView(resultObject[7]["pembayaranb4"] != 0 ? "100%" : "0%", 4),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                                : Alert(
                                                    context: context,
                                                    title: "Info,",
                                                    content: Text("Tidak ada data"),
                                                    cancel: false,
                                                    type: "warning"
                                                  );
                                                },
                                                child: Container(
                                                  height: 75,
                                                  width: 75,
                                                  child: Center(
                                                    child: Image.asset("assets/illustration/pipe.png", alignment: Alignment.center, fit: BoxFit.contain, height: 50),
                                                ),
                                              ),
                                            ),
                                            elevation: 3,
                                            shadowColor: config.grayNonActiveColor,
                                            margin: EdgeInsets.all(20),
                                            shape: CircleBorder(
                                              side: BorderSide(width: 1, color: Colors.white),
                                            ),
                                          ),
                                          Text("Bahan Bangunan"),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Card(
                                            child: InkWell(
                                              onTap: () {
                                                resultObject[6]["pembayaranm1"] != 0 || resultObject[6]["pembayaranm2"] != 0 || resultObject[6]["pembayaranm3"] != 0 || resultObject[6]["pembayaranm4"] != 0
                                                ? 
                                                showAvatarModalBottomSheet(
                                                  expand: true,
                                                  context: context,
                                                  backgroundColor: Colors.transparent,
                                                  builder: (context) => ModalWithPageView(
                                                    modalTitle: "Rentang Pembayaran",
                                                    modalContent: [
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              child: TextView("Rentang Mebel 1 (0 - ${resultObject[5]["top_mebel"]})", 3, color: Colors.black),
                                                            ),
                                                            SizedBox(height: 30),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                TextView("Rp " + currencyFormatter.format(resultObject[6]["pembayaranm1"]), 4),
                                                                TextView(resultObject[6]["pembayaranm1"] != 0 ? "100%" : "0%", 4),
                                                              ],
                                                            ),
                                                            Divider(
                                                              height: 60,
                                                              thickness: 4,
                                                              color: config.lighterGrayColor,
                                                            ),
                                                            Container(
                                                              child: TextView("Rentang Mebel 2 (${resultObject[5]["top_mebel"] + 1} - 70)", 3, color: Colors.black),
                                                            ),
                                                            SizedBox(height: 30),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                TextView("Rp " + currencyFormatter.format(resultObject[6]["pembayaranm2"]), 4),
                                                                TextView(resultObject[6]["pembayaranm2"] != 0 ? "100%" : "0%", 4),
                                                              ],
                                                            ),
                                                            Divider(
                                                              height: 60,
                                                              thickness: 4,
                                                              color: config.lighterGrayColor,
                                                            ),
                                                            Container(
                                                              child: TextView("Rentang Mebel 3 (71 - 90)", 3, color: Colors.black),
                                                            ),
                                                            SizedBox(height: 30),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                TextView("Rp " + currencyFormatter.format(resultObject[6]["pembayaranm3"]), 4),
                                                                TextView(resultObject[6]["pembayaranm3"] != 0 ? "100%" : "0%", 4),
                                                              ],
                                                            ),
                                                            Divider(
                                                              height: 60,
                                                              thickness: 4,
                                                              color: config.lighterGrayColor,
                                                            ),
                                                            Container(
                                                              child: TextView("Rentang Mebel 4 (> 90)", 3, color: Colors.black),
                                                            ),
                                                            SizedBox(height: 30),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                TextView("Rp " + currencyFormatter.format(resultObject[6]["pembayaranm4"]), 4),
                                                                TextView(resultObject[6]["pembayaranm4"] != 0 ? "100%" : "0%", 4),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                                :
                                                Alert(
                                                  context: context,
                                                  title: "Info,",
                                                  content: Text("Tidak ada data"),
                                                  cancel: false,
                                                  type: "warning"
                                                );
                                              },
                                              child: Container(
                                                height: 75,
                                                width: 75,
                                                child: Center(
                                                  child: Image.asset("assets/illustration/furniture.png", alignment: Alignment.center, fit: BoxFit.contain, height: 50),
                                                ),
                                              ),
                                            ),
                                            elevation: 3,
                                            shadowColor: config.grayNonActiveColor,
                                            margin: EdgeInsets.all(20),
                                            shape: CircleBorder(
                                              side: BorderSide(
                                                width: 1,
                                                color: Colors.white
                                              ),
                                            ),
                                          ),
                                          Text("Mebel"),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 60,
                              thickness: 4,
                              color: config.lighterGrayColor,
                            ),
                            Container(
                              child: TextView("Faktur Terdekat Jatuh Tempo", 1, color: config.blueColor),
                            ),
                            Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Container(
                                      child: Column(
                                        children: [
                                          Card(
                                            child: InkWell(
                                              onTap: () {
                                                resultObject[12].length != 0 ?
                                                showAvatarModalBottomSheet(
                                                  expand: true,
                                                  context: context,
                                                  backgroundColor: Colors.transparent,
                                                  builder: (context) => ModalWithPageView(
                                                    modalTitle: "Faktur Terdekat Jatuh Tempo",
                                                    modalContent: [
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              child: TextView("Cat (${resultObject[12][0]["due_date"]})", 3, color: Colors.black),
                                                            ),
                                                            SizedBox(height: 30),
                                                            Container(
                                                              child: TextView("Document No", 3, color: Colors.black),
                                                            ),
                                                            SizedBox(height: 15),
                                                            Container(
                                                              child: Column(
                                                                children: List.generate(resultObject[12].length,(index){
                                                                  return Container(
                                                                    margin: EdgeInsets.only(top: 10),
                                                                    child: TextView(resultObject[12][index]["document_no"], 4)
                                                                  );
                                                                }),
                                                              ),
                                                            ),
                                                            Divider(
                                                              height: 40,
                                                              thickness: 4,
                                                              color: config.lighterGrayColor,
                                                            ),
                                                            Container(
                                                              child: TextView("Sisa", 3, color: Colors.black),
                                                            ),
                                                            SizedBox(height: 15),
                                                            Container(
                                                              child: Column(
                                                                children:
                                                                List.generate(resultObject[12].length,(index){
                                                                  return Container(
                                                                    margin: EdgeInsets.only(top: 10),
                                                                    child: TextView("Rp "+ currencyFormatter.format(double.parse(resultObject[12][index]["sisa"])), 4)
                                                                  );
                                                                }),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                          ],
                                                        ),
                                                      )
                                                    : Alert(
                                                        context: context,
                                                        title: "Info,",
                                                        content: Text(
                                                            "Tidak ada data"),
                                                        cancel: false,
                                                        type: "warning");
                                              },
                                              child: Container(
                                                height: 75,
                                                width: 75,
                                                child: Center(
                                                  child: Image.asset(
                                                      "assets/illustration/varnish.png",
                                                      alignment: Alignment.center,
                                                      fit: BoxFit.contain,
                                                      height: 50),
                                                ),
                                              ),
                                            ),
                                            elevation: 3,
                                            shadowColor:
                                                config.grayNonActiveColor,
                                            margin: EdgeInsets.all(20),
                                            shape: CircleBorder(
                                              side: BorderSide(
                                                  width: 1, color: Colors.white),
                                            ),
                                          ),
                                          Text("Cat"),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Card(
                                                child: InkWell(
                                                  onTap: () {
                                                    resultObject[13].length != 0
                                                        ? showAvatarModalBottomSheet(
                                                            expand: true,
                                                            context: context,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            builder: (context) =>
                                                                ModalWithPageView(
                                                              modalTitle:
                                                                  "Faktur Terdekat Jatuh Tempo",
                                                              modalContent: [
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Container(
                                                                        child: TextView("BB (${resultObject[13][0]["due_date"]})", 3, color: Colors.black),
                                                                      ),
                                                                      SizedBox(height: 30),
                                                                      Container(
                                                                        child: TextView("Document No", 3, color: Colors.black),
                                                                      ),
                                                                      SizedBox(height: 15),
                                                                      Container(
                                                                        child: Column(
                                                                          children: List.generate(resultObject[13].length,(index){
                                                                            return Container(
                                                                              margin: EdgeInsets.only(top: 10),
                                                                              child: TextView(resultObject[13][index]["document_no"], 4)
                                                                            );
                                                                          }),
                                                                        ),
                                                                      ),
                                                                      Divider(
                                                                        height: 40,
                                                                        thickness: 4,
                                                                        color: config.lighterGrayColor,
                                                                      ),
                                                                      Container(
                                                                        child: TextView("Sisa", 3, color: Colors.black),
                                                                      ),
                                                                      SizedBox(height: 15),
                                                                      Container(
                                                                        child: Column(
                                                                          children:
                                                                          List.generate(resultObject[13].length,(index){
                                                                            return Container(
                                                                              margin: EdgeInsets.only(top: 10),
                                                                              child: TextView("Rp "+ currencyFormatter.format(double.parse(resultObject[13][index]["sisa"])), 4)
                                                                            );
                                                                          }),
                                                                        ),
                                                                      ),

                                                                      // DataTable(
                                                                      //   columns: [
                                                                      //     DataColumn(
                                                                      //       label: TextView("Document No", 4,)
                                                                      //     ),
                                                                      //     DataColumn(
                                                                      //       label: TextView("Sisa", 4)
                                                                      //     ),
                                                                      //   ],
                                                                      //   rows: List.generate(resultObject[13].length,(index){
                                                                      //     return DataRow(
                                                                      //       cells: [
                                                                      //         DataCell(TextView("${resultObject[13][index]["document_no"]}", 4)),
                                                                      //         DataCell(TextView("Rp "+ currencyFormatter.format(double.parse(resultObject[13][index]["sisa"])), 4)),
                                                                      //       ]
                                                                      //     );
                                                                      //   }),
                                                                      // ),

                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        : Alert(
                                                            context: context,
                                                            title: "Info,",
                                                            content: Text(
                                                                "Tidak ada data"),
                                                            cancel: false,
                                                            type: "warning");
                                                  },
                                                  child: Container(
                                                    height: 75,
                                                    width: 75,
                                                    child: Center(
                                                      child: Image.asset(
                                                          "assets/illustration/pipe.png",
                                                          alignment:
                                                              Alignment.center,
                                                          fit: BoxFit.contain,
                                                          height: 50),
                                                    ),
                                                  ),
                                                ),
                                                elevation: 3,
                                                shadowColor:
                                                    config.grayNonActiveColor,
                                                margin: EdgeInsets.all(20),
                                                shape: CircleBorder(
                                                  side: BorderSide(
                                                      width: 1,
                                                      color: Colors.white),
                                                ),
                                              )
                                            ],
                                          ),
                                          Text("Bahan Bangunan"),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Card(
                                            child: InkWell(
                                              onTap: () {
                                                resultObject[14].length != 0
                                                    ? showAvatarModalBottomSheet(
                                                        expand: true,
                                                        context: context,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        builder: (context) =>
                                                            ModalWithPageView(
                                                          modalTitle:
                                                              "Faktur Terdekat Jatuh Tempo",
                                                          modalContent: [
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Container(
                                                                    child: TextView("Mebel (${resultObject[14][0]["due_date"]})", 3, color: Colors.black),
                                                                  ),
                                                                  SizedBox(height: 30),
                                                                  Container(
                                                                    child: TextView("Document No", 3, color: Colors.black),
                                                                  ),
                                                                  SizedBox(height: 15),
                                                                  Container(
                                                                    child: Column(
                                                                      children: List.generate(resultObject[14].length,(index){
                                                                        return Container(
                                                                          margin: EdgeInsets.only(top: 10),
                                                                          child: TextView(resultObject[14][index]["document_no"], 4)
                                                                        );
                                                                      }),
                                                                    ),
                                                                  ),
                                                                  Divider(
                                                                    height: 40,
                                                                    thickness: 4,
                                                                    color: config.lighterGrayColor,
                                                                  ),
                                                                  Container(
                                                                    child: TextView("Sisa", 3, color: Colors.black),
                                                                  ),
                                                                  SizedBox(height: 15),
                                                                  Container(
                                                                    child: Column(
                                                                      children:
                                                                      List.generate(resultObject[14].length,(index){
                                                                        return Container(
                                                                          margin: EdgeInsets.only(top: 10),
                                                                          child: TextView("Rp "+ currencyFormatter.format(double.parse(resultObject[14][index]["sisa"])), 4)
                                                                        );
                                                                      }),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    : Alert(
                                                        context: context,
                                                        title: "Info,",
                                                        content: Text(
                                                            "Tidak ada data"),
                                                        cancel: false,
                                                        type: "warning");
                                              },
                                              child: Container(
                                                height: 75,
                                                width: 75,
                                                child: Center(
                                                  child: Image.asset(
                                                      "assets/illustration/furniture.png",
                                                      alignment: Alignment.center,
                                                      fit: BoxFit.contain,
                                                      height: 50),
                                                ),
                                              ),
                                            ),
                                            elevation: 3,
                                            shadowColor:
                                                config.grayNonActiveColor,
                                            margin: EdgeInsets.all(20),
                                            shape: CircleBorder(
                                              side: BorderSide(
                                                  width: 1, color: Colors.white),
                                            ),
                                          ),
                                          Text("Mebel"),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 60,
                              thickness: 4,
                              color: config.lighterGrayColor,
                            ),
                            Container(
                              child:
                                  TextView("Omzet", 1, color: config.blueColor),
                            ),
                            Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Container(
                                      child: Column(
                                        children: [
                                          Card(
                                            child: InkWell(
                                              onTap: () {
                                                resultObject[15][0].length != 0
                                                    ? showAvatarModalBottomSheet(
                                                        expand: true,
                                                        context: context,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        builder: (context) =>
                                                            ModalWithPageView(
                                                          modalTitle: "Omzet",
                                                          modalContent: [
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Container(
                                                                    child: TextView("Cat", 3, color: Colors.black),
                                                                  ),
                                                                  SizedBox(height: 30),
                                                                  Container(
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Container(
                                                                          child: TextView("Pengambilan Tertinggi", 3, color: Colors.black),
                                                                        ),
                                                                        SizedBox(height: 15),
                                                                        Container(
                                                                          child: Column(
                                                                            children: List.generate(resultObject[15].length, (index) {
                                                                              return Container(
                                                                                margin: EdgeInsets.only(top: 10),
                                                                                child: TextView("Rp " + currencyFormatter.format(resultObject[15][index]["jum_byr"]), 4)
                                                                                );  
                                                                              },
                                                                            )
                                                                          ),
                                                                        ),
                                                                        Divider(
                                                                          height: 40,
                                                                          thickness: 4,
                                                                          color: config.lighterGrayColor,
                                                                        ),
                                                                        Container(
                                                                          child: TextView("Rata-rata Payment", 3, color: Colors.black),
                                                                        ),
                                                                        SizedBox(height: 15),
                                                                        Container(
                                                                          child: Column(
                                                                            children: List.generate(resultObject[15].length, (index) {
                                                                              return Container(
                                                                                child: TextView("Rp " + currencyFormatter.format(resultObject[15][index]["rata2"]) + " (" + "${resultObject[15][index]["pengali"]} x)", 4, align: TextAlign.end)
                                                                                );  
                                                                              },
                                                                            )
                                                                          ),
                                                                        ),
                                                                        Divider(
                                                                          height: 40,
                                                                          thickness: 4,
                                                                          color: config.lighterGrayColor,
                                                                        ),
                                                                        Container(
                                                                          child: TextView("Total Omzet", 3, color: Colors.black),
                                                                        ),
                                                                        SizedBox(height: 15),
                                                                        Container(
                                                                          child: TextView("Rp " + currencyFormatter.format(resultObject[18]["total_omzet_cat"]), 4),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    : Alert(
                                                        context: context,
                                                        title: "Info,",
                                                        content: Text(
                                                            "Tidak ada data"),
                                                        cancel: false,
                                                        type: "warning");
                                              },
                                              child: Container(
                                                height: 75,
                                                width: 75,
                                                child: Center(
                                                  child: Image.asset(
                                                      "assets/illustration/varnish.png",
                                                      alignment: Alignment.center,
                                                      fit: BoxFit.contain,
                                                      height: 50),
                                                ),
                                              ),
                                            ),
                                            elevation: 3,
                                            shadowColor:
                                                config.grayNonActiveColor,
                                            margin: EdgeInsets.all(20),
                                            shape: CircleBorder(
                                              side: BorderSide(
                                                  width: 1, color: Colors.white),
                                            ),
                                          ),
                                          Text("Cat"),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Card(
                                            child: InkWell(
                                              onTap: () {
                                                resultObject[16][0].length != 0
                                                    ? showAvatarModalBottomSheet(
                                                        expand: true,
                                                        context: context,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        builder: (context) =>
                                                            ModalWithPageView(
                                                          modalTitle: "Omzet",
                                                          modalContent: [
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Container(
                                                                    child: TextView("BB", 3, color: Colors.black),
                                                                  ),
                                                                  SizedBox(height: 30),
                                                                  Container(
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Container(
                                                                          child: TextView("Pengambilan Tertinggi", 3, color: Colors.black),
                                                                        ),
                                                                        SizedBox(height: 15),
                                                                        Container(
                                                                          child: Column(
                                                                            children: List.generate(resultObject[15].length, (index) {
                                                                              return Container(
                                                                                margin: EdgeInsets.only(top: 10),
                                                                                child: TextView("Rp " + currencyFormatter.format(resultObject[16][index]["jum_byr"]), 4)
                                                                                );  
                                                                              },
                                                                            )
                                                                          ),
                                                                        ),
                                                                        Divider(
                                                                          height: 40,
                                                                          thickness: 4,
                                                                          color: config.lighterGrayColor,
                                                                        ),
                                                                        Container(
                                                                          child: TextView("Rata-rata Payment", 3, color: Colors.black),
                                                                        ),
                                                                        SizedBox(height: 15),
                                                                        Container(
                                                                          child: Column(
                                                                            children: List.generate(resultObject[15].length, (index) {
                                                                              return Container(
                                                                                child: TextView("Rp " + currencyFormatter.format(resultObject[16][index]["rata2"]) + " (" + "${resultObject[16][index]["pengali"]} x)", 4, align: TextAlign.end)
                                                                                );  
                                                                              },
                                                                            )
                                                                          ),
                                                                        ),
                                                                        Divider(
                                                                          height: 40,
                                                                          thickness: 4,
                                                                          color: config.lighterGrayColor,
                                                                        ),
                                                                        Container(
                                                                          child: TextView("Total Omzet", 3, color: Colors.black),
                                                                        ),
                                                                        SizedBox(height: 15),
                                                                        Container(
                                                                          child: TextView("Rp " + currencyFormatter.format(resultObject[19]["total_omzet_bb"]), 4),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  
                                                                  // Container(
                                                                  //   child: Column(
                                                                  //     children: [
                                                                  //       Container(
                                                                  //         child: Row(
                                                                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  //           crossAxisAlignment: CrossAxisAlignment.start,
                                                                  //           children: [
                                                                  //             Container(
                                                                  //               child: TextView("Pengambilan Tertinggi", 4),
                                                                  //             ),
                                                                  //             Container(
                                                                  //               child: Column(
                                                                  //                 children: List.generate(resultObject[16].length, (index) {
                                                                  //                   return Container(
                                                                  //                     margin: EdgeInsets.only(top: 10),
                                                                  //                     child: TextView("Rp " + currencyFormatter.format(resultObject[16][index]["jum_byr"]), 4)
                                                                  //                     );  
                                                                  //                   },
                                                                  //                 )
                                                                  //               ),
                                                                  //             )
                                                                  //           ],
                                                                  //         ),
                                                                  //       ),
                                                                  //       SizedBox(height: 40),
                                                                  //       Container(
                                                                  //         child: Row(
                                                                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  //           children: [
                                                                  //             Container(
                                                                  //               child: TextView("Rata-rata Payment", 4),
                                                                  //             ),
                                                                  //             Container(
                                                                  //               child: Column(
                                                                  //                 children: List.generate(resultObject[16].length, (index) {
                                                                  //                   return Container(
                                                                  //                     child: TextView("Rp " + currencyFormatter.format(resultObject[16][index]["rata2"]) + "\n(" + "${resultObject[16][index]["pengali"]} x)", 4, align: TextAlign.end)
                                                                  //                     );  
                                                                  //                   },
                                                                  //                 )
                                                                  //               ),
                                                                  //             )
                                                                  //           ],
                                                                  //         ),
                                                                  //       ),
                                                                  //       SizedBox(height: 40),
                                                                  //       Container(
                                                                  //         child: Row(
                                                                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  //           children: [
                                                                  //             Container(
                                                                  //               child: TextView("Total Omzet", 4),
                                                                  //             ),
                                                                  //             Container(
                                                                  //               child: TextView("Rp " + currencyFormatter.format(resultObject[19]["total_omzet_bb"]), 4),
                                                                  //             )
                                                                  //           ],
                                                                  //         ),
                                                                  //       ),
                                                                  //     ],
                                                                  //   ),
                                                                  // ),

                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    : Alert(
                                                        context: context,
                                                        title: "Info,",
                                                        content: Text(
                                                            "Tidak ada data"),
                                                        cancel: false,
                                                        type: "warning");
                                              },
                                              child: Container(
                                                height: 75,
                                                width: 75,
                                                child: Center(
                                                  child: Image.asset(
                                                      "assets/illustration/pipe.png",
                                                      alignment: Alignment.center,
                                                      fit: BoxFit.contain,
                                                      height: 50),
                                                ),
                                              ),
                                            ),
                                            elevation: 3,
                                            shadowColor:
                                                config.grayNonActiveColor,
                                            margin: EdgeInsets.all(20),
                                            shape: CircleBorder(
                                              side: BorderSide(
                                                  width: 1, color: Colors.white),
                                            ),
                                          ),
                                          Text("Bahan Bangunan"),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Card(
                                            child: InkWell(
                                              onTap: () {
                                                resultObject[17][0].length != 0
                                                    ? showAvatarModalBottomSheet(
                                                        expand: true,
                                                        context: context,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        builder: (context) =>
                                                            ModalWithPageView(
                                                          modalTitle: "Omzet",
                                                          modalContent: [
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Container(
                                                                    child: TextView("Mebel", 3, color: Colors.black),
                                                                  ),
                                                                  SizedBox(height: 30),
                                                                  Container(
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Container(
                                                                          child: TextView("Pengambilan Tertinggi", 3, color: Colors.black),
                                                                        ),
                                                                        SizedBox(height: 15),
                                                                        Container(
                                                                          child: Column(
                                                                            children: List.generate(resultObject[15].length, (index) {
                                                                              return Container(
                                                                                margin: EdgeInsets.only(top: 10),
                                                                                child: TextView("Rp " + currencyFormatter.format(resultObject[17][index]["jum_byr"]), 4)
                                                                                );  
                                                                              },
                                                                            )
                                                                          ),
                                                                        ),
                                                                        Divider(
                                                                          height: 40,
                                                                          thickness: 4,
                                                                          color: config.lighterGrayColor,
                                                                        ),
                                                                        Container(
                                                                          child: TextView("Rata-rata Payment", 3, color: Colors.black),
                                                                        ),
                                                                        SizedBox(height: 15),
                                                                        Container(
                                                                          child: Column(
                                                                            children: List.generate(resultObject[15].length, (index) {
                                                                              return Container(
                                                                                child: TextView("Rp " + currencyFormatter.format(resultObject[17][index]["rata2"]) + " (" + "${resultObject[17][index]["pengali"]} x)", 4, align: TextAlign.end)
                                                                                );  
                                                                              },
                                                                            )
                                                                          ),
                                                                        ),
                                                                        Divider(
                                                                          height: 40,
                                                                          thickness: 4,
                                                                          color: config.lighterGrayColor,
                                                                        ),
                                                                        Container(
                                                                          child: TextView("Total Omzet", 3, color: Colors.black),
                                                                        ),
                                                                        SizedBox(height: 15),
                                                                        Container(
                                                                          child: TextView("Rp " + currencyFormatter.format(resultObject[20]["total_omzet_mebel"]), 4),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    : Alert(
                                                        context: context,
                                                        title: "Info,",
                                                        content: Text(
                                                            "Tidak ada data"),
                                                        cancel: false,
                                                        type: "warning");
                                              },
                                              child: Container(
                                                height: 75,
                                                width: 75,
                                                child: Center(
                                                  child: Image.asset(
                                                      "assets/illustration/furniture.png",
                                                      alignment: Alignment.center,
                                                      fit: BoxFit.contain,
                                                      height: 50),
                                                ),
                                              ),
                                            ),
                                            elevation: 3,
                                            shadowColor:
                                                config.grayNonActiveColor,
                                            margin: EdgeInsets.all(20),
                                            shape: CircleBorder(
                                              side: BorderSide(
                                                  width: 1, color: Colors.white),
                                            ),
                                          ),
                                          Text("Mebel"),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 60,
                              thickness: 4,
                              color: config.lighterGrayColor,
                            ),
                            Container(
                              child: TextView("Informasi Lainnya", 1, color: config.blueColor),
                            ),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 15),
                                  TextView("SO Outstanding", 3, color: Colors.black),
                                  SizedBox(height: 10),
                                  TextView("Rp " + currencyFormatter.format(resultObject[11]["ov"]),4),
                                  SizedBox(height: 30),
                                  TextView("Shipment Not Invoiced", 3, color: Colors.black),
                                  SizedBox(height: 10),
                                  TextView("Rp " + currencyFormatter.format(resultObject[9]["jum"]),4),
                                  SizedBox(height: 30),
                                  TextView("Total Retur", 3, color: Colors.black),
                                  SizedBox(height: 10),
                                  TextView("Rp " + currencyFormatter.format(resultObject[8]["retur"]),4),
                                  SizedBox(height: 30),
                                  TextView("Piutang", 3, color: Colors.black),
                                  SizedBox(height: 10),
                                  TextView("Rp " + currencyFormatter.format(resultObject[10]["piutang"]),4),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
    
                  // informationDetailWidgetList.length == 0
                  // ?
                  // Container()
                  // :
                  // ListView(
                  //   scrollDirection: Axis.vertical,
                  //   padding: EdgeInsets.all(0),
                  //   physics: ScrollPhysics(),
                  //   shrinkWrap: true,
                  //   children: informationDetailWidgetList,
                  // ),
                ],
              ),
            )),
      )
    );
  }

  showChangeLimit(Configuration config) {
    List<Widget> tempWidgetList = [];

    final currencyFormatter = NumberFormat('#,##0', 'ID');

    if (result != null) {
      final resultObject = jsonDecode(result.data.toString());

      var blockedType = resultObject[0]["blocked"];
      var blockedTypeSelected;

      if (blockedType == 3) {
        blockedTypeSelected = "Blocked All";
      } else if (blockedType == 2) {
        blockedTypeSelected = "Blocked Invoice";
      } else if (blockedType == 1) {
        blockedTypeSelected = "Blocked Ship";
      } else {
        blockedTypeSelected = "Not Blocked";
      }

      tempWidgetList.add(Container(
        child: Form(
          key: _AddLimitFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: TextFormField(
                  enabled: false,
                  decoration: new InputDecoration(
                    hintStyle: TextStyle(color: Colors.black),
                    labelStyle: TextStyle(color: Colors.black),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Kode Pelanggan",
                    hintText: resultObject[0]["No_"],
                    icon: Icon(Icons.bookmark, color: config.grayColor),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(
                        5.0,
                      ),
                      borderSide: BorderSide(
                        color: config.grayColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: TextFormField(
                  enabled: false,
                  decoration: new InputDecoration(
                    hintStyle: TextStyle(color: Colors.black),
                    labelStyle: TextStyle(color: Colors.black),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Nama Pelanggan",
                    hintText: resultObject[0]["Name"],
                    icon: Icon(Icons.person, color: config.grayColor),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(
                        5.0,
                      ),
                      borderSide: BorderSide(
                        color: config.grayColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: TextFormField(
                  enabled: false,
                  decoration: new InputDecoration(
                    hintStyle: TextStyle(color: Colors.black),
                    labelStyle: TextStyle(color: Colors.black),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Alamat Pelanggan",
                    hintText: resultObject[0]["Address"],
                    icon: Icon(Icons.location_on, color: config.grayColor),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(
                        5.0,
                      ),
                      borderSide: BorderSide(
                        color: config.grayColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: TextFormField(
                  enabled: false,
                  decoration: new InputDecoration(
                    hintStyle: TextStyle(color: Colors.black),
                    labelStyle: TextStyle(color: Colors.black),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Status",
                    hintText:
                        resultObject[0]["disc"] + " | " + blockedTypeSelected,
                    icon: Icon(Icons.list_alt, color: config.grayColor),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(
                        5.0,
                      ),
                      borderSide: BorderSide(
                        color: config.grayColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: TextFormField(
                  inputFormatters: <TextInputFormatter>[
                      CurrencyTextInputFormatter(
                        locale: 'IDR',
                        decimalDigits: 0,
                        symbol: '',
                      ),
                    ],
                  keyboardType: TextInputType.number,
                  enabled: user_login.toLowerCase().contains("kc") ? false : true,
                  controller: limitDMDController,
                  decoration: new InputDecoration(
                    hintStyle: TextStyle(color: Colors.black),
                    labelStyle: TextStyle(color: Colors.black),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Limit DSD",
                    // hintText: resultObject[0]["limit_dmd"].toString(),
                    icon: TextView("Rp ", 5),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(
                        5.0,
                      ),
                      borderSide: BorderSide(
                        color: Colors.black54,
                        width: 1.5,
                      ),
                    ),
                    disabledBorder: user_login.toLowerCase().contains("kc") ?
                    OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(
                        5.0,
                      ),
                      borderSide: BorderSide(
                        color: config.grayColor,
                        width: 1.5,
                      ),
                    ) : null,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: TextFormField(
                  enabled: false,
                  decoration: new InputDecoration(
                    hintStyle: TextStyle(color: Colors.black),
                    labelStyle: TextStyle(color: Colors.black),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Limit Saat Ini",
                    hintText: currencyFormatter
                        .format(int.parse(resultObject[0]["Limit"])),
                    icon: TextView("Rp ", 5, color: config.grayColor),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(
                        5.0,
                      ),
                      borderSide: BorderSide(
                        color: config.grayColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: TextFormField(
                  inputFormatters: <TextInputFormatter>[
                      CurrencyTextInputFormatter(
                        locale: 'IDR',
                        decimalDigits: 0,
                        symbol: '',
                      ),
                    ],
                  keyboardType: TextInputType.number,
                  enabled: true,
                  controller: limitRequestController,
                  decoration: new InputDecoration(
                    hintStyle: TextStyle(color: Colors.black),
                    labelStyle: TextStyle(color: Colors.black),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Limit Yang Diajukan",
                    icon: TextView("Rp ", 5),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(
                        5.0,
                      ),
                      borderSide: BorderSide(
                        color: Colors.black54,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                  child: Button(
                    key: Key("submit"),
                    loading: changeLimitLoading,
                    backgroundColor: config.darkOpacityBlueColor,
                    child: TextView(
                      "UBAH",
                      3,
                      caps: true,
                    ),
                    onTap: () {
                      updateLimit();
                      // Alert(
                      //   context: context,
                      //   title: "Alert",
                      //   content: Text(limitDMDController.text.toString()),
                      //   cancel: false,
                      //   type: "warning"
                      // );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ));
    }

    return tempWidgetList;
  }

  void updateLimit() async {
    // setState(() {
    //   limitDMDController.text.isEmpty ? customerIdValid = true : customerIdValid = false;
    // });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int limit_dmd_lama = prefs.getInt("limit_dmd");
    int max_limit = prefs.getInt("max_limit");

    printHelp("get limit dmd lama " + limit_dmd_lama.toString());
    printHelp("get max  limit " + max_limit.toString());

    if(!user_login.toLowerCase().contains("kc")) {
      if ((limitDMDController.text.isEmpty ||
            limitRequestController.text.isEmpty) ||
          (limitRequestController.text.isEmpty &&
              int.parse(limitDMDController.text.replaceAll(new RegExp('\\.'),'')) == limit_dmd_lama)) {
        Alert(
            context: context,
            title: "Info,",
            content: Text("Limit Baru atau Limit DSD harus diisi"),
            cancel: false,
            type: "warning");
      } else {
        if (int.parse(limitDMDController.text.replaceAll(new RegExp('\\.'),'')) != 0 &&
            int.parse(limitRequestController.text.replaceAll(new RegExp('\\.'),'')) >
                int.parse(limitDMDController.text.replaceAll(new RegExp('\\.'),''))) {
          Alert(
              context: context,
              title: "Info,",
              content: Text("Limit Baru melebihi Limit DSD!"),
              cancel: false,
              type: "warning");
        } else if (int.parse(limitDMDController.text.replaceAll(new RegExp('\\.'),'')) == 0 ||
            (int.parse(limitDMDController.text.replaceAll(new RegExp('\\.'),'')) != 0 &&
                int.parse(limitRequestController.text.replaceAll(new RegExp('\\.'),'')) <=
                    int.parse(limitDMDController.text.replaceAll(new RegExp('\\.'),'')))) {
          if (int.parse(limitRequestController.text.replaceAll(new RegExp('\\.'),'')) > max_limit) {
            Alert(
                context: context,
                title: "Konfirmasi,",
                content: Text("Limit melebihi kapasitas. Kirim permintaan?"),
                cancel: true,
                type: "warning",
                defaultAction: () {
                  addRequestLimit();
                });
          } else {
            Alert(
              context: context,
              title: "Konfirmasi,",
              content: Text("Ubah Limit Customer?"),
              cancel: true,
              type: "warning",
              defaultAction: () {
                changeLimit();
              }
            );
          }
        }
      }

    } else {
      if (limitRequestController.text.isEmpty) {
        Alert(
            context: context,
            title: "Info,",
            content: Text("Limit Baru harus diisi"),
            cancel: false,
            type: "warning");
      } else {
        if (int.parse(limitDMDController.text.replaceAll(new RegExp('\\.'),'')) != 0 &&
            int.parse(limitRequestController.text.replaceAll(new RegExp('\\.'),'')) >
                int.parse(limitDMDController.text.replaceAll(new RegExp('\\.'),''))) {
          Alert(
              context: context,
              title: "Info,",
              content: Text("Limit Baru melebihi Limit DSD!"),
              cancel: false,
              type: "warning");
        } else if (int.parse(limitDMDController.text.replaceAll(new RegExp('\\.'),'')) == 0 ||
            (int.parse(limitDMDController.text.replaceAll(new RegExp('\\.'),'')) != 0 &&
                int.parse(limitRequestController.text.replaceAll(new RegExp('\\.'),'')) <=
                    int.parse(limitDMDController.text.replaceAll(new RegExp('\\.'),'')))) {
          if (int.parse(limitRequestController.text.replaceAll(new RegExp('\\.'),'')) > max_limit) {
            Alert(
                context: context,
                title: "Konfirmasi,",
                content: Text("Limit melebihi kapasitas. Kirim permintaan?"),
                cancel: true,
                type: "warning",
                defaultAction: () {
                  addRequestLimit();
                });
          } else {
            Alert(
              context: context,
              title: "Konfirmasi,",
              content: Text("Ubah Limit Customer?"),
              cancel: true,
              type: "warning",
              defaultAction: () {
                changeLimit();
              }
            );
          }
        }
      }

    }

    
  }

  void changeLimit() async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      changeLimitLoading = true;
    });

    Alert(context: context, loading: true, disableBackButton: true);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // var obj = {"kode_customer": $$('#kode_cust').val(),"nama_cust":$$('#nama_cust').val(), "limit_baru": limit_baru, "user_code": localStorage.getItem('user_code'), "old_limit": localStorage.getItem('old_limit'), "piutang": piutang, "limit_dmd_lama": limit_dmd_lama, "limit_dmd_baru": limit_dmd_baru};
    // currencyFormatter.format(int.parse(resultObject[0]["Limit"]))

    String getChangeLimit = await customerAPI.changeLimit(context,
        parameter:
            'json={"kode_customer":"${resultObject[0]['No_']}","user_code":"${prefs.getString('user_code')}","nama_cust":"${resultObject[0]['Name']}","limit_baru":"${limitRequestController.text.replaceAll(new RegExp('\\.'),'')}","old_limit":"${resultObject[0]['Limit']}","piutang":${resultObject[10]['piutang']},"limit_dmd_lama":"${prefs.getInt('limit_dmd')}","limit_dmd_baru":"${limitDMDController.text.replaceAll(new RegExp('\\.'),'')}"}');

    Navigator.of(context).pop();

    if (getChangeLimit == "OK") {
      Alert(
          context: context,
          title: "Terima kasih,",
          content: Text("Ubah limit sukses"),
          cancel: false,
          type: "success",
          defaultAction: () {
            Navigator.pop(context);
          }
        );
    } else {
      Alert(
          context: context,
          title: "Info,",
          content: Text(getChangeLimit),
          cancel: false,
          type: "warning");
    }

    setState(() {
      changeLimitLoading = false;
    });
  }

  void addRequestLimit() async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      changeLimitLoading = true;
    });

    Alert(context: context, loading: true, disableBackButton: true);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String getRequestLimit = await customerAPI.addRequestLimit(context, parameter: 'json={"kode_customer":"${resultObject[0]['No_']}","user_code":"${prefs.getString('user_code')}","nama_cust":"${resultObject[0]['Name']}","limit_baru":"${limitRequestController.text.replaceAll(new RegExp('\\.'),'')}","limit_dmd_baru":"${limitDMDController.text.replaceAll(new RegExp('\\.'),'')}"}');

    Navigator.of(context).pop();

    if (getRequestLimit == "OK") {
      Alert(
          context: context,
          title: "Terima kasih,",
          content: Text("Permintaan sudah dikirim"),
          cancel: false,
          type: "success",
          defaultAction: () {
            Navigator.pop(context);
          }
        );
    } else {
      Alert(
          context: context,
          title: "Maaf,",
          content: Text(getRequestLimit),
          cancel: false,
          type: "error");
    }

    setState(() {
      changeLimitLoading = false;
    });
  }

  showInformationDetail(Configuration config) {}

}
