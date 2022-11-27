import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future addData(String collection, Map<String, dynamic> data,
      [String? doc]) async {
    try {
      if (doc == null) {
        await firestore.collection(collection).add(data);
      } else {
        await firestore.collection(collection).doc(doc).set(
              data,
              SetOptions(
                merge: true,
              ),
            );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future addTask(
      String collection1, String collection2, Map<String, dynamic> data,
      [String? doc1, doc2]) async {
    try {
      if (doc1 == null) {
        await firestore
            .collection(collection1)
            .doc(doc1)
            .collection(collection2)
            .add(data);
      } else {
        await firestore
            .collection(collection1)
            .doc(doc1)
            .collection(collection2)
            .doc(doc2)
            .set(data, SetOptions(merge: false));
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future getTask(
      String collection1, String collection2, Map<String, dynamic> data,
      [String? doc1]) async {
    try {
      firestore
          .collection(collection1)
          .doc(doc1)
          .collection(collection2)
          .snapshots();
    } catch (e) {
      rethrow;
    }
  }
}
