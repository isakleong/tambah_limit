import 'package:flutter/material.dart';
import 'package:tambah_limit/settings/configuration.dart';


class TextView extends StatelessWidget{
  String text, family, fontFamilyUsed;
  Color color, labelColorUsed;
  FontWeight fontWeight, fontWeightUsed;
  FontStyle fontStyle;
  TextAlign align;
  double size, fontSizeUsed, lineHeight;
  int type, maxLines;
  bool caps, italic;
  TextDecoration decoration;
  
  TextView(this.text, this.type, {
    this.align = TextAlign.left,
    this.color,
    this.size,
    this.caps = false,
    this.fontStyle = FontStyle.normal,
    this.family,
    this.lineHeight = 1.2,
    this.maxLines = 9999,
    this.decoration,
    this.fontWeight
  });

  @override
  Widget build(BuildContext context){
    Configuration config = Configuration.of(context);
    double space = 0;

    switch(type) {
      case 1: // Title with primary background
        this.labelColorUsed = config.primaryTextColor;
        this.fontSizeUsed = 20;
        this.fontFamilyUsed = 'WorkSans';
        this.fontWeightUsed = FontWeight.w700;
      break;
      case 2: // Title with secondary background
        this.labelColorUsed = config.secondaryTextColor;
        this.fontSizeUsed = 20;
        this.fontFamilyUsed = 'WorkSans';
        this.fontWeightUsed = FontWeight.w700;
      break;
      case 3: // Title with primary background smaller
        this.labelColorUsed = config.primaryTextColor;
        this.fontFamilyUsed = 'WorkSans';
        this.fontSizeUsed = 16;
        this.fontWeightUsed = FontWeight.w600;
      break;
      case 4: // Title with secondary background smaller
        this.labelColorUsed = config.secondaryTextColor;
        this.fontFamilyUsed = 'WorkSans';
        this.fontSizeUsed = 16;
        this.fontWeightUsed = FontWeight.w500;
      break;
      case 5: // Greyed text
        this.labelColorUsed = config.grayColor;
        this.fontFamilyUsed = 'WorkSans';
        this.fontSizeUsed = 14;
        this.fontWeightUsed = FontWeight.w600;
      break;
      case 6: // Greyed text smaller caps
        this.labelColorUsed = config.grayColor;
        this.fontFamilyUsed = 'WorkSans';
        this.fontSizeUsed = 14;
        this.fontWeightUsed = FontWeight.w500;
      break;
      case 7: // Normal
        this.labelColorUsed = config.secondaryTextColor;
        this.fontFamilyUsed = 'WorkSans';
        this.fontSizeUsed = 12;
        this.fontWeightUsed = FontWeight.w600;
      break;
      case 8:
        this.fontFamilyUsed = 'WorkSans';
        this.fontSizeUsed = 12;
        this.fontWeightUsed = FontWeight.w600;
      break;
      case 9:
        this.fontFamilyUsed = 'WorkSans';
        this.fontSizeUsed = 10;
        this.fontWeightUsed = FontWeight.w500;
      break;
      case 10:
        this.fontFamilyUsed = 'WorkSans';
        this.fontSizeUsed = 8;
        this.fontWeightUsed = FontWeight.w500;
      break;
    }
    
    if (caps && this.text != "") this.text = this.text.toUpperCase();
    if (color != null) this.labelColorUsed = this.color;
    if (size != null) this.fontSizeUsed = this.size;
    if (family != null) this.fontFamilyUsed = this.family;
    if (fontWeight != null) this.fontWeightUsed = this.fontWeight;

    return Text(
      this.text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: this.labelColorUsed,
        fontFamily: this.fontFamilyUsed,
        fontWeight: this.fontWeightUsed,
        fontSize: this.fontSizeUsed,
        height: this.lineHeight,
        fontStyle: this.fontStyle,
        decoration: this.decoration,
        decorationThickness: 2,
        letterSpacing: space
      ),
      textAlign: this.align,
      maxLines: this.maxLines,
    );
    
  } 
  
}