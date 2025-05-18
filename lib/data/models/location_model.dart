// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class LocationModel {
  int? customerId;
  double? lat;
  double? long;
  LocationModel({
    this.customerId,
    this.lat,
    this.long,
  });

  LocationModel copyWith({
    int? customerId,
    double? lat,
    double? long,
  }) {
    return LocationModel(
      customerId: customerId ?? this.customerId,
      lat: lat ?? this.lat,
      long: long ?? this.long,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'customerId': customerId,
      'lat': lat,
      'long': long,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      customerId: map['customerId'] != null ? map['customerId'] as int : null,
      lat: map['lat'] != null ? map['lat'] as double : null,
      long: map['long'] != null ? map['long'] as double : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LocationModel.fromJson(String source) =>
      LocationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'LocationModel(customerId: $customerId, lat: $lat, long: $long)';

  @override
  bool operator ==(covariant LocationModel other) {
    if (identical(this, other)) return true;

    return other.customerId == customerId &&
        other.lat == lat &&
        other.long == long;
  }

  @override
  int get hashCode => customerId.hashCode ^ lat.hashCode ^ long.hashCode;
}
