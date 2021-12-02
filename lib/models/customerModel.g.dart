// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customerModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) {
  return Customer(
    No_: json['No_'] as String,
    Name: json['Name'] as String,
    Address: json['Address'] as String,
    blocked: json['blocked'] as int,
  );
}

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
      'No_': instance.No_,
      'Name': instance.Name,
      'Address': instance.Address,
      'blocked': instance.blocked,
    };
