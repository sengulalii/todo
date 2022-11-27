import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo/exception/app_exception.dart';
import 'package:todo/services/abstract_create_service.dart';

class FirebaseCreateService implements AbstractCreateService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  UserCredential? credential;
  @override
  Future<UserCredential> create(String email, String pass) async {
    try {
      credential = await auth.createUserWithEmailAndPassword(
          email: email, password: pass);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AppException('Zayıf Şifre');
      } else if (e.code == 'email-already-in-use') {
        throw AppException('E-posta zaten kullanımda');
      }
    }
    return credential!;
  }
}
