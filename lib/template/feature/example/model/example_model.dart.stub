import 'dart:convert';

List<ExampleModel> userModelFromMap(String str) =>
    List<ExampleModel>.from(json.decode(str).map((x) => ExampleModel.fromMap(x)));

String userModelToMap(List<ExampleModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ExampleModel {
  ExampleModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  int id;
  String email;
  String firstName;
  String lastName;
  String avatar;

  factory ExampleModel.fromMap(Map<String, dynamic> json) => ExampleModel(
    id: json["id"],
    email: json["email"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    avatar: json["avatar"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "email": email,
    "first_name": firstName,
    "last_name": lastName,
    "avatar": avatar,
  };
}