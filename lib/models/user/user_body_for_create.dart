// To parse this JSON data, do
//
//     final userBodyForCreate = userBodyForCreateFromJson(jsonString);

import 'dart:convert';

UserBodyForCreate userBodyForCreateFromJson(String str) => UserBodyForCreate.fromJson(json.decode(str));

String userBodyForCreateToJson(UserBodyForCreate data) => json.encode(data.toJson());

class UserBodyForCreate {
    String? phone;
    String? email;
    String? password;
    String? fullname;
    String? role;
    String? address;
    String? carPlate;
    String? avatarPicture;
    Location? location;

    UserBodyForCreate({
        this.phone,
        this.email,
        this.password,
        this.fullname,
        this.role,
        this.address,
        this.carPlate,
        this.avatarPicture,
        this.location,
    });

    factory UserBodyForCreate.fromJson(Map<String, dynamic> json) => UserBodyForCreate(
        phone: json["phone"],
        email: json["email"],
        password: json["password"],
        fullname: json["fullname"],
        role: json["role"],
        address: json["address"],
        carPlate: json["car_plate"],
        avatarPicture: json["avatar_picture"],
        location: json["location"] == null ? null : Location.fromJson(json["location"]),
    );

    Map<String, dynamic> toJson() => {
        "phone": phone,
        "email": email,
        "password": password,
        "fullname": fullname,
        "role": role,
        "address": address,
        "car_plate": carPlate,
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
