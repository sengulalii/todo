import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:todo/main.dart';
import 'package:todo/services/firebase_login_service.dart';

class LoginViewModel extends ChangeNotifier {
  String? userUid;
  Future<void> loginClassic(String mail, String pass) async {
    try {
      await loginService.login(
        mail,
        pass,
      );
    } catch (exception) {
      /// Kim exception içindeki metni kullanacak ise, oraya kadar elden ele (rethrow ile) exception'ı taşıyoruz

      rethrow;
    }
  }

  Future<String> currentUserUid() async {
    try {
      FirebaseAuth yetki = FirebaseAuth.instance;
      final mevcutKullanici = yetki.currentUser;
      userUid = mevcutKullanici!.uid;
      return userUid!;
    } catch (e) {
      rethrow;
    }
  }

  Future logOut() async {
    await FirebaseLoginService().auth.signOut();
  }

  bool checkLogin() {
    log((FirebaseLoginService().auth.currentUser.toString()));
    if (FirebaseLoginService().auth.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }
}
