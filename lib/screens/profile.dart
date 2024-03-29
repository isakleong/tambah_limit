import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' show Client;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tambah_limit/models/resultModel.dart';
import 'package:tambah_limit/models/userModel.dart';
import 'package:tambah_limit/resources/userAPI.dart';
import 'package:tambah_limit/settings/configuration.dart';
import 'package:tambah_limit/tools/function.dart';
import 'package:tambah_limit/widgets/EditText.dart';
import 'package:tambah_limit/widgets/TextView.dart';
import 'package:tambah_limit/widgets/button.dart';

Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();


class Profile extends StatefulWidget {
  final Result result;

  const Profile({Key key, this.result}) : super(key: key);

  @override
  ProfileState createState() => ProfileState();
}


class ProfileState extends State<Profile> {

  bool unlockOldPassword = true;
  bool unlockNewPassword = true;
  bool unlockConfirmPassword = true;

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final FocusNode oldPasswordFocus = FocusNode();
  final FocusNode newPasswordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  bool oldPasswordValid = false;
  bool newPasswordValid = false;
  bool confirmPasswordValid = false;
  String oldPasswordErrorMessage = "", newPasswordErrorMessage = "", confirmPasswordErrorMessage = "";

  bool changePasswordLoading = false;


  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
              child: EditText(
                useIcon: true,
                key: Key("OldPassword"),
                controller: oldPasswordController,
                focusNode: oldPasswordFocus,
                obscureText: unlockOldPassword,
                validate: oldPasswordValid,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.characters,
                hintText: "Password Lama",
                alertMessage: oldPasswordErrorMessage,
                suffixIcon:
                InkWell(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(
                      Icons.remove_red_eye,
                      color:  unlockOldPassword ? config.lightGrayColor : config.grayColor,
                      size: 18,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      unlockOldPassword = !unlockOldPassword;
                    });
                  },
                ),
                onSubmitted: (value) {
                  _fieldFocusChange(context, oldPasswordFocus, newPasswordFocus);
                },
                onChanged: (value) {
                  
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
              child: EditText(
                useIcon: true,
                key: Key("NewPassword"),
                controller: newPasswordController,
                focusNode: newPasswordFocus,
                validate:  newPasswordValid,
                obscureText: unlockNewPassword,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.characters,
                hintText: "Password Baru",
                alertMessage: newPasswordErrorMessage,
                suffixIcon:
                  InkWell(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(
                        Icons.remove_red_eye,
                        color:  unlockNewPassword ? config.lightGrayColor : config.grayColor,
                        size: 18,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        unlockNewPassword = !unlockNewPassword;
                      });
                    },
                  ),
                onSubmitted: (value) {
                  _fieldFocusChange(context, newPasswordFocus, confirmPasswordFocus);
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
              child: EditText(
                useIcon: true,
                key: Key("ConfirmPassword"),
                controller: confirmPasswordController,
                focusNode: confirmPasswordFocus,
                validate: confirmPasswordValid,
                keyboardType: TextInputType.text,
                obscureText: unlockConfirmPassword,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.characters,
                hintText: "Konfirmasi Password Baru",
                alertMessage: confirmPasswordErrorMessage,
                suffixIcon:
                  InkWell(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(
                        Icons.remove_red_eye,
                        color:  unlockConfirmPassword ? config.lightGrayColor : config.grayColor,
                        size: 18,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        unlockConfirmPassword = !unlockConfirmPassword;
                      });
                    },
                  ),
                onSubmitted: (value) {
                  confirmPasswordFocus.unfocus();
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              width: MediaQuery.of(context).size.width,
              child: Button(
                loading: changePasswordLoading,
                backgroundColor: config.darkOpacityBlueColor,
                child: TextView("UBAH", 3, color: Colors.white),
                onTap: () {
                  submitValidation();
                },
              ),
            ),
          ],
        ),
      );
  }

  void submitValidation() {

    setState(() {

      if(oldPasswordController.text.isEmpty){
        oldPasswordValid = true;
        oldPasswordErrorMessage = "tidak boleh kosong";
      } else {
        oldPasswordValid = false;
      }

      if(newPasswordController.text.isEmpty){
        newPasswordValid = true;
        newPasswordErrorMessage = "tidak boleh kosong";
      } else {
        newPasswordValid = false;
      }

      if(confirmPasswordController.text.isEmpty){
        confirmPasswordValid = true;
        confirmPasswordErrorMessage = "tidak boleh kosong";
      } else {
        confirmPasswordValid = false;
      }

      if(oldPasswordController.text.isEmpty){
        oldPasswordValid = true;
        oldPasswordErrorMessage = "tidak boleh kosong";
      } else {
        oldPasswordValid = false;
      }

      if (newPasswordController.text != confirmPasswordController.text){
        newPasswordValid = true;
        confirmPasswordValid = true;

        newPasswordErrorMessage = "tidak sama dengan Konfirmasi Password Baru";
        confirmPasswordErrorMessage = "tidak sama dengan Password Baru";

      }

    });

    if(!oldPasswordValid && !newPasswordValid && !confirmPasswordValid){
      Alert(
        context: context,
        title: "Konfirmasi,",
        content: Text("Apakah Anda yakin ingin mengubah password?"),
        cancel: true,
        type: "warning",
        defaultAction: () async {
          doChangePassword();
      });
      
      
    }

  }
  
  void doChangePassword() async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      changePasswordLoading = true;
    });

    Alert(context: context, loading: true, disableBackButton: true);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final userCodeData = encryptData(prefs.getString('user_code'));
    final oldPasswordData = encryptData(oldPasswordController.text);

    String getOldPassword = await userAPI.getPassword(context, parameter: 'user_code=$userCodeData&old_pass=$oldPasswordData');

    Navigator.of(context).pop();

    if(getOldPassword == "OK"){
      final userCodeData = encryptData(prefs.getString("user_code"));

      String getChangePassword = await userAPI.changePassword(context, parameter: 'json={"new_pass":"${newPasswordController.text}","user_code":"${userCodeData}"}');

      if(getChangePassword == "OK"){
        Alert(
          context: context,
          title: "Terima kasih,",
          content: Text("Password berhasil diubah, silahkan lakukan login ulang"),
          cancel: false,
          type: "success",
          defaultAction: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove("limit_dmd");
              await prefs.remove("request_limit");
              await prefs.remove("user_code_request");
              await prefs.remove("user_code");
              await prefs.remove("max_limit");
              await prefs.remove("fcmToken");
              await prefs.remove("get_user_login");
              await prefs.remove("nik");
              await prefs.remove("module_privilege");
              await FirebaseMessaging.instance.deleteToken();
              await prefs.clear();
              Navigator.pushReplacementNamed(
                context,
                "login",
              );
            // if (mounted) {
            //   SharedPreferences prefs = await SharedPreferences.getInstance();
            //   await prefs.remove("limit_dmd");
            //   await prefs.remove("request_limit");
            //   await prefs.remove("user_code_request");
            //   await prefs.remove("user_code");
            //   await prefs.remove("max_limit");
            //   await prefs.clear();
            //   Navigator.pushReplacementNamed(
            //     context,
            //     "login",
            //   );
            // }
          } 
        );
        
      } else {
        Alert(
          context: context,
          title: "Maaf,",
          content: Text(getChangePassword),
          cancel: false,
          type: "error"
        );
      }

      setState(() {
        changePasswordLoading = false;
      });

    } else {
      Alert(
          context: context,
          title: "Maaf,",
          content: Text(getOldPassword),
          cancel: false,
          type: "error"
        );
    }

    setState(() {
      changePasswordLoading = false;
    });
    

  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus); 
  }

}