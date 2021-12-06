import 'package:json_annotation/json_annotation.dart';
import 'package:tambah_limit/tools/function.dart';

part 'limitHistoryModel.g.dart';

@JsonSerializable()
class LimitHistory {
  final int id;
  final String customer_code;
  final String customer_name;
  final String limit;
  final int status;
  final DateTime request_date;
  final DateTime confirm_date;
  final String user_code;

  LimitHistory({this.id, this.customer_code, this.customer_name, this.limit, this.status, this.request_date, this.confirm_date, this.user_code});

  factory LimitHistory.fromJson(Map<String, dynamic> parsedJson) => _$LimitHistoryFromJson(parsedJson);
  Map<String, dynamic> toJson() => _$LimitHistoryToJson(this);

}
