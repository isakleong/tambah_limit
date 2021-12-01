// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customerModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) {
  return Customer(
    Id: json['Id'] as String,
    Name: json['Name'] as String,
    Address: json['Address'] as String,
    Blocked: json['Blocked'] as int,
  );
}

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
      'Id': instance.Id,
      'Name': instance.Name,
      'Address': instance.Address,
      'Blocked': instance.Blocked,
    };
