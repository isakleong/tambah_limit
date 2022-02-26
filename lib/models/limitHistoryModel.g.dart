// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'limitHistoryModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LimitHistory _$LimitHistoryFromJson(Map<String, dynamic> json) {
  return LimitHistory(
    id: json['id'] as int,
    customer_code: json['customer_code'] as String,
    customer_name: json['customer_name'] as String,
    limit: json['limit'] as String,
    limit_dmd: json['limit_dmd'] as String,
    status: json['status'] as int,
    request_date: json['request_date'] == null
        ? null
        : DateTime.parse(json['request_date']['date'] as String),
    confirm_date: json['confirm_date'] == null
        ? null
        : DateTime.parse(json['confirm_date']['date'] as String),
    user_code: json['user_code'] as String,
  );
}

Map<String, dynamic> _$LimitHistoryToJson(LimitHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_code': instance.customer_code,
      'customer_name': instance.customer_name,
      'limit': instance.limit,
      'limit_dmd': instance.limit_dmd,
      'status': instance.status,
      'request_date': instance.request_date?.toIso8601String(),
      'confirm_date': instance.confirm_date?.toIso8601String(),
      'user_code': instance.user_code,
    };
