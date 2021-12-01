import 'package:json_annotation/json_annotation.dart';
import 'package:tambah_limit/tools/function.dart';

part 'customerModel.g.dart';

@JsonSerializable()
class Customer {
  final String Id;
  final String Name;
  final String Address;
  final int Blocked;

  Customer({this.Id, this.Name, this.Address, this.Blocked});

  factory Customer.fromJson(Map<String, dynamic> parsedJson) => _$CustomerFromJson(parsedJson);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);

}