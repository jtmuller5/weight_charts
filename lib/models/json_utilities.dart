import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

DateTime? getDateFromTimestamp(Timestamp? timestamp) {
  return timestamp?.toDate();
}

Timestamp? getTimestampFromDate(DateTime? dateTime) {
  return dateTime != null ? Timestamp.fromDate(dateTime) : null;
}

List<DateTime>? getDateListFromTimestampList(List<Timestamp>? timestamps) {
  return timestamps != null ? timestamps.map((e) => e.toDate()).toList() : null;
}

List<Timestamp>? getTimestampListFromDateList(List<DateTime>? dates) {
  return dates != null ? dates.map((e) => Timestamp.fromDate(e)).toList() : null;
}

DateTime getDateWithoutTime(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

double? getWeightForDisplay(double? weight, {bool imperial = true}) {
  double convertedWeight;

  if (weight != null) {
    // Return lbs
    if (imperial) {
      convertedWeight = weight * 2.205;
    }

    // Return kg
    else {
      convertedWeight = weight;
    }

    return convertedWeight;
  }
  return null;
}

Color getDotColor(double value){
  if(value>= 3){
    return Colors.brown;
  } else if(value >=2){
    return Colors.red;
  } else if(value >=1.5){
    return Colors.orange;
  }else if(value>= .5){
    return Colors.green;
  } else if(value >= 0){
    return Colors.orange;
  } else if(value >= -1){
    return Colors.yellow;
  }

  return Colors.black;
}