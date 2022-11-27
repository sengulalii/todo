import 'package:todo/model/tasks.dart';

abstract class AbstractDbService {
  Future<bool> addTask(Task task, String uid);
  Future<bool> updateTask(Task task, String uid);
  Future<bool> deleteTask(String uid, String date);
  Stream<List<Task>> getAllTask(String uid);
}
