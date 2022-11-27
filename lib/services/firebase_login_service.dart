import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo/exception/app_exception.dart';
import 'package:todo/services/abstract_login_service.dart';

class FirebaseLoginService implements AbstractLoginService {
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Future<String> login(String email, [String? pass]) async {
    try {
      return (await auth.signInWithEmailAndPassword(
              email: email, password: pass!))
          .user!
          .uid;
    } catch (e) {
      /// Exception ile beraber metin de gönderebilmek için kendi exception'ımızı türettik
      if (e == FirebaseAuthException(code: "3")) {
        throw AppException("Şifre Yanlış");
      } else if (e == FirebaseAuthException(code: "2")) {
        throw AppException("Şifre Girin");
      }
      throw AppException();
    }
  }
}
