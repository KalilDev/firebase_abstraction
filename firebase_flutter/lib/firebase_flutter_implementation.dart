import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart' as mobile_fs;
import 'package:firebase_auth/firebase_auth.dart' as mobile_auth;
import 'package:firebase_storage/firebase_storage.dart' as mobile_str;
import 'package:google_sign_in/google_sign_in.dart';

import 'package:firebase_abstraction/firebase.dart';

FirebaseApp getFirebaseApp() => MobileFirebaseApp();

class MobileFirestoreTransaction extends FirestoreTransaction {
  MobileFirestoreTransaction._(this._transaction, this._firestore);
  final mobile_fs.Transaction _transaction;
  final mobile_fs.Firestore _firestore;
  Future<FirestoreDocumentSnapshot> get(FirestoreDocumentReference ref) async =>
      _transaction
          .get(_firestore.document(ref.path))
          .then(MobileFirestoreDocumentReference.castToAbstract);
  Future<void> update(
          FirestoreDocumentReference ref, Map<String, dynamic> data) async =>
      _transaction
          .update(_firestore.document(ref.path), data);
  Future<void> set(
          FirestoreDocumentReference ref, Map<String, dynamic> data) async =>
      _transaction.set(_firestore.document(ref.path), data);
  Future<void> delete(FirestoreDocumentReference ref) async =>
      _transaction.delete(_firestore.document(ref.path));
}

class MobileFirestoreInstance extends FirestoreInstance {
  MobileFirestoreInstance._(this._firestore);
  final mobile_fs.Firestore _firestore;
  MobileFirestoreCollectionReference collection(String path) =>
      MobileFirestoreCollectionReference._(_firestore.collection(path));
  MobileFirestoreDocumentReference doc(String path) =>
      MobileFirestoreDocumentReference._(_firestore.document(path));
  runTransaction(TransactionHandler transaction) {
    return _firestore.runTransaction((mobile_fs.Transaction nativeTransaction) {
      return transaction(
          MobileFirestoreTransaction._(nativeTransaction, _firestore));
    });
  }
}

class MobileFirestoreDocumentReference extends FirestoreDocumentReference {
  MobileFirestoreDocumentReference._(this._ref);
  final mobile_fs.DocumentReference _ref;
  String get path => _ref.path;
  Stream<FirestoreDocumentSnapshot> get snapshots =>
      _ref.snapshots().map(MobileFirestoreDocumentReference.castToAbstract);
  Future<FirestoreDocumentSnapshot> get get =>
      _ref.get().then(MobileFirestoreDocumentReference.castToAbstract);
  set(Map<String, dynamic> data) => _ref.setData(data).then<Null>((_) => null);
  String get id => _ref.documentID;
  delete() => _ref.delete();
  collection(String path) =>
      MobileFirestoreCollectionReference._(_ref.collection(path));
  static FirestoreDocumentSnapshot castToAbstract(
          mobile_fs.DocumentSnapshot doc) =>
      FirestoreDocumentSnapshot(
          data: doc.data,
          id: doc.documentID,
          exists: doc.exists,
          ref: MobileFirestoreDocumentReference._(doc.reference));
}

class MobileFirestoreCollectionReference extends FirestoreCollectionReference {
  MobileFirestoreCollectionReference._(this._ref);
  final mobile_fs.CollectionReference _ref;

  String get path => _ref.path;
  Stream<FirestoreQuerySnapshot> get snapshots =>
      _ref.snapshots().map(MobileFirestoreQuery.castToAbstract);
  Future<FirestoreQuerySnapshot> get get =>
      _ref.getDocuments().then(MobileFirestoreQuery.castToAbstract);
  add(Map<String, dynamic> data) => _ref.add(data);
  String get id => _ref.id;
  FirestoreQuery where(String field, QueryOperation op, dynamic value) {
    assert(op != null);
    mobile_fs.Query query;
    switch (op) {
      case QueryOperation.equalTo: query = _ref.where(field, isEqualTo: value); break;
      case QueryOperation.lessThan: query = _ref.where(field, isLessThan: value); break;
      case QueryOperation.lessThanOrEqualTo: query = _ref.where(field, isLessThanOrEqualTo: value); break;
      case QueryOperation.greaterThan: query = _ref.where(field, isGreaterThan: value); break;
      case QueryOperation.greaterThanOrEqualTo: query = _ref.where(field, isGreaterThanOrEqualTo: value); break;
      case QueryOperation.arrayContains: query = _ref.where(field, arrayContains: value); break;
    }
    return MobileFirestoreQuery._(query);
  }
  doc(String path) => MobileFirestoreDocumentReference._(_ref.document(path));
}
class MobileFirestoreQuery extends FirestoreQuery {
  MobileFirestoreQuery._(this._query);
  final mobile_fs.Query _query;
  Stream<FirestoreQuerySnapshot> get snapshots =>
      _query.snapshots().map(castToAbstract);
  Future<FirestoreQuerySnapshot> get get =>
      _query.getDocuments().then(MobileFirestoreQuery.castToAbstract);
  FirestoreQuery where(String field, QueryOperation op, dynamic value) {
    assert(op != null);
    mobile_fs.Query query;
    switch (op) {
      case QueryOperation.equalTo: query = _query.where(field, isEqualTo: value); break;
      case QueryOperation.lessThan: query = _query.where(field, isLessThan: value); break;
      case QueryOperation.lessThanOrEqualTo: query = _query.where(field, isLessThanOrEqualTo: value); break;
      case QueryOperation.greaterThan: query = _query.where(field, isGreaterThan: value); break;
      case QueryOperation.greaterThanOrEqualTo: query = _query.where(field, isGreaterThanOrEqualTo: value); break;
      case QueryOperation.arrayContains: query = _query.where(field, arrayContains: value); break;
    }
    return MobileFirestoreQuery._(query);
  }
  static FirestoreQuerySnapshot castToAbstract(mobile_fs.QuerySnapshot snap) =>
      FirestoreQuerySnapshot(snap.documents
          .map<FirestoreDocumentSnapshot>(
              MobileFirestoreDocumentReference.castToAbstract)
          .toList());
}

