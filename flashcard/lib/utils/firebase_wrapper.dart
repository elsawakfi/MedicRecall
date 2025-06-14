import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class FirebaseWrapper {
  
  static late FirebaseFirestore _firestore;
  static late FirebaseAuth _auth;

  static void setup() {
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
  }

  static void setupForIntegrationTesting() {
    setup();
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }

  static Future<void> setupForTesting(FirebaseFirestore database) async {

    _firestore = database;
    
    _auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(
        uid: "test",
      )
    );

  }

  // This must not be called unless setup() has been called first
  static FirebaseFirestore firestore() {
    return _firestore;
  }

  static FirebaseAuth auth() {
    return _auth;
  }

}