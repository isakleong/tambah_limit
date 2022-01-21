import 'dart:convert';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tambah_limit/models/limitHistoryModel.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/resources/customerAPI.dart';
import 'package:tambah_limit/resources/limitHistoryAPI.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';
import 'package:tambah_limit/widgets/TextView.dart';
import 'package:tambah_limit/widgets/button.dart';
import 'package:tambah_limit/widgets/circularModal.dart';
import 'package:tambah_limit/widgets/modalPageView.dart';

class HistoryLimitRequestDetail extends StatefulWidget {
  final Result model;
  final int id;
  final int mode;
  final int notificationType;

  HistoryLimitRequestDetail({Key key, this.model, this.id, this.mode, this.notificationType}) : super(key: key);

  @override
  HistoryLimitRequestDetailState createState() => HistoryLimitRequestDetailState();
}


class HistoryLimitRequestDetailState extends State<HistoryLimitRequestDetail> {

  Result result;
  var resultObject;
  int historyLimitId, pageType;
  int notificationType;

  String user_login = "";

  String user_code = "";
  int request_limit = 0;
  int request_limit_dmd = 0;
  String user_code_request = "";

  bool acceptLimitRequestLoading = false;
  bool rejectLimitRequestLoading = false;

  final _HistoryLimitFormKey = GlobalKey<FormState>();
  final _AddLimitFormKey = GlobalKey<FormState>();

  final limitDMDController = TextEditingController();
  final limitRequestController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final currencyFormatter = NumberFormat('#,##0', 'ID');

  bool checkModulePrivilegeLoading = true;
  bool isNeedApproval = false;

  bool getLimitRequestApprovalStatusLoading = true;
  bool isLimitRequestApprovalExist = false;
  String limitRequestApprovalMessage = "";

  @override
  void initState() {
    super.initState();

    result = widget.model;
    historyLimitId = widget.id;
    pageType = widget.mode;
    notificationType = widget.notificationType;
  }

