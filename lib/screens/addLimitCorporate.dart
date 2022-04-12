import 'dart:async';
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


class AddLimitCorporate extends StatefulWidget {
  final Result result;

  const AddLimitCorporate({Key key, this.result}) : super(key: key);

  @override
  AddLimitCorporateState createState() => AddLimitCorporateState();
}


class AddLimitCorporateState extends State<AddLimitCorporate> {

  Result result;

  bool customerIdValid = false;
  bool searchLoading = false;
  
  final customerIdController = TextEditingController();
  final FocusNode customerIdFocus = FocusNode();


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigator.popAndPushNamed(
        //     context,
        //     "dashboard"
        // );
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: TextView("Tambah Limit Corporate", 1),
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
              hintText: "Kode Corporate",
              textCapitalization: TextCapitalization.characters,
            ),
          ),
        ),
        bottomNavigationBar:Container(
          margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Button(
            loading: searchLoading,
            backgroundColor: config.darkOpacityBlueColor,
            child: TextView("LANJUTKAN", 3, color: Colors.white),
            onTap: () {
              getLimit();
            },
          ),
        ),
      ),
    );
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

      //var obj = {"kode_customerc": $$('#corporate_code').val(),"corporate_name":$$('#corporate_name').val(), "limit_baru": limit_baru.replace(/\./g,''), "user_code": localStorage.getItem('user_code'), "old_limit": localStorage.getItem('old_limitc')};

      Alert(context: context, loading: true, disableBackButton: true);

      SharedPreferences _sharedPreferences;
      _sharedPreferences = await SharedPreferences.getInstance();
      final SharedPreferences sharedPreferences = await _sharedPreferences;
      String user_code = sharedPreferences.getString('user_code');

      final userCodeData = encryptData(user_code);
      final kodeCustomerData = encryptData(customerIdController.text);

      Result result_ = await customerAPI.getLimitGabungan(context, parameter: 'json={"kode_customerc":"$kodeCustomerData","user_code":"$userCodeData"}');

      Navigator.of(context).pop();

      if(result_.success == 1){
        setState(() {
          result = result_;
        });

        Navigator.pushNamed(
          context,
          "addLimitCorporateDetail",
          arguments: result
        );
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