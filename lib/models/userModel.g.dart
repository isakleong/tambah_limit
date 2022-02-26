// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    Id: json['Id'] as String,
    NIK: json['NIK'] as String ?? '',
    Password_User: json['Password_User'] as String,
    Token: json['Token'] as String,
    MaxLimit: json['MaxLimit'] as String,
    ModuleId: (json['ModuleId'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'Id': instance.Id,
      'NIK': instance.NIK,
      'Password_User': instance.Password_User,
      'Token': instance.Token,
      'MaxLimit': instance.MaxLimit,
      'ModuleId': instance.ModuleId,
    };
