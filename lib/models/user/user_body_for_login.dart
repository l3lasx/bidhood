import 'dart:convert';

UserBodyForLogin userBodyForLoginFromJson(String str) => UserBodyForLogin.fromJson(json.decode(str));

String userBodyForLoginToJson(UserBodyForLogin data) => json.encode(data.toJson());

class UserBodyForLogin {
    String? phone;
    String? password;

    UserBodyForLogin({
        this.phone,
        this.password,
    });

    factory UserBodyForLogin.fromJson(Map<String, dynamic> json) => UserBodyForLogin(
        phone: json["phone"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "phone": phone,
        "password": password,
    };
}
