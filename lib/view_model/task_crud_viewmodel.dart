import 'package:flutter/material.dart';
import 'package:todo/main.dart';
import 'package:todo/model/tasks.dart';

class TaskViewModel extends ChangeNotifier {
  String? uid;
  DateTime date = DateTime.now();

  Future<bool> addTask(Task task, String uid) async {
    try {
      await taskService.addTask(task, uid);
    } catch (exception) {
      rethrow;
    }
    return true;
  }

  Future<bool> updateTask(Task task, String uid) async {
    try {
      await taskService.updateTask(task, uid);
    } catch (exception) {
      rethrow;
    }
    return true;
  }

  Stream<List<Task>> getAllTask(String? uid) {
    return taskService.getAllTask(uid!);
  }

  Future<bool> deleteTask(String uid, String date) async {
    try {
      await taskService.deleteTask(uid, date);
    } catch (e) {
      rethrow;
    }
    return true;
  }
}
