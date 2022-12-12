import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo/constants/consts.dart';
import 'package:todo/main.dart';
import 'package:todo/services/database_service.dart';

class CreateViewModel extends ChangeNotifier {
  Future<void> create(String mail, String pass) async {
    UserCredential? uid;
    try {
      uid = await createService.create(
        mail,
        pass,
      );
      DatabaseService.addUser(
        usersCollection,
        {"email": mail, "uid": uid.user?.uid},
        uid.user?.uid,
      );
    } catch (exception) {
      /// Kim exception içindeki metni kullanacak ise, oraya kadar elden ele (rethrow ile) exception'ı taşıyoruz

      rethrow;
    }
  }
}
