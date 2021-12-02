import 'package:json_annotation/json_annotation.dart';
import 'package:tambah_limit/tools/function.dart';

part 'customerModel.g.dart';

@JsonSerializable()
class Customer {
  final String No_;
  final String Name;
  final String Address;
  final int blocked;

  Customer({this.No_, this.Name, this.Address, this.blocked});

  factory Customer.fromJson(Map<String, dynamic> parsedJson) => _$CustomerFromJson(parsedJson);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);

}