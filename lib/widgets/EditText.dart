import 'package:flutter/material.dart';
import 'package:tambah_limit/settings/configuration.dart';

class EditText extends StatelessWidget{
  Function function;
  String hintText, labelText, message, alertMessage, data, time;
  bool validate, obscureText, enabled, isFullDate, autoFocus, useIcon, useBorder, whiteStyle;
  TextEditingController controller;
  TextInputType keyboardType;
  Widget prefixIcon;
  Widget suffixIcon, trailing;
  int maxLines;
  FormFieldValidator<String> validator;
  ValueChanged<String> onSubmitted;
  ValueChanged<String> onChanged;
  Key key;
  FocusNode focusNode;
  TextInputAction textInputAction;
  VoidCallback onPressed;
  TextAlign textAlign;
  double width, spaceBetweenLine;
  Color borderColor;
  TextCapitalization textCapitalization;

  EditText({
    this.controller, 
    this.hintText, 
    this.labelText = "", 
    this.validate = false,
    this.obscureText = false, 
    this.keyboardType, 
    this.message, 
    this.prefixIcon, 
    this.suffixIcon,
    this.trailing,
    this.maxLines = 1, 
    this.validator, 
    this.onSubmitted,
    this.onChanged,
    this.alertMessage, 
    this.key, 
    this.enabled,
    this.focusNode,
    this.textInputAction,
    this.width,
    this.data,
    this.time,
    this.isFullDate = false,
    this.autoFocus = false,
    this.useIcon = false,
    this.whiteStyle = false,
    this.useBorder = true,
    this.textAlign = TextAlign.start,
    this.spaceBetweenLine = 0,
    this.function,
    this.borderColor,
    this.textCapitalization = TextCapitalization.none
  });

  @override
  Widget build(BuildContext context){
    Configuration config = Configuration.of(context);

    return TextField(
      decoration: InputDecoration(
        isDense: true,
        enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: config.lightBlueColor, width: 0),
        ),
        border: OutlineInputBorder(),
        hintText: this.hintText,
        hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
        filled: true,
        fillColor: config.lightBlueColor,
        focusColor: config.orangeColor,
        suffix: suffixIcon,
        prefixIcon: prefixIcon,
        errorText: validate ? "${hintText} tidak boleh kosong" : null
      ),
      onChanged: onChanged,
      autofocus: autoFocus,
      key: key,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      textAlign: textAlign,
      controller: controller,
      onSubmitted: onSubmitted,
      enabled: enabled,
      focusNode: focusNode,
      textInputAction: this.textInputAction,
      textCapitalization: textCapitalization
    );
  } 
  
}