// ignore_for_file: public_member_api_docs, sort_constructors_first

class TokenIdModel {
  String? deviceId;
  int? customerId;
  int? status;

  TokenIdModel({
    this.deviceId,
    this.customerId,
    this.status,
  });

  TokenIdModel.fromJson(Map<String, dynamic> json) {
    deviceId = json['device_id'];
    customerId = json['customer_id'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['device_id'] = deviceId;
    data['customer_id'] = customerId;
    data['status'] = status;
    return data;
  }

  TokenIdModel copyWith({
    String? deviceId,
    int? customerId,
    int? status,
  }) {
    return TokenIdModel(
      deviceId: deviceId ?? this.deviceId,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'deviceId': deviceId,
      'customerId': customerId,
      'status': status,
    };
  }

  factory TokenIdModel.fromMap(Map<String, dynamic> map) {
    return TokenIdModel(
      deviceId: map['deviceId'] != null ? map['deviceId'] as String : null,
      customerId: map['customerId'] != null ? map['customerId'] as int : null,
      status: map['status'] != null ? map['status'] as int : null,
    );
  }

  @override
  String toString() =>
      'TokenIdModel(deviceId: $deviceId, customerId: $customerId, status: $status)';

  @override
  bool operator ==(covariant TokenIdModel other) {
    if (identical(this, other)) return true;

    return other.deviceId == deviceId &&
        other.customerId == customerId &&
        other.status == status;
  }

  @override
  int get hashCode => deviceId.hashCode ^ customerId.hashCode ^ status.hashCode;
}