class MobileFirebaseApp extends FirebaseApp {
  MobileAuthInstance auth() =>
      MobileAuthInstance._(mobile_auth.FirebaseAuth.instance);
  MobileFirestoreInstance firestore() =>
      MobileFirestoreInstance._(mobile_fs.Firestore.instance);
  MobileStorageInstance storage() =>
      MobileStorageInstance._(mobile_str.FirebaseStorage.instance);
}

class MobileAuthInstance extends AuthInstance {
  MobileAuthInstance._(this._auth);
  mobile_auth.FirebaseAuth _auth;
  Future<MobileAuthUser> get currentUser async {
    final mobile_auth.FirebaseUser user = await _auth.currentUser();
    return MobileAuthUser._(user);
  }

  Stream<MobileAuthUser> get userStream => _auth.onAuthStateChanged
      .map((mobile_auth.FirebaseUser u) => MobileAuthUser._(u));

  Future<MobileAuthUser> signInWithEmailAndPassword(
      {String email, String password}) async {
    final mobile_auth.AuthResult credential = await _auth
        .signInWithEmailAndPassword(email: email, password: password);
    return MobileAuthUser._(credential.user);
  }

  signInWithGoogleAccount() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final mobile_auth.AuthCredential credential =
          mobile_auth.GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final mobile_auth.AuthResult result =
          await _auth.signInWithCredential(credential);
      return MobileAuthUser._(result.user);
    } catch (e) {
      print("Error in sign in with google: $e");
      return null;
    }
  }

  createUserWithEmailAndPassword({String email, String password}) async {
    final mobile_auth.AuthResult credential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);
    return MobileAuthUser._(credential.user);
  }

  signOut() {
    return _auth.signOut();
  }
}

class MobileAuthUser extends AuthUser {
  MobileAuthUser._(this._user);
  final mobile_auth.FirebaseUser _user;

  String get uid => _user?.uid;
  String get displayName => _user?.displayName;
  String get photoURL => _user?.photoUrl;
  String get email => _user?.email;

  updateProfile(AuthUserProfile profile) async {
    final mobile_auth.UserUpdateInfo info = mobile_auth.UserUpdateInfo();
    if (profile?.shouldUpdate('photoUrl') == true)
      info.photoUrl = profile.photoUrl;
    if (profile?.shouldUpdate('displayName') == true)
      info.displayName = profile.displayName;
    return _user.updateProfile(info).then<Null>((_) => null);
  }
}

class MobileFirebaseStorageReference extends FirebaseStorageReference {
  MobileFirebaseStorageReference._(this._ref);
  final mobile_str.StorageReference _ref;
  MobileFirebaseStorageReference child(path) {
    return MobileFirebaseStorageReference._(_ref.child(path));
  }

  String get path => _ref.path;
  Future<dynamic> downloadURL() => _ref.getDownloadURL();
  MobileFirebaseStorageUploadTask put(Uint8List data) =>
      MobileFirebaseStorageUploadTask._(_ref.putData(data));
}

class MobileFirebaseStorageUploadTask extends FirebaseStorageUploadTask {
  MobileFirebaseStorageUploadTask._(this._task);
  final mobile_str.StorageUploadTask _task;
  void cancel() => _task.cancel();
  void pause() => _task.pause();
  void resume() => _task.resume();
  Stream<FirebaseStorageTaskEvent> get events =>
      _task.events.map((mobile_str.StorageTaskEvent e) =>
          FirebaseStorageTaskEvent(convertEventType(e.type),
              snapshot: convertTaskSnapshot(e.snapshot)));
}

class MobileStorageInstance extends StorageInstance {
  MobileStorageInstance._(this._instance);
  final mobile_str.FirebaseStorage _instance;
  FirebaseStorageReference get ref =>
      MobileFirebaseStorageReference._(_instance.ref());
}

FirebaseStorageTaskEventType convertEventType(
    mobile_str.StorageTaskEventType t) {
  final int i = t?.index;
  if (i == null) return null;
  return FirebaseStorageTaskEventType.values[i];
}

FirebaseStorageTaskSnapshot<MobileFirebaseStorageReference> convertTaskSnapshot(
        mobile_str.StorageTaskSnapshot snap) =>
    FirebaseStorageTaskSnapshot<MobileFirebaseStorageReference>(
        MobileFirebaseStorageReference._(snap.ref),
        bytesTransferred: snap.bytesTransferred,
        totalByteCount: snap.totalByteCount,
        error: snap.error);
