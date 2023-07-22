class UserModel {
  UserModel({
    this.data,
  });

  UserModel.fromJson(dynamic json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Data? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }
}

class Data {
  Data({
    this.token,
    this.expiresOn,
    this.role,
    this.name,
    this.cityId,
    this.trackVehicleDevice,
    this.trackVehicleNumber,
    this.projectId,
  });

  Data.fromJson(dynamic json) {
    token = json['token'];
    trackVehicleNumber = json['trackVehicleNumber'];
    trackVehicleDevice = json['trackVehicleDevice'];
    expiresOn = json['expiresOn'];
    role = json['role'];
    name = json['name'];
    cityId = json['cityId'];
    projectId = json['projectId'];
  }

  String? token;
  String? expiresOn;
  String? role;
  String? trackVehicleDevice;
  String? trackVehicleNumber;
  String? name;
  int? cityId;
  int? projectId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = token;
    map['expiresOn'] = expiresOn;
    map['role'] = role;
    map['name'] = name;
    map['cityId'] = cityId;
    map['projectId'] = projectId;
    return map;
  }
}
