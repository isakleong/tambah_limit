import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';
import 'package:tambah_limit/widgets/TextView.dart';
import 'package:tambah_limit/widgets/button.dart';

class AddLimitCorporateDetail extends StatefulWidget {
  final Result model;

  AddLimitCorporateDetail({Key key, this.model}) : super(key: key);

  @override
  AddLimitCorporateDetailState createState() => AddLimitCorporateDetailState();
}

class AddLimitCorporateDetailState extends State<AddLimitCorporateDetail> {
  Result result;
  var resultObject;

  final limitRequestController = TextEditingController();

  @override
  void initState() {
    super.initState();

    result = widget.model;
    final _resultObject = jsonDecode(result.data.toString());
    setState(() {
      resultObject = _resultObject;
    });
  }

  final _ChangeBlockedStatusFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    List<Widget> addLimitCorporateDetailList = showAddLimitCorporateDetail(config);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: TextView("Tambah Limit Corporate Detail", 3),
      ),
      body: addLimitCorporateDetailList.length == 0
      ? 
      Container()
      :
      ListView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 5),
        physics: ScrollPhysics(),
        shrinkWrap: true,
        children: addLimitCorporateDetailList,
      ),
    );
  }

  showAddLimitCorporateDetail(Configuration config) {
    List<Widget> tempWidgetList = [];

    final currencyFormatter = NumberFormat('#,##0', 'ID');

    if (result != null) {
      final resultObject = jsonDecode(result.data.toString());
      var blockedType;

      tempWidgetList.add(
        Container(
          child: Form(
            key: _ChangeBlockedStatusFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: TextFormField(
                    enabled: false,
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(color: config.grayNonActiveColor),
                      labelStyle: TextStyle(color: config.grayNonActiveColor),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Kode Corporate",
                      hintText: resultObject[0]["corporate_code"],
                      icon: Icon(Icons.bookmark),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(
                          5.0,
                        ),
                        borderSide: BorderSide(
                          color: config.grayNonActiveColor,
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
                      hintStyle: TextStyle(color: config.grayNonActiveColor),
                      labelStyle: TextStyle(color: config.grayNonActiveColor),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Nama Corporate",
                      hintText: resultObject[0]["corporate_name"],
                      icon: Icon(Icons.person),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(
                          5.0,
                        ),
                        borderSide: BorderSide(
                          color: config.grayNonActiveColor,
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
                      hintStyle: TextStyle(color: config.grayNonActiveColor),
                      labelStyle: TextStyle(color: config.grayNonActiveColor),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Induk Pelanggan",
                      hintText: resultObject[0]["head_customer"],
                      icon: Icon(Icons.group),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(
                          5.0,
                        ),
                        borderSide: BorderSide(
                          color: config.grayNonActiveColor,
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
                      hintStyle: TextStyle(color: config.grayNonActiveColor),
                      labelStyle: TextStyle(color: config.grayNonActiveColor),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Limit Saat Ini",
                      hintText: currencyFormatter.format(int.parse(resultObject[0]["old_limit"])),
                      icon: Icon(Icons.money),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(
                          5.0,
                        ),
                        borderSide: BorderSide(
                          color: config.grayNonActiveColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: TextFormField(
                    enabled: true,
                    controller: limitRequestController,
                    decoration: new InputDecoration(
                      hintStyle: TextStyle(color: config.grayColor),
                      labelStyle: TextStyle(color: config.grayColor),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Limit Yang Diajukan",
                      icon: Icon(Icons.money, color: config.grayColor),
                      enabledBorder: OutlineInputBorder(
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
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: Button(
                      key: Key("submit"),
                      backgroundColor: config.darkOpacityBlueColor,
                      child: TextView(
                        "UBAH",
                        3,
                        caps: true,
                      ),
                      onTap: () {
                        updateLimit();
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

  void updateLimit() async {

    if(limitRequestController.text.isEmpty){
      Alert(
        context: context,
        title: "Alert",
        content: Text(
            "Kode Customer Gabungan tidak boleh kosong"),
        cancel: false,
        type: "warning",
      );
    } else {
      if(result.data == null){
        Alert(
          context: context,
          title: "Alert",
          content: Text(result.message),
          cancel: true,
          type: "warning",
          defaultAction: () {
            // updateBlock();
          }
        );
      } else {

        if(limitRequestController.text != resultObject[0]["old_limit"]) {
          Alert(
            context: context,
            title: "Alert",
            content: Text(
                "Apakah Anda yakin ingin menyimpan data?"),
            cancel: true,
            type: "warning",
            defaultAction: () {
              // updateBlock();
            }
          );
        } else {
          Alert(
            context: context,
            title: "Alert",
            content: Text(
                "Mohon untuk melakukan perubahan data terlebih dahulu"),
            cancel: false,
            type: "warning");
        }


      }
    }

    

  }



}
