import 'package:json_annotation/json_annotation.dart';

part 'userModel.g.dart';

@JsonSerializable()
class User {
  final String Id;
  @JsonKey(name: 'NIK', defaultValue: "")
  String NIK;
  final String Password_User;
  final String Token;
  final String MaxLimit;
  final List<String> ModuleId;

  User({this.Id, this.NIK, this.Password_User, this.Token, this.MaxLimit, this.ModuleId});

  factory User.fromJson(Map<String, dynamic> parsedJson) => _$UserFromJson(parsedJson);
  Map<String, dynamic> toJson() => _$UserToJson(this);

}
