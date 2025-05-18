// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class BlockAppModel {
  int? id;
  List<AppInfo>? block;
  List<AppInfo>? unBlock;

  BlockAppModel({
    this.id,
    this.block,
    this.unBlock,
  });

  BlockAppModel copyWith({
    int? id,
    List<AppInfo>? block,
    List<AppInfo>? unBlock,
  }) {
    return BlockAppModel(
      id: id ?? this.id,
      block: block ?? this.block,
      unBlock: unBlock ?? this.unBlock,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'block': block?.map((x) => x.toMap()).toList(),
      'unBlock': unBlock?.map((x) => x.toMap()).toList(),
    };
  }

  factory BlockAppModel.fromMap(Map<String, dynamic> map) {
    return BlockAppModel(
      id: map['id'] != null ? map['id'] as int : null,
      block: map['block'] != null
          ? List<AppInfo>.from(
              (map['block'] as List<int>).map<AppInfo?>(
                (x) => AppInfo.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      unBlock: map['unBlock'] != null
          ? List<AppInfo>.from(
              (map['unBlock'] as List<int>).map<AppInfo?>(
                (x) => AppInfo.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory BlockAppModel.fromJson(String source) =>
      BlockAppModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'BlockAppModel(id: $id, block: $block, unBlock: $unBlock)';

  @override
  bool operator ==(covariant BlockAppModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        listEquals(other.block, block) &&
        listEquals(other.unBlock, unBlock);
  }

  @override
  int get hashCode => id.hashCode ^ block.hashCode ^ unBlock.hashCode;
}

class AppInfo {
  int? id;
  String? bundle;

  AppInfo({
    this.id,
    this.bundle,
  });

  AppInfo copyWith({
    int? id,
    String? bundle,
  }) {
    return AppInfo(
      id: id ?? this.id,
      bundle: bundle ?? this.bundle,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'bundle': bundle,
    };
  }

  factory AppInfo.fromMap(Map<String, dynamic> map) {
    return AppInfo(
      id: map['id'] != null ? map['id'] as int : null,
      bundle: map['bundle'] != null ? map['bundle'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppInfo.fromJson(String source) =>
      AppInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'AppInfo(id: $id, bundle: $bundle)';

  @override
  bool operator ==(covariant AppInfo other) {
    if (identical(this, other)) return true;

    return other.id == id && other.bundle == bundle;
  }

  @override
  int get hashCode => id.hashCode ^ bundle.hashCode;
}
