import 'package:firebase_auth/firebase_auth.dart';

abstract class AbstractCreateService {
  Future<UserCredential> create(String email, String pass);
}
