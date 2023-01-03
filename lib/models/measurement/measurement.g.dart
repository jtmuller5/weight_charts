// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Measurement _$MeasurementFromJson(Map<String, dynamic> json) => Measurement(
      measurementId: json['measurementId'] as String?,
      petId: json['petId'] as String?,
      dateTime: getDateFromTimestamp(json['dateTime'] as Timestamp?),
      hour: json['hour'] as int?,
      minute: json['minute'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      foodType: json['foodType'] as String?,
      offered: (json['offered'] as num?)?.toDouble(),
      notEaten: (json['notEaten'] as num?)?.toDouble(),
      treats: json['treats'] as int?,
      exerciseMins: json['exerciseMins'] as int?,
      exerciseIntensity:
          $enumDecodeNullable(_$IntensityEnumMap, json['exerciseIntensity']),
      notes: json['notes'] as String?,
      hasNote: json['hasNote'] as bool?,
      bcs: (json['bcs'] as num?)?.toDouble(),
      bcsSource: json['bcsSource'] as String?,
      bcsCalc: (json['bcsCalc'] as num?)?.toDouble(),
      lastUpdated: getDateFromTimestamp(json['lastUpdated'] as Timestamp?),
      lastUpdateUser: json['lastUpdateUser'] as String?,
      foodUnits: json['foodUnits'] as String?,
      caloriesPerCup: (json['caloriesPerCup'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MeasurementToJson(Measurement instance) =>
    <String, dynamic>{
      'measurementId': instance.measurementId,
      'petId': instance.petId,
      'dateTime': getTimestampFromDate(instance.dateTime),
      'hour': instance.hour,
      'minute': instance.minute,
      'weight': instance.weight,
      'offered': instance.offered,
      'notEaten': instance.notEaten,
      'treats': instance.treats,
      'foodType': instance.foodType,
      'caloriesPerCup': instance.caloriesPerCup,
      'foodUnits': instance.foodUnits,
      'exerciseMins': instance.exerciseMins,
      'exerciseIntensity': _$IntensityEnumMap[instance.exerciseIntensity],
      'notes': instance.notes,
      'hasNote': instance.hasNote,
      'bcs': instance.bcs,
      'bcsSource': instance.bcsSource,
      'bcsCalc': instance.bcsCalc,
      'lastUpdated': getTimestampFromDate(instance.lastUpdated),
      'lastUpdateUser': instance.lastUpdateUser,
    };

const _$IntensityEnumMap = {
  Intensity.low: 'low',
  Intensity.medium: 'medium',
  Intensity.high: 'high',
};
