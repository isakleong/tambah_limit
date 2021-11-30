class Result {
  int success;
  String message;
  final data; 

  Result({
    this.success,
    this.message,
    this.data
  });

  factory Result.fromJson(Map<String, dynamic> parsedJson){
    return Result(
      success: parsedJson["success"] ?? 0,
      message: parsedJson["Id"] ?? "",
      data: parsedJson["MaxLimit"] ?? "",
    );
  }
}