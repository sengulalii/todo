// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      id: json['id'] as int?,
      date: json['date'] as String?,
      taskDate: json['taskDate'] as String?,
      taskName: json['taskName'] as String?,
      fullTime: json['fullTime'] == null
          ? null
          : DateTime.parse(json['fullTime'] as String),
    );

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'taskDate': instance.taskDate,
      'taskName': instance.taskName,
      'fullTime': instance.fullTime?.toIso8601String(),
    };