  @override
  void didChangeDependencies() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      user_login = prefs.getString("get_user_login");
    });

    user_code = prefs.getString('user_code');

    if(checkModulePrivilegeLoading) {
      checkModulePrivilege();
    }

    final _resultObject = jsonDecode(result.data.toString());

    //get limit request approval status
    if(getLimitRequestApprovalStatusLoading) {
      getLimitRequestApprovalStatus();
    }

    if(pageType > 3){
      // final _newValue = currencyFormatter.format(_resultObject[0]["old_limit"]).toString();
        limitDMDController.value = TextEditingValue(
          text: _resultObject[0]["old_limit"].toString(),
          selection: TextSelection.fromPosition(
            TextPosition(offset: _resultObject[0]["old_limit"].length),
          ),
        );
    } else {
      final _newValue = currencyFormatter.format(_resultObject[0]["limit_dmd"]).toString();
        limitDMDController.value = TextEditingValue(
              text: _newValue,
              selection: TextSelection.fromPosition(
                TextPosition(offset: _newValue.length),
              ),
            );
    }

    if(prefs.containsKey("request_limit")) {
      request_limit = prefs.getInt("request_limit");
      
      limitRequestController.value = TextEditingValue(
        text: currencyFormatter.format(request_limit).toString(),
        selection: TextSelection.fromPosition(
          TextPosition(offset: request_limit.toString().length),
        ),
      );
    }

    if(prefs.containsKey("request_limit_dmd")) {
      request_limit_dmd = prefs.getInt("request_limit_dmd");

      limitDMDController.value = TextEditingValue(
        text: currencyFormatter.format(request_limit_dmd).toString(),
        selection: TextSelection.fromPosition(
          TextPosition(offset: request_limit_dmd.toString().length),
        ),
      );
    }
    
    user_code_request = prefs.getString("user_code_request");
    
    setState(() {
      resultObject = _resultObject;
    });
    
    if(resultObject[0]["limit_dmd"] != null){
      prefs.setInt("limit_dmd", resultObject[0]["limit_dmd"]);
    }
    
  }

  getLimitRequestApprovalStatus() async {
    if(pageType == 1 || pageType == 4) {
      setState(() {
        getLimitRequestApprovalStatusLoading = true;
        isLimitRequestApprovalExist = false;
        limitRequestApprovalMessage = "";
      });

      String getLimitRequestApprovalStatus = await limitHistoryAPI.getLimitRequestApprovalStatus(context, parameter: 'json={"id_approval":"${widget.id.toString()}"}');

      try {
        if(int.parse(getLimitRequestApprovalStatus) > 0) {
          isLimitRequestApprovalExist = true;
          limitRequestApprovalMessage = "Menunggu persetujuan Sales Director";
        } else {
            isLimitRequestApprovalExist = false;
        }

        if((pageType == 1 || pageType == 4) && !isNeedApproval && user_code_request.toLowerCase() == user_login.toLowerCase()) {
          isLimitRequestApprovalExist = true;
          limitRequestApprovalMessage = "Menunggu persetujuan Sales Director";
        }
      } catch (e) {
        isLimitRequestApprovalExist = true;
        limitRequestApprovalMessage = "Menunggu persetujuan Sales Director";
        Alert(
          context: context,
          title: "Maaf,",
          content: Text(getLimitRequestApprovalStatus),
          cancel: false,
          type: "error",
          defaultAction: () {}
        );
      }

      setState(() {
        getLimitRequestApprovalStatusLoading = false;
        isLimitRequestApprovalExist = isLimitRequestApprovalExist;
        limitRequestApprovalMessage = limitRequestApprovalMessage;
      });

    } else {
      setState(() {
        getLimitRequestApprovalStatusLoading = true;
        isLimitRequestApprovalExist = false;
        limitRequestApprovalMessage = "";
      });

      String getLimitRequestApprovalStatus = await limitHistoryAPI.getLimitRequestApprovalStatus(context, parameter: 'json={"id":"${widget.id.toString()}"}');

      try {
        if(getLimitRequestApprovalStatus != null) {
          isLimitRequestApprovalExist = true;
          var jsonObject = json.decode(getLimitRequestApprovalStatus);
          final dateTime = DateTime.parse(jsonObject['date'].toString()); 
          final dateFormat = DateFormat('dd-MM-yyyy H:m:s');
          final dateApproval = dateFormat.format(dateTime);
          print(dateApproval);
          
          if(pageType == 2 || pageType == 5) {
            limitRequestApprovalMessage = "Disetujui pada\n" + dateApproval;
          } else {
            limitRequestApprovalMessage = "Ditolak pada\n" + dateApproval;
          }
        } else {
          isLimitRequestApprovalExist = false;
        }

        // if((pageType == 1 || pageType == 4) && !isNeedApproval && user_code_request.toLowerCase() == user_login.toLowerCase()) {
        //   isLimitRequestApprovalExist = true;
        // }
      } catch (e) {
        isLimitRequestApprovalExist = true;
        Alert(
          context: context,
          title: "Maaf,",
          content: Text(getLimitRequestApprovalStatus),
          cancel: false,
          type: "error",
          defaultAction: () {}
        );
      }

      setState(() {
        getLimitRequestApprovalStatusLoading = false;
        isLimitRequestApprovalExist = isLimitRequestApprovalExist;
        limitRequestApprovalMessage = limitRequestApprovalMessage;
      });
    }
    
    
    
  }

  checkModulePrivilege() async {
    setState(() {
      checkModulePrivilegeLoading = true;
      isNeedApproval = false;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> privilegeList = prefs.getStringList("module_privilege") ?? [];

    if(privilegeList.contains("LIMITREQUESTAPPROVAL")) {
      if(user_login.toLowerCase().contains("dsd")){
        if(user_code_request.toLowerCase().contains("kc")){
          isNeedApproval = true;
        } else {
          isNeedApproval = false;
        }
      } else {
        isNeedApproval = true;
      }
    }

    setState(() {
      checkModulePrivilegeLoading = false;
      isNeedApproval = isNeedApproval;
    });
  }


  @override
  Widget build(BuildContext context) {
    if(pageType < 4){
      List<Widget> changeLimitWidgetList = showChangeLimit(config);
      // List<Widget> informationDetailWidgetList = showInformationDetail(config);

      final resultObject = jsonDecode(result.data.toString());

      return DefaultTabController(
        length: 2,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                new SliverAppBar(
                  title: pageType == 1
                    ?
                    TextView('Limit Yang Diminta', 1)
                    :
                    pageType == 2
                    ?
                    TextView('Limit Yang Disetujui', 1)
                    :
                    TextView('Limit Yang Ditolak', 1),
                  pinned: true,
                  floating: true,
                  bottom: TabBar(
                    isScrollable: true,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: [
                      Tab(icon: Icon(Icons.book_rounded), child: TextView("Ubah Limit", 3)),
                      Tab(icon: Icon(Icons.info_rounded), child: TextView("Detail Informasi", 3))
                      ],
                    ),
                )
              ];
            },
            body: TabBarView(
              children: [
                changeLimitWidgetList.length == 0
                ? 
                Container()
                :
                //View Limit section
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
                    padding: EdgeInsets.symmetric(vertical:30, horizontal:30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: TextView("Ketepatan Waktu Pembayaran", 1, color: config.blueColor),
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
                                          onTap: (){
                                            //bottom sheet
                                            resultObject[1]["pembayaranc1"] != 0 || resultObject[1]["pembayaranc2"] !=0 || resultObject[1]["pembayaranc3"] !=0 || 
                                            resultObject[1]["pembayaranc4"] !=0
                                            ?
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
                                                          child: TextView("Rentang Cat 1 (0 - ${resultObject[3]["top_cat"].toString()})", 3, color: Colors.black),
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
                                                          child: TextView("Rentang Cat 2 (${resultObject[3]["top_cat"]+1} - 70)", 3, color: Colors.black),
                                                        ),
                                                        SizedBox(height: 30),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                          color: config.lighterGrayColor,
                                                        ),
                          
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
                                              child: Image.asset("assets/illustration/varnish.png", alignment: Alignment.center, fit: BoxFit.contain, height: 50,),
                                              ),
                                            ),
                                        ),
                                          elevation: 3,
                                          shadowColor: config.grayNonActiveColor,
                                          margin: EdgeInsets.all(20),
                                          shape: CircleBorder(side: BorderSide(width: 1, color: Colors.white),
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
                                          onTap: (){
                                            resultObject[7]["pembayaranb1"] != 0 || resultObject[7]["pembayaranb2"] !=0 || resultObject[7]["pembayaranb3"] !=0 || 
                                            resultObject[7]["pembayaranb4"] !=0
                                            ?
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
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                          child: TextView("Rentang BB 2 (${resultObject[3]["top_cat"]+1} - 70)", 3, color: Colors.black),
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
                                                          child: TextView("Rentang BB 4 (> 90)", 3, color: Colors.black),
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
                                              child: Image.asset("assets/illustration/pipe.png", alignment: Alignment.center, fit: BoxFit.contain, height: 50),
                                              ),
                                            ),
                                        ),
                                          elevation: 3,
                                          shadowColor: config.grayNonActiveColor,
                                          margin: EdgeInsets.all(20),
                                          shape: CircleBorder(side: BorderSide(width: 1, color: Colors.white),
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
                                          onTap: (){
                                            resultObject[6]["pembayaranm1"] != 0 || resultObject[6]["pembayaranm2"] !=0 || resultObject[6]["pembayaranm3"] !=0 || 
                                            resultObject[6]["pembayaranm4"] !=0
                                            ?
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
                                                          child: TextView("Rentang Mebel 2 (${resultObject[5]["top_mebel"]+1} - 70)", 3, color: Colors.black),
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
                                              child: Image.asset("assets/illustration/furniture.png", alignment: Alignment.center, fit: BoxFit.contain, height:50),
                                              ),
                                            ),
                                        ),
                                          elevation: 3,
                                          shadowColor: config.grayNonActiveColor,
                                          margin: EdgeInsets.all(20),
                                          shape: CircleBorder(side: BorderSide(width: 1, color: Colors.white),
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
                                          onTap: (){
                                            resultObject[12].length != 0
                                            ?
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
                                              child: Image.asset("assets/illustration/varnish.png", alignment: Alignment.center, fit: BoxFit.contain, height:50),
                                              ),
                                            ),
                                        ),
                                          elevation: 3,
                                          shadowColor: config.grayNonActiveColor,
                                          margin: EdgeInsets.all(20),
                                          shape: CircleBorder(side: BorderSide(width: 1, color: Colors.white),
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
                                              onTap: (){
                                                resultObject[13].length != 0 ?
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
                                                  child: Image.asset("assets/illustration/pipe.png", alignment: Alignment.center, fit: BoxFit.contain, height: 50),
                                                  ),
                                                ),
                                            ),
                                              elevation: 3,
                                              shadowColor: config.grayNonActiveColor,
                                              margin: EdgeInsets.all(20),
                                              shape: CircleBorder(side: BorderSide(width: 1, color: Colors.white),
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
                                          onTap: (){
                                            resultObject[14].length != 0
                                            ?
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
                                              child: Image.asset("assets/illustration/furniture.png", alignment: Alignment.center, fit: BoxFit.contain, height:50),
                                              ),
                                            ),
                                        ),
                                          elevation: 3,
                                          shadowColor: config.grayNonActiveColor,
                                          margin: EdgeInsets.all(20),
                                          shape: CircleBorder(side: BorderSide(width: 1, color: Colors.white),
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
                          child: TextView("Omzet", 1, color: config.blueColor),
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
                                          onTap: (){
                                            resultObject[15][0].length != 0
                                            ?
                                            showAvatarModalBottomSheet(
                                              expand: true,
                                              context: context,
                                              backgroundColor: Colors.transparent,
                                              builder: (context) => ModalWithPageView(
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
                                              child: Image.asset("assets/illustration/varnish.png", alignment: Alignment.center, fit: BoxFit.contain, height:50),
                                              ),
                                            ),
                                        ),
                                          elevation: 3,
                                          shadowColor: config.grayNonActiveColor,
                                          margin: EdgeInsets.all(20),
                                          shape: CircleBorder(side: BorderSide(width: 1, color: Colors.white),
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
                                          onTap: (){
                                            resultObject[16][0].length != 0
                                            ?
                                            showAvatarModalBottomSheet(
                                              expand: true,
                                              context: context,
                                              backgroundColor: Colors.transparent,
                                              builder: (context) => ModalWithPageView(
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
                                              child: Image.asset("assets/illustration/pipe.png", alignment: Alignment.center, fit: BoxFit.contain, height: 50),
                                              ),
                                            ),
                                        ),
                                          elevation: 3,
                                          shadowColor: config.grayNonActiveColor,
                                          margin: EdgeInsets.all(20),
                                          shape: CircleBorder(side: BorderSide(width: 1, color: Colors.white),
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
                                          onTap: (){
                                            resultObject[17][0].length != 0
                                            ?
                                            showAvatarModalBottomSheet(
                                              expand: true,
                                              context: context,
                                              backgroundColor: Colors.transparent,
                                              builder: (context) => ModalWithPageView(
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
                                              child: Image.asset("assets/illustration/furniture.png", alignment: Alignment.center, fit: BoxFit.contain, height:50),
                                              ),
                                            ),
                                        ),
                                          elevation: 3,
                                          shadowColor: config.grayNonActiveColor,
                                          margin: EdgeInsets.all(20),
                                          shape: CircleBorder(side: BorderSide(width: 1, color: Colors.white),
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
                    )
                  ),
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
          )  
        ),
      );



    }  else {
      //hoi
      return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: pageType == 1 || pageType == 4 ?
          TextView("Limit Yang Diminta", 1)
          :
          pageType == 2 || pageType == 5 ?
          TextView("Limit Yang Disetujui", 1)
          :
          TextView("Limit Yang Ditolak", 1),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
          child: Form(
            key: _HistoryLimitFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: isLimitRequestApprovalExist,
                  child: Card(
                    color: config.lightOpactityBlueColor,
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    elevation: 3,
                    child: ListTile(
                      leading: Icon(Icons.notifications, color:config.darkOpacityBlueColor),
                      title: Container(
                        child: TextView(limitRequestApprovalMessage, 3, color: config.darkOpacityBlueColor),
                      ),
                    ),
                  ),
                ),
                Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: TextFormField(
                  enabled: false,
                  decoration: new InputDecoration(
                    hintStyle: TextStyle(
                      color: Colors.black
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Kode Corporate",
                    hintText: resultObject[0]["corporate_code"],
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
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: TextFormField(
                  enabled: false,
                  decoration: new InputDecoration(
                    hintStyle: TextStyle(
                      color: Colors.black
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Nama Corporate",
                    hintText: resultObject[0]["corporate_name"],
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
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: TextFormField(
                  enabled: false,
                  decoration: new InputDecoration(
                    hintStyle: TextStyle(
                      color: Colors.black
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Induk Pelanggan",
                    hintText: resultObject[0]["head_customer"],
                    icon: Icon(Icons.group, color: config.grayColor),
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
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: TextFormField(
                  enabled: false,
                  decoration: new InputDecoration(
                    hintStyle: TextStyle(
                      color: Colors.black
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Limit Saat Ini",
                    hintText: currencyFormatter.format(int.parse(resultObject[0]["old_limit"])),
                    icon: TextView("Rp ", 4, color: config.grayColor),
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
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: TextFormField(
                  style: TextStyle(color: Colors.black),
                  inputFormatters: <TextInputFormatter>[
                    CurrencyTextInputFormatter(
                      locale: 'IDR',
                      decimalDigits: 0,
                      symbol: '',
                    ),
                  ],
                  keyboardType: TextInputType.number,
                  enabled: false,
                  controller: limitRequestController,
                  decoration: new InputDecoration(
                    hintStyle: TextStyle(
                      color: Colors.black
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Limit Yang Diajukan",
                    icon: TextView("Rp ", 4, color: config.grayColor),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(5.0,),
                        borderSide: BorderSide(color: config.grayColor, width: 1.5,),
                    ),
                  ),
                ),
              ),
              (pageType == 1 || pageType == 4) && isNeedApproval && user_code_request.toLowerCase() != user_login.toLowerCase() ?
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        child: Button(
                          key: Key("submit"),
                          loading: acceptLimitRequestLoading,
                          backgroundColor: isLimitRequestApprovalExist ? config.grayNonActiveColor : config.darkOpacityBlueColor,
                          child: user_login.toLowerCase().contains("dsd") && user_code_request.toLowerCase().contains("kc") && int.parse(limitRequestController.text.replaceAll(new RegExp('\\.'),'')) > 1500000000 ? TextView("acc (sales director)", 3, caps: true, align: TextAlign.center) : TextView("terima", 3, caps: true, align: TextAlign.center),
                          onTap: () {
                            if(!isLimitRequestApprovalExist) {
                              user_login.toLowerCase().contains("dsd") && user_code_request.toLowerCase().contains("kc") && int.parse(limitRequestController.text.replaceAll(new RegExp('\\.'),'')) > 1500000000 ?
                              updateLimitGabunganRequest(-1)
                              :
                              updateLimitGabunganRequest(1);
                            }
                          },
                        ),
                      ),
                    ),
              
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        child: Button(
                          key: Key("submit"),
                          loading: rejectLimitRequestLoading,
                          backgroundColor: isLimitRequestApprovalExist ? config.grayNonActiveColor : config.darkOpacityBlueColor,
                          child: TextView(
                            "tolak",
                            3,
                            caps: true,
                            align: TextAlign.center,
                          ),
                          onTap: () {
                            if(!isLimitRequestApprovalExist) {
                              updateLimitGabunganRequest(0);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )
              :
              Container(),
              ],
            ),
          ),
        ),
      );
    }

    
  }

  showChangeLimit(Configuration config) {
    List<Widget> tempWidgetList = [];

    final currencyFormatter = NumberFormat('#,##0', 'ID');

    if(result != null){
      final resultObject = jsonDecode(result.data.toString());

      var blockedType = resultObject[0]["blocked"];
      var blockedTypeSelected;

      if(blockedType == 3) {
        blockedTypeSelected = "Blocked All";
      } else if(blockedType == 2) {
        blockedTypeSelected = "Blocked Invoice";
      } else if(blockedType == 1) {
        blockedTypeSelected = "Blocked Ship";
      } else {
        blockedTypeSelected = "Not Blocked";
      }

      tempWidgetList.add(
        Container(
          child: Form(
            key: _AddLimitFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Visibility(
                  visible: isLimitRequestApprovalExist,
                  child: Card(
                    color: config.lightOpactityBlueColor,
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    elevation: 3,
                    child: ListTile(
                      leading: Icon(Icons.notifications, color:config.darkOpacityBlueColor),
                      title: Container(
                        child: TextView(limitRequestApprovalMessage, 3, color: config.darkOpacityBlueColor),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                  child: TextFormField(
                    enabled: false,
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Kode Pelanggan",
                      hintText: resultObject[0]["No_"],
                      icon: Icon(Icons.bookmark, color: config.grayColor),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: config.grayColor, width: 1.5,),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: TextFormField(
                    enabled: false,
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Nama Pelanggan",
                      hintText: resultObject[0]["Name"],
                      icon: Icon(Icons.person, color: config.grayColor),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: config.grayColor, width: 1.5,),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: TextFormField(
                    enabled: false,
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Alamat Pelanggan",
                      hintText: resultObject[0]["Address"],
                      icon: Icon(Icons.location_on, color: config.grayColor),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: config.grayColor, width: 1.5,),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: TextFormField(
                    enabled: false,
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Status",
                      hintText: resultObject[0]["disc"] + " | " +blockedTypeSelected,
                      icon: Icon(Icons.list_alt, color: config.grayColor),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: config.grayColor, width: 1.5,),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: TextFormField(
                    enabled: false,
                    controller: limitDMDController,
                    style: TextStyle(color: Colors.black),
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Limit DSD",
                      // hintText: resultObject[0]["limit_dmd"].toString(),
                      icon: TextView("Rp ",5,color: config.grayColor),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: config.grayColor, width: 1.5,),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: TextFormField(
                    enabled: false,
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Limit Saat Ini",
                      hintText: currencyFormatter.format(int.parse(resultObject[0]["Limit"])),
                      icon: TextView("Rp ",5,color:config.grayColor),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: config.grayColor, width: 1.5,),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: TextFormField(
                    enabled: false,
                    controller: limitRequestController,
                    style: TextStyle(color: Colors.black),
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Limit Yang Diajukan",
                      icon: TextView("Rp ",5,color: config.grayColor),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: config.grayColor, width: 1.5,),
                      )
                    ),
                  ),
                ),
                (pageType == 1 || pageType == 4) && isNeedApproval && user_code_request.toLowerCase() != user_login.toLowerCase() ?
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                          child: Button(
                            key: Key("submit"),
                            loading: acceptLimitRequestLoading,
                            backgroundColor: isLimitRequestApprovalExist ? config.grayNonActiveColor : config.darkOpacityBlueColor,
                            child: user_login.toLowerCase().contains("dsd") && user_code_request.toLowerCase().contains("kc") && int.parse(limitRequestController.text.replaceAll(new RegExp('\\.'),'')) > 1500000000 ? TextView("acc (sales director)", 3, caps: true, align: TextAlign.center) : TextView("terima", 3, caps: true, align: TextAlign.center),
                            onTap: () {
                              if(!isLimitRequestApprovalExist) {
                                user_login.toLowerCase().contains("dsd") && user_code_request.toLowerCase().contains("kc") && int.parse(limitRequestController.text.replaceAll(new RegExp('\\.'),'')) > 1500000000 ?
                                updateLimitRequest(-1)
                                :
                                updateLimitRequest(1);
                              }
                            },
                          ),
                        ),
                      ),
                
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                          child: Button(
                            key: Key("submit"),
                            loading: rejectLimitRequestLoading,
                            backgroundColor: isLimitRequestApprovalExist ? config.grayNonActiveColor : config.darkOpacityBlueColor,
                            child: TextView(
                              "tolak",
                              3,
                              caps: true,
                              align: TextAlign.center
                            ),
                            onTap: () {
                              if(!isLimitRequestApprovalExist) {
                                updateLimitRequest(0);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                :
                Container(),
              ],
            ),
          ),
        )
      );

    }
    
    return tempWidgetList;

  }

  void updateLimitGabunganRequest(int command) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //var obj = {"kode_customer": row_pending[i].customer_code, "limit_baru": row_pending[i].limit, "user_code": row_pending[i].user_code, "id": row_pending[i].id};
    //var obj = {"kode_customer": row_pending[i].customer_code, "limit_baru": row_pending[i].limit, "user_code": row_pending[i].user_code, "id": row_pending[i].id, "old_limit": localStorage

    Alert(
      context: context,
      title: "Konfirmasi,",
      content: command == 1 ? Text("Apakah Anda yakin ingin menyetujui permintaan limit ini?") : command == 0 ? Text("Apakah Anda yakin ingin menolak permintaan limit ini?") : Text("Apakah Anda yakin ingin mengajukan ACC permintaan limit ini ke Sales Director?"),
      cancel: true,
      type: "warning",
      defaultAction: (){
        command == 1 ? changeLimitRequestGabungan(1) : command == 0 ? changeLimitRequestGabungan(0) : addRequestLimitCorporate();
      }
    );
  }

  void changeLimitRequestGabungan(int command) async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      command == 1 ? acceptLimitRequestLoading = true : rejectLimitRequestLoading = true;
    });

    Alert(context: context, loading: true, disableBackButton: true);


    String getChangeLimit = "";

    if(command == 1) {
      getChangeLimit = await customerAPI.updateLimitGabunganRequest(context, command: command, parameter: 'json={"kode_customer":"${resultObject[0]['corporate_code']}","user_code":"$user_code_request","limit_baru":"${limitRequestController.text.replaceAll(new RegExp('\\.'),'')}","old_limit":"${resultObject[0]["old_limit"]}","user_login":"$user_code","id":"${widget.id}"}');
    } else {
      getChangeLimit = await customerAPI.updateLimitGabunganRequest(context, command: command, parameter: 'json={"kode_customer":"${resultObject[0]['corporate_code']}","user_code":"$user_code_request","id":"${widget.id}"}');
    }

    Navigator.of(context).pop();

    if(command == 1 ) {
      if(getChangeLimit == "OK"){
        Alert(
          context: context,
          title: "Terima kasih,",
          content: Text("Ubah limit sukses"),
          cancel: false,
          type: "success",
          defaultAction: () {
            if(notificationType == 0) {
              Navigator.pop(context);  
            } else {
              Navigator.pop(context);
              Navigator.popAndPushNamed(
                context,
                "dashboard/1"
              );
            }
          }
        );
      } else {
        Alert(
          context: context,
          title: "Info,",
          content: Text(getChangeLimit),
          cancel: false,
          type: "warning"
        );
      }
    } else {
      if(getChangeLimit == "OK"){
        Alert(
          context: context,
          title: "Terima kasih,",
          content: Text("Limit tidak diubah"),
          cancel: false,
          type: "success",
          defaultAction: () {
            if(notificationType == 0) {
              Navigator.pop(context);  
            } else {
              Navigator.pop(context);
              Navigator.popAndPushNamed(
                context,
                "dashboard/1"
              );
            }
          }
        );
      }
    }

    setState(() {
      command == 1 ? acceptLimitRequestLoading = false : rejectLimitRequestLoading = false;
    });

  }

  void updateLimitRequest(int command) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //var obj = {"kode_customer": row_pending[i].customer_code, "limit_baru": row_pending[i].limit, "user_code": row_pending[i].user_code, "id": row_pending[i].id};

    Alert(
      context: context,
      title: "Konfirmasi,",
      content: command == 1 ? Text("Apakah Anda yakin ingin menyetujui permintaan limit ini?") : command == 0 ? Text("Apakah Anda yakin ingin menolak permintaan limit ini?") : Text("Apakah Anda yakin ingin mengajukan ACC permintaan limit ini ke Sales Director?"),
      cancel: true,
      type: "warning",
      defaultAction: (){
        command == 1 ? changeLimitRequest(1) : command == 0 ? changeLimitRequest(0) : addRequestLimit();
      }
    );
  }

  void addRequestLimit() async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      acceptLimitRequestLoading = true;
    });

    Alert(context: context, loading: true, disableBackButton: true);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String getRequestLimit = await customerAPI.addRequestLimit(context, parameter: 'json={"kode_customer":"${resultObject[0]['No_']}","user_code":"${prefs.getString('user_code')}","nama_cust":"${resultObject[0]['Name']}","id_approval":"${widget.id.toString()}","limit_baru":"${limitRequestController.text.replaceAll(new RegExp('\\.'),'')}","limit_dmd_baru":"${limitDMDController.text.replaceAll(new RegExp('\\.'),'')}"}');

    Navigator.of(context).pop();

    if (getRequestLimit == "OK") {
      Alert(
          context: context,
          title: "Terima kasih,",
          content: Text("Permintaan sudah dikirim"),
          cancel: false,
          type: "success",
          defaultAction: () {
            if(notificationType == 0) {
              Navigator.pop(context);  
            } else {
              Navigator.pop(context);
              Navigator.popAndPushNamed(
                context,
                "dashboard/1"
              );
            }
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
      acceptLimitRequestLoading = false;
    });
  }

  void addRequestLimitCorporate() async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      acceptLimitRequestLoading = true;
    });

    Alert(context: context, loading: true, disableBackButton: true);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    //var obj = {"kode_customerc": $$('#corporate_code').val(),"corporate_name":$$('#corporate_name').val(), "limit_baru": limit_baru.replace(/\./g,''), "user_code": localStorage.getItem('user_code'), "old_limit": localStorage.getItem('old_limitc')};

    String getRequestLimit = await customerAPI.addRequestLimitGabungan(context, parameter: 'json={"kode_customerc":"${resultObject[0]['corporate_code']}","user_code":"${prefs.getString('user_code')}","corporate_name":"${resultObject[0]['corporate_name']}","old_limit":"${resultObject[0]['old_limit']}","limit_baru":"${limitRequestController.text.replaceAll(new RegExp('\\.'),'')}"}');

    Navigator.of(context).pop();

    if(getRequestLimit == "OK"){
      Alert(
        context: context,
        title: "Terima kasih,",
        content: Text("Permintaan sudah dikirim"),
        cancel: false,
        type: "success",
        defaultAction: () {
          if(notificationType == 0) {
            Navigator.pop(context);  
          } else {
            Navigator.pop(context);
            Navigator.popAndPushNamed(
              context,
              "dashboard/1"
            );
          }
        }
      );
    } else {
      Alert(
        context: context,
        title: "Maaf,",
        content: Text(getRequestLimit),
        cancel: false,
        type: "error"
      );
    }

    setState(() {
      acceptLimitRequestLoading = false;
    });



  }



  void changeLimitRequest(int command) async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      command == 1 ? acceptLimitRequestLoading = true : rejectLimitRequestLoading = true;
    });

    Alert(context: context, loading: true, disableBackButton: true);

    String getChangeLimit = "";

    // printHelp("cek params kode customer "+resultObject[0]['No_']);
    // printHelp("cek params user_code "+user_code_request);
    // printHelp("cek params limit_baru "+limitRequestController.text.replaceAll(new RegExp('\\.'),''));
    // printHelp("cek params limit_dmd_baru "+limitDMDController.text.replaceAll(new RegExp('\\.'),''));
    // printHelp("cek params user_login "+user_login);
    // printHelp("cek params id "+widget.id.toString());

    if(command == 1) {
      getChangeLimit = await customerAPI.updateLimitRequest(context, command: command, parameter: 'json={"kode_customer":"${resultObject[0]['No_']}","user_code":"$user_code_request","limit_baru":"${limitRequestController.text.replaceAll(new RegExp('\\.'),'')}","limit_dmd_baru":"${limitDMDController.text.replaceAll(new RegExp('\\.'),'')}","user_login":"$user_code","id":"${widget.id}"}');
    } else {
      getChangeLimit = await customerAPI.updateLimitRequest(context, command: command, parameter: 'json={"kode_customer":"${resultObject[0]['No_']}","user_code":"$user_code_request","id":"${widget.id}"}');
    }

    Navigator.of(context).pop();

    if(command == 1 ) {
      if(getChangeLimit == "OK"){
        Alert(
          context: context,
          title: "Terima kasih,",
          content: Text("Ubah limit sukses"),
          cancel: false,
          type: "success",
          defaultAction: () {
            if(notificationType == 0) {
              Navigator.pop(context);  
            } else {
              Navigator.pop(context);
              Navigator.popAndPushNamed(
                context,
                "dashboard/1"
              );
            }
          }
        );
      } else {
        Alert(
          context: context,
          title: "Info,",
          content: Text(getChangeLimit),
          cancel: false,
          type: "warning"
        );
      }
    } else {
      if(getChangeLimit == "OK"){
        Alert(
          context: context,
          title: "Terima kasih,",
          content: Text("Limit tidak diubah"),
          cancel: false,
          type: "success",
          defaultAction: () {
            if(notificationType == 0) {
              Navigator.pop(context);  
            } else {
              Navigator.pop(context);
              Navigator.popAndPushNamed(
                context,
                "dashboard/1"
              );
            }
          }
        );
      }
    }

    

    setState(() {
      command == 1 ? acceptLimitRequestLoading = false : rejectLimitRequestLoading = false;
    });

  }

  // RefreshController _refreshRequestController =
  //     RefreshController(initialRefresh: false);

  // void _onHistoryRefresh() async{
  //   setState(() {
  //     checkModulePrivilegeLoading = true;
  //     getLimitRequestApprovalStatusLoading = true;
  //   });

  //   if(checkModulePrivilegeLoading){
  //     checkModulePrivilege();
  //   }

  //   if(getLimitRequestApprovalStatusLoading){
  //     getLimitRequestApprovalStatus();
  //   }

  //   refreshHistoryLimitDetail()
  // }

  // Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();
  // void refreshHistoryLimitDetail(LimitHistory tempLimitHistory, int type) async {
  //   Result result_;

  //   if(tempLimitHistory.customer_code.length > 11) {
  //     Alert(context: context, loading: true, disableBackButton: true);

  //     result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"${tempLimitHistory.customer_code}","user_code":"$user_login"}');

  //     final SharedPreferences sharedPreferences = await _sharedPreferences;
  //     await sharedPreferences.setInt("request_limit", int.parse(tempLimitHistory.limit));
  //     await sharedPreferences.setString("user_code_request", tempLimitHistory.user_code);

  //     Navigator.of(context).pop();

  //     if(result_.success == 1) {
  //       if(type == 1) {
  //         Navigator.pushNamed(
  //           context,
  //           "historyLimitRequestDetail/${tempLimitHistory.id}/4",
  //           arguments: result_,
  //         );
  //       } else if(type == 2) {
  //         Navigator.pushNamed(
  //           context,
  //           "historyLimitRequestDetail/${tempLimitHistory.id}/5",
  //           arguments: result_,
  //         );
  //       } else {
  //         Navigator.pushNamed(
  //           context,
  //           "historyLimitRequestDetail/${tempLimitHistory.id}/6",
  //           arguments: result_,
  //         );
  //       }
  //     } else {
  //       Alert(
  //         context: context,
  //         title: "Maaf,",
  //         content: Text(result_.message),
  //         cancel: false,
  //         type: "error",
  //         defaultAction: () {}
  //       );
  //     }

  //   } else {
  //     result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"${tempLimitHistory.customer_code}","user_code":"$user_login"}');

  //     final SharedPreferences sharedPreferences = await _sharedPreferences;
  //     await sharedPreferences.setInt("request_limit", int.parse(tempLimitHistory.limit));
  //     try {
  //       await sharedPreferences.setInt("request_limit_dmd", int.parse(tempLimitHistory.limit_dmd));
  //     } catch(e) {

  //     }
  //     await sharedPreferences.setString("user_code_request", tempLimitHistory.user_code);

  //     setState(() {
  //       result = result_;
  //       pageType = type;
  //       historyLimitId = tempLimitHistory.id;
  //     });
  //   }
  // }

}