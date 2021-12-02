import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' show Client;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/models/userModel.dart';
import 'package:tambah_limit/resources/customerAPI.dart';
import 'package:tambah_limit/resources/userAPI.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';
import 'package:tambah_limit/widgets/EditText.dart';
import 'package:tambah_limit/widgets/TextView.dart';
import 'package:tambah_limit/widgets/button.dart';


class AddLimit extends StatefulWidget {
  final Result result;

  const AddLimit({Key key, this.result}) : super(key: key);

  @override
  AddLimitState createState() => AddLimitState();
}


class AddLimitState extends State<AddLimit> {

  final _AddLimitFormKey = GlobalKey<FormState>();

  Result result;

  bool customerIdValid = false;
  bool searchLoading = false;
  
  final customerIdController = TextEditingController();
  final FocusNode customerIdFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    List<Widget> customerLimitWidgetList = showCustomerLimitInfo(config);

    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
            child: EditText(
              useIcon: true,
              key: Key("CustomerId"),
              controller: customerIdController,
              focusNode: customerIdFocus,
              validate: customerIdValid,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.characters,
              hintText: "Kode Pelanggan",
              onSubmitted: (value) {
                customerIdFocus.unfocus();
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            width: MediaQuery.of(context).size.width,
            child: Button(
              loading: searchLoading,
              backgroundColor: config.darkOpacityBlueColor,
              child: TextView("CARI", 3, color: Colors.white),
              onTap: () {
                showCustomerLimitInfo(config);
              },
            ),
          ),
        ],
      ),
    );
  }

  showCustomerLimitInfo(Configuration config) {
    final _AddLimitFormKey = GlobalKey<FormState>();

    List<Widget> tempWidgetList = [];

    if(result != null){
      final resultObject = jsonDecode(result.data.toString());

      var blockedType = resultObject[0]["blocked"];
      var blockedTypeSelected;
      // blockedType == 3 ? blockedTypeSelected = "Blocked All" : blockedType == 0 ? blockedTypeSelected = "Not Blocked" : blockedType == 1 ? blockedTypeSelected = "Blocked Ship" : blockedType == 2 ? "Blocked Invoice" : ""; //kalau diunblock value awal bisa muncul, namun waktu onchange radio, value gk keganti. kalau diblock, running awal, value ndk muncul
      if(blockedType == 3) {
        blockedTypeSelected = "Blocked All";
      } else if(blockedType == 2) {
        blockedTypeSelected = "Blocked Invoice HEHEHE";
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
                      labelText: "Kode Pelanggan",
                      hintText: resultObject[0]["No_"],
                      icon: Icon(Icons.bookmark),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: Colors.black54, width: 1.5,),
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
                      labelText: "Nama Pelanggan",
                      hintText: resultObject[0]["Name"],
                      icon: Icon(Icons.people),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: Colors.black54, width: 1.5,),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: TextFormField(
                    style: TextStyle(color: Colors.red),
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
                      icon: Icon(Icons.location_on),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: Colors.black54, width: 1.5,),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: TextFormField(
                    style: TextStyle(color: Colors.red),
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
                      hintText: resultObject[0]["disc"] + "|" +blockedTypeSelected,
                      icon: Icon(Icons.list_alt),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(5.0,),
                          borderSide: BorderSide(color: Colors.black54, width: 1.5,),
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
                      backgroundColor: config.darkOrangeColor,
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
    

  }


  void getLimit() async {
    setState(() {
      customerIdController.text.isEmpty ? customerIdValid = true : customerIdValid = false;
    });

    if(!customerIdValid){
      FocusScope.of(context).requestFocus(FocusNode());
      setState(() {
        searchLoading = true;
      });

      //http://192.168.10.213/dbrudie-2-0-0/getLimit.php?json={ "user_code" : "isak", "kode_customer" : "01A01010001" }

      Alert(context: context, loading: true, disableBackButton: true);

      SharedPreferences _sharedPreferences;
      _sharedPreferences = await SharedPreferences.getInstance();
      final SharedPreferences sharedPreferences = await _sharedPreferences;
      String user_code = sharedPreferences.getString('user_code');

      Result result_ = await customerAPI.getLimit(context, parameter: 'json={"kode_customer":"${customerIdController.text}","user_code":"${user_code}"}');

      Navigator.of(context).pop();

      if(result_.success == 1){
        // final products = jsonDecode(result.data.toString());
        // products[0]["Name"]

        setState(() {
          result = result_;
        });

        // showBlockInfoDetail(config);
      } else {
        Alert(
          context: context,
          title: "Alert",
          content: Text(result_.message),
          cancel: false,
          type: "warning"
        );
        setState(() {
          result = null;
        });
      }

      setState(() {
        searchLoading = false;
      });

    } else {
      setState(() {
        result = null;
      });
    }

  }

}