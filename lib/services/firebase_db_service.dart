import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo/constants/consts.dart';
import 'package:todo/exception/app_exception.dart';
import 'package:todo/model/tasks.dart';
import 'package:todo/services/abstract_db_service.dart';

class FirebaseDbService implements AbstractDbService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<bool> updateTask(Task task, String uid) async {
    try {
      await firestore
          .collection(taskCollection)
          .doc(uid)
          .collection(myTaskCollection)
          .doc(task.date)
          .update(task.toJson());
    } catch (e) {
      throw AppException(e.toString());
    }
    return true;
  }

  @override
  Future<bool> addTask(Task task, String uid) async {
    try {
      await firestore
          .collection(taskCollection)
          .doc(uid)
          .collection(myTaskCollection)
          .doc(task.date)
          .set(task.toJson());
    } catch (e) {
      throw AppException(e.toString());
    }
    return true;
  }

  @override
  Stream<List<Task>> getAllTask(String uid) {
    var querySnapshot = firestore
        .collection(taskCollection)
        .doc(uid)
        .collection(myTaskCollection)
        .snapshots();
    return querySnapshot.map((taskList) =>
        taskList.docs.map((task) => Task.fromJson(task.data())).toList());
  }

  @override
  Future<bool> deleteTask(String uid, String date) async {
    try {
      await firestore
          .collection(taskCollection)
          .doc(uid)
          .collection(myTaskCollection)
          .doc(date)
          .delete();
    } catch (e) {
      throw AppException(e.toString());
    }
    return true;
  }
}
