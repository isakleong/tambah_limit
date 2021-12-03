import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';
import 'package:tambah_limit/widgets/TextView.dart';
import 'package:tambah_limit/widgets/button.dart';

class AddLimitDetail extends StatefulWidget {
  final Result model;

  AddLimitDetail({Key key, this.model}) : super(key: key);

  @override
  AddLimitDetailState createState() => AddLimitDetailState();
}


class AddLimitDetailState extends State<AddLimitDetail> {
  Result result;

  final _AddLimitFormKey = GlobalKey<FormState>();
  final limitDMD = TextEditingController();
  final limitRequest = TextEditingController();

  @override
  void initState() {
    super.initState();
    result = widget.model;
  }


  @override
  Widget build(BuildContext context) {

    List<Widget> changeLimitWidgetList = showChangeLimit(config);
    List<Widget> informationDetailWidgetList = showInformationDetail(config);

    final resultObject = jsonDecode(result.data.toString());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        // appBar: AppBar(
        //   title: TextView("Tambah Limit", 1),
        //   leading: IconButton(
        //     icon: Icon(Icons.arrow_back, color: Colors.white),
        //     onPressed: () => Navigator.popAndPushNamed(context, "dashboard"),
        //   ),
        //   bottom: 
        // ),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
               new SliverAppBar(
                 title: Text('Tambah Limit'),
                 pinned: true,
                 floating: true,
                 bottom: TabBar(
                   indicatorColor: Colors.amber,
                   indicatorWeight: 3,
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
                  padding: EdgeInsets.symmetric(vertical:15, horizontal:25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: TextView("Ketepatan Waktu Pembayaran", 1, color: config.blueColor),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical:20, horizontal:0),
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
                                        Alert(
                                          context: context,
                                          title: "Rentang Pembayaran",
                                          content: Text(resultObject[1]["pembayaranc1"].toString()),
                                          cancel: false,
                                          type: "warning",
                                          defaultAction: () {
                                          }
                                        );
                                      },
                                      child: Container(
                                        height: 80,
                                        width: 80,
                                        child: Center(
                                          child: Image.asset("assets/illustration/varnish.png", alignment: Alignment.center, fit: BoxFit.contain),
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
                                    child: Container(
                                      height: 80,
                                      width: 80,
                                      child: Center(
                                        child: Image.asset("assets/illustration/pipe.png", alignment: Alignment.center, fit: BoxFit.contain),
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
                                    child: Container(
                                      height: 80,
                                      width: 80,
                                      child: Center(
                                        child: Image.asset("assets/illustration/logo.png", alignment: Alignment.center, fit: BoxFit.contain),
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
              
                      Divider(
                        height: 60,
                        thickness: 4,
                        color: config.lighterGrayColor,
                      ),
              
                      Container(
                        child: TextView("Faktur Terdekat Jatuh Tempo", 1, color: config.blueColor),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical:5, horizontal:0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              child: Column(
                                children: [
                                  Card(
                                    child: Container(
                                      height: 80,
                                      width: 80,
                                      child: Center(
                                        child: Image.asset("assets/illustration/logo.png", alignment: Alignment.center, fit: BoxFit.contain),
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
                                  Text("Bahan Bangunan"),
                                  Row(
                                    children: [
                                      Card(
                                        child: Container(
                                          height: 80,
                                          width: 80,
                                          child: Center(
                                            child: Image.asset("assets/illustration/logo.png", alignment: Alignment.center, fit: BoxFit.contain),
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
                                ],
                              ),
                            ),
                            Container(
                              child: Column(
                                children: [
                                  Card(
                                    child: Container(
                                      height: 80,
                                      width: 80,
                                      child: Center(
                                        child: Image.asset("assets/illustration/logo.png", alignment: Alignment.center, fit: BoxFit.contain),
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
              
                      Divider(
                        height: 60,
                        thickness: 4,
                        color: config.lighterGrayColor,
                      ),
              
                      Container(
                        child: TextView("Omzet", 1, color: config.blueColor),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical:5, horizontal:0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              child: Column(
                                children: [
                                  Card(
                                    child: Container(
                                      height: 80,
                                      width: 80,
                                      child: Center(
                                        child: Image.asset("assets/illustration/logo.png", alignment: Alignment.center, fit: BoxFit.contain),
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
                                    child: Container(
                                      height: 80,
                                      width: 80,
                                      child: Center(
                                        child: Image.asset("assets/illustration/logo.png", alignment: Alignment.center, fit: BoxFit.contain),
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
                                    child: Container(
                                      height: 80,
                                      width: 80,
                                      child: Center(
                                        child: Image.asset("assets/illustration/logo.png", alignment: Alignment.center, fit: BoxFit.contain),
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
    
  }

  showChangeLimit(Configuration config) {
    List<Widget> tempWidgetList = [];

    if(result != null){
      final resultObject = jsonDecode(result.data.toString());

      var blockedType = resultObject[0]["blocked"];
      var blockedTypeSelected;
      // blockedType == 3 ? blockedTypeSelected = "Blocked All" : blockedType == 0 ? blockedTypeSelected = "Not Blocked" : blockedType == 1 ? blockedTypeSelected = "Blocked Ship" : blockedType == 2 ? "Blocked Invoice" : ""; //kalau diunblock value awal bisa muncul, namun waktu onchange radio, value gk keganti. kalau diblock, running awal, value ndk muncul
      if(blockedType == 3) {
        blockedTypeSelected = "Blocked All";
      } else if(blockedType == 2) {
        blockedTypeSelected = "Blocked Invoice";
      } else if(blockedType == 1) {
        blockedTypeSelected = "Blocked Ship";
      } else {
        blockedTypeSelected = "Not Blocked";
      }

      final _newValue = resultObject[0]["limit_dmd"].toString();
      limitDMD.value = TextEditingValue(
            text: _newValue,
            selection: TextSelection.fromPosition(
              TextPosition(offset: _newValue.length),
            ),
          );

      tempWidgetList.add(
        Container(
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
                      hintStyle: TextStyle(
                        color: config.grayNonActiveColor
                      ),
                      labelStyle: TextStyle(
                        color: config.grayNonActiveColor
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Kode Pelanggan",
                      hintText: resultObject[0]["No_"],
                      icon: Icon(Icons.bookmark),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: config.grayNonActiveColor, width: 1.5,),
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
                        color: config.grayNonActiveColor
                      ),
                      labelStyle: TextStyle(
                        color: config.grayNonActiveColor
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Nama Pelanggan",
                      hintText: resultObject[0]["Name"],
                      icon: Icon(Icons.people),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: config.grayNonActiveColor, width: 1.5,),
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
                        color: config.grayNonActiveColor
                      ),
                      labelStyle: TextStyle(
                        color: config.grayNonActiveColor
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Alamat Pelanggan",
                      hintText: resultObject[0]["Address"],
                      icon: Icon(Icons.location_on),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: config.grayNonActiveColor, width: 1.5,),
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
                        color: config.grayNonActiveColor
                      ),
                      labelStyle: TextStyle(
                        color: config.grayNonActiveColor
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Status",
                      hintText: resultObject[0]["disc"] + " | " +blockedTypeSelected,
                      icon: Icon(Icons.list_alt),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: config.grayNonActiveColor, width: 1.5,),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: TextFormField(
                    enabled: true,
                    controller: limitDMD,
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Limit DMD",
                      // hintText: resultObject[0]["limit_dmd"].toString(),
                      icon: TextView("Rp ",5),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: Colors.black54, width: 1.5,),
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
                        color: config.grayNonActiveColor
                      ),
                      labelStyle: TextStyle(
                        color: config.grayNonActiveColor
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Limit Saat Ini",
                      hintText: resultObject[0]["Limit"].toString(),
                      icon: TextView("Rp ",5,color:config.grayNonActiveColor),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: config.grayNonActiveColor, width: 1.5,),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: TextFormField(
                    enabled: true,
                    controller: limitRequest,
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(
                        color: Colors.black
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Limit Yang Diajukan",
                      hintText: "0",
                      icon: TextView("Rp ",5),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: Colors.black54, width: 1.5,),
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
                      backgroundColor: config.darkOpacityBlueColor,
                      child: TextView("UBAH", 3, caps: true,),
                      onTap: (){
                        // blockedType != resultObject[0]["blocked"]
                        // ?
                        // Alert(
                        //   context: context,
                        //   title: "Alert",
                        //   content: Text("Apakah Anda yakin ingin menyimpan data?"),
                        //   cancel: true,
                        //   type: "warning",
                        //   defaultAction: () {
                        //     // updateBlock();
                        //   }
                        // )
                        // :
                        // Alert(
                        //   context: context,
                        //   title: "Alert",
                        //   content: Text("Mohon untuk melakukan perubahan data terlebih dahulu"),
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
        )
      );

    }
    
    return tempWidgetList;

  }

  showInformationDetail(Configuration config) {

  }

}