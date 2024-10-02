// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
    String? userId;
    String? phone;
    String? email;
    String? password;
    String? fullname;
    String? role;
    String? address;
    String? avatarPicture;
    Location? location;

    User({
        this.userId,
        this.phone,
        this.email,
        this.password,
        this.fullname,
        this.role,
        this.address,
        this.avatarPicture,
        this.location,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json["user_id"],
        phone: json["phone"],
        email: json["email"],
        password: json["password"],
        fullname: json["fullname"],
        role: json["role"],
        address: json["address"],
        avatarPicture: json["avatar_picture"],
        location: json["location"] == null ? null : Location.fromJson(json["location"]),
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "phone": phone,
        "email": email,
        "password": password,
        "fullname": fullname,
        "role": role,
        "address": address,
        "avatar_picture": avatarPicture,
        "location": location?.toJson(),
    };
}

class Location {
    double? lat;
    double? long;

    Location({
        this.lat,
        this.long,
    });

    factory Location.fromJson(Map<String, dynamic> json) => Location(
        lat: json["lat"]?.toDouble(),
        long: json["long"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "lat": lat,
        "long": long,
    };
}
