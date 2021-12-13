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

  Result result;

  bool customerIdValid = false;
  bool searchLoading = false;
  
  final customerIdController = TextEditingController();
  final FocusNode customerIdFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    // List<Widget> customerLimitWidgetList = showCustomerLimitInfo(config);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: TextView("Tambah Limit", 1),
          // leading: IconButton(
          //   icon: Icon(Icons.arrow_back, color: Colors.white),
          //   onPressed: () => Navigator.pop(context),
          // ),
        ),
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 40, horizontal: 15),
            child: EditText(
              key: Key("CustomerId"),
              controller: customerIdController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              focusNode: customerIdFocus,
              validate: customerIdValid,
              hintText: "Kode Pelanggan",
              textCapitalization: TextCapitalization.characters,
            ),
          ),
        ),
        bottomNavigationBar:Container(
          margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Button(
            backgroundColor: config.darkOpacityBlueColor,
            child: TextView("LANJUTKAN", 3, color: Colors.white, caps: true),
            onTap: () {
              getLimit();
            },
          ),
        ),
      ),
    );

    // return Container(
    //   child: Column(
    //     children: [
    //       Container(
    //         margin: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
    //         child: EditText(
    //           useIcon: true,
    //           key: Key("CustomerId"),
    //           controller: customerIdController,
    //           focusNode: customerIdFocus,
    //           validate: customerIdValid,
    //           keyboardType: TextInputType.text,
    //           textInputAction: TextInputAction.done,
    //           textCapitalization: TextCapitalization.characters,
    //           hintText: "Kode Pelanggan",
    //           onSubmitted: (value) {
    //             customerIdFocus.unfocus();
    //           },
    //         ),
    //       ),
    //       Container(
    //         margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
    //         width: MediaQuery.of(context).size.width,
    //         child: Button(
    //           loading: searchLoading,
    //           backgroundColor: config.darkOpacityBlueColor,
    //           child: TextView("CARI", 3, color: Colors.white),
    //           onTap: () {
    //             getLimit();
    //           },
    //         ),
    //       ),
    //       customerLimitWidgetList.length == 0
    //       ? 
    //       Container()
    //       :
    //       Container(),
          
    //       // Expanded(
    //       //   child: ListView(
    //       //     scrollDirection: Axis.vertical,
    //       //     padding: EdgeInsets.all(0),
    //       //     physics: ScrollPhysics(),
    //       //     shrinkWrap: true,
    //       //     children: customerLimitWidgetList,
    //       //   ),
    //       // ),
    //     ],
    //   ),
    // );
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

        Navigator.pushNamed(
          context,
          "addLimitDetail",
          arguments: result,
        );

        // showBlockInfoDetail(config);
      } else {
        Alert(
          context: context,
          title: "Maaf,",
          content: Text(result_.message),
          cancel: false,
          type: "error"
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