import 'dart:convert';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/resources/customerAPI.dart';
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

  bool changeLimitLoading = false;

  final limitRequestController = TextEditingController();

  final currencyFormatter = NumberFormat('#,##0', 'ID');

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
                      hintStyle: TextStyle(color: Colors.black),
                      labelStyle: TextStyle(color: Colors.black),
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
                      hintStyle: TextStyle(color: Colors.black),
                      labelStyle: TextStyle(color: Colors.black),
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
                      hintStyle: TextStyle(color: Colors.black),
                      labelStyle: TextStyle(color: Colors.black),
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
                      hintStyle: TextStyle(color: Colors.black),
                      labelStyle: TextStyle(color: Colors.black),
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
                      icon: TextView("Rp ", 4, color: config.grayColor),
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
                      loading: changeLimitLoading,
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
        title: "Info,",
        content: Text(
            "Limit Baru harus diisi"),
        cancel: false,
        type: "warning",
      );
    } else {
      if(result.data == null){
        Alert(
          context: context,
          title: "Maaf,",
          content: Text(result.message),
          cancel: false,
          type: "error",
        );
      } else {

        SharedPreferences prefs = await SharedPreferences.getInstance();
        int limit_dmd_lama = prefs.getInt("limit_dmd");
        int max_limit = prefs.getInt("max_limit");

        if(limitRequestController.text.isEmpty){
          Alert(
            context: context,
            title: "Info,",
            content: Text("Limit Baru harus diisi"),
            cancel: false,
            type: "warning"
          );
        } else {
          if((int.parse(limitRequestController.text.replaceAll(new RegExp('\\.'),'')) > max_limit)){
            Alert(
              context: context,
              title: "Konfirmasi,",
              content: Text("Limit melebihi kapasitas. Kirim permintaan?"),
              cancel: true,
              type: "warning",
              defaultAction: (){
                addRequestLimit();
              }
            );
          } else {
            Alert(
              context: context,
              title: "Konfirmasi,",
              content: Text(
                  "Ubah Limit Customer Gabungan?"),
              cancel: true,
              type: "warning",
              defaultAction: (){
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

    String getChangeLimit = await customerAPI.changeLimitGabungan(context, parameter: 'json={"kode_customerc":"${resultObject[0]['corporate_code']}","user_code":"${prefs.getString('user_code')}","corporate_name":"${resultObject[0]['corporate_name']}","old_limit":"${resultObject[0]['old_limit']}","limit_baru":"${limitRequestController.text.replaceAll(new RegExp('\\.'),'')}"}');

    Navigator.of(context).pop();

    if(getChangeLimit == "OK"){
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

      setState(() {
        resultObject[0]["old_limit"]=limitRequestController.text;
      });
    } else {
      Alert(
        context: context,
        title: "Info,",
        content: Text(getChangeLimit),
        cancel: false,
        type: "warning"
      );
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
          Navigator.pop(context);
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
      changeLimitLoading = false;
    });



  }



}
