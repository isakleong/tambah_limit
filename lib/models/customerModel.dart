import 'package:json_annotation/json_annotation.dart';

part 'customerModel.g.dart';

@JsonSerializable()
class Customer {
  final String No_;
  final String Name;
  final String Address;
  final int blocked;
  final String limit;
  final String disc;
  final int limit_dmd;
  final int pembayaranc1;
  final int pembayaranc2;
  final int pembayaranc3;
  final int pembayaranc4;
  final int top_catm;
  final int top_cat;
  final int top_mebelm;
  final int top_mebel;
  final int pembayaranm1;
  final int pembayaranm2;
  final int pembayaranm3;
  final int pembayaranm4;
  final int pembayaranb1;
  final int pembayaranb2;
  final int pembayaranb3;
  final int pembayaranb4;
  final int retur;
  final int jum;
  final int piutang;
  final int ov;
  final String document_no;
  final String due_date;
  final String sisa;
  final String PIN;
  final int jum_byr;
  final int pengali;
  final int rata2;
  final int total_omzet_cat;
  final int total_omzet_bb;
  final int total_omzet_mebel;

  Customer({
    this.No_,
    this.Name,
    this.Address,
    this.blocked,
    this.limit,
    this.disc,
    this.limit_dmd,
    this.pembayaranc1,
    this.pembayaranc2,
    this.pembayaranc3,
    this.pembayaranc4,
    this.top_catm,
    this.top_cat,
    this.top_mebelm,
    this.top_mebel,
    this.pembayaranm1,
    this.pembayaranm2,
    this.pembayaranm3,
    this.pembayaranm4,
    this.pembayaranb1,
    this.pembayaranb2,
    this.pembayaranb3,
    this.pembayaranb4,
    this.retur,
    this.jum,
    this.piutang,
    this.ov,
    this.document_no,
    this.due_date,
    this.sisa,
    this.PIN,
    this.jum_byr,
    this.pengali,
    this.rata2,
    this.total_omzet_cat,
    this.total_omzet_bb,
    this.total_omzet_mebel
  });

  factory Customer.fromJson(Map<String, dynamic> parsedJson) => _$CustomerFromJson(parsedJson);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);

}