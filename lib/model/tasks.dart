// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'tasks.g.dart';

@JsonSerializable()
class Task {
  int? id;
  String? date;
  String? taskDate;
  String? taskName;
  DateTime? fullTime;
  String? notificationHour;
  String? notificationMinute;
  String? notificationYear;
  String? notificationMonth;
  String? notificationDay;
  Task({
    this.id,
    this.date,
    this.taskDate,
    this.taskName,
    this.fullTime,
    this.notificationHour,
    this.notificationMinute,
    this.notificationYear,
    this.notificationMonth,
    this.notificationDay,
  });
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);
}
