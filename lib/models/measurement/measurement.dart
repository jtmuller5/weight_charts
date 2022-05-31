import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


import 'package:json_annotation/json_annotation.dart';
import 'package:weight_charts/models/json_utilities.dart';


part 'measurement.g.dart';

@JsonSerializable(explicitToJson: true)
class Measurement {
  String? measurementId;

  String? petId;

  @JsonKey(fromJson: getDateFromTimestamp, toJson: getTimestampFromDate)
  DateTime? dateTime;

  int? hour;

  int? minute;

  double? weight;

  double? offered;

  double? notEaten;

  int? treats;
  
  String? foodType;

  int? exerciseMins;

  Intensity? exerciseIntensity;

  String? notes;

  bool? hasNote;

  double? bcs;

  String? bcsSource;

  double? bcsCalc;

  @JsonKey(fromJson: getDateFromTimestamp, toJson: getTimestampFromDate)
  DateTime? lastUpdated;

  String? lastUpdateUser;

  Measurement({
    this.measurementId,
    this.petId,
    this.dateTime,
    this.hour,
    this.minute,
    this.weight,
    this.foodType,
    this.offered,
    this.notEaten,
    this.treats,
    this.exerciseMins,
    this.exerciseIntensity,
    this.notes,
    this.hasNote,
    this.bcs,
    this.bcsSource,
    this.bcsCalc,
    this.lastUpdated,
    this.lastUpdateUser,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) => _$MeasurementFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementToJson(this);
}

enum Intensity {
  @JsonValue('low')
  low,

  @JsonValue('medium')
  medium,

  @JsonValue('high')
  high,
}

extension IntensityExtension on Intensity {
  String get name => describeEnum(this);

  String get displayTitle {
    switch (this) {
      case Intensity.low:
        return 'Low Intensity';
      case Intensity.medium:
        return 'Medium Intensity';
      case Intensity.high:
        return 'High Intensity';
    }
  }

  Color get color {
    switch (this) {
      case Intensity.low:
        return Colors.green;
      case Intensity.medium:
        return Colors.orange;
      case Intensity.high:
        return Colors.red;
    }
  }
}
