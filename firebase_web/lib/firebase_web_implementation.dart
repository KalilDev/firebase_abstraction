import 'dart:typed_data';

import 'package:firebase/firebase.dart' as web_fb;
import 'package:firebase/firestore.dart' as web_fs;
import 'package:firebase_abstraction/firebase.dart';

class WebFirestoreTransaction extends FirestoreTransaction {
  WebFirestoreTransaction._(this._transaction, this._firestore);
  final web_fs.Transaction _transaction;
  final web_fs.Firestore _firestore;
  Future<FirestoreDocumentSnapshot> get(FirestoreDocumentReference ref) async =>
      _transaction
          .get(_firestore.doc(ref.path))
          .then(WebFirestoreDocumentReference.castToAbstract);
  Future<Null> update(
          FirestoreDocumentReference ref, Map<String, dynamic> data) async =>
      _transaction.update(_firestore.doc(ref.path), data: data);
  Future<Null> set(
          FirestoreDocumentReference ref, Map<String, dynamic> data) async =>
      _transaction.set(_firestore.doc(ref.path), data);
  Future<Null> delete(FirestoreDocumentReference ref) async =>
      _transaction.delete(_firestore.doc(ref.path));
}

class WebFirestoreInstance extends FirestoreInstance {
  WebFirestoreInstance._(this._firestore);
  final web_fs.Firestore _firestore;
  WebFirestoreCollectionReference collection(String path) =>
      WebFirestoreCollectionReference._(_firestore.collection(path));

  WebFirestoreDocumentReference doc(String path) =>
      WebFirestoreDocumentReference._(_firestore.doc(path));

  runTransaction(TransactionHandler transaction) {
    return _firestore.runTransaction((web_fs.Transaction nativeTransaction) {
      return transaction(
          WebFirestoreTransaction._(nativeTransaction, _firestore));
    });
  }
}

class WebFirestoreDocumentReference extends FirestoreDocumentReference {
  WebFirestoreDocumentReference._(this._ref);
  final web_fs.DocumentReference _ref;
  String get path => _ref.path;
  Stream<FirestoreDocumentSnapshot> get snapshots =>
      _ref.onSnapshot.map(WebFirestoreDocumentReference.castToAbstract);
  Future<FirestoreDocumentSnapshot> get get =>
      _ref.get().then(WebFirestoreDocumentReference.castToAbstract);
  Future<Null> set(Map<String, dynamic> data) => _ref.set(data);
  String get id => _ref.id;
  Future<Null> delete() => _ref.delete();
  collection(String path) =>
      WebFirestoreCollectionReference._(_ref.collection(path));

  static FirestoreDocumentSnapshot castToAbstract(
          web_fs.DocumentSnapshot doc) =>
      FirestoreDocumentSnapshot(
          data: doc.data(),
          id: doc.id,
          exists: doc.exists,
          ref: WebFirestoreDocumentReference._(doc.ref));
}

class WebFirestoreCollectionReference extends FirestoreCollectionReference {
  WebFirestoreCollectionReference._(this._ref);
  final web_fs.CollectionReference _ref;

  String get path => _ref.path;
  Stream<FirestoreQuerySnapshot> get snapshots => _ref.onSnapshot
      .map<FirestoreQuerySnapshot>(WebFirestoreQuery.castToAbstract);

  Future<FirestoreQuerySnapshot> get get =>
      _ref.get().then(WebFirestoreQuery.castToAbstract);
  add(Map<String, dynamic> data) => _ref.add(data);
  String get id => _ref.id;
  FirestoreQuery where(String field, QueryOperation op, dynamic value) =>
    WebFirestoreQuery._(_ref.where(field, getOpString(op), value));
  doc(String path) => WebFirestoreDocumentReference._(_ref.doc(path));
}
    String getOpString(QueryOperation op) {
    assert(op != null);
    String opString;
    switch (op) {
      case QueryOperation.equalTo: opString = '=='; break;
      case QueryOperation.lessThan: opString = '<'; break;
      case QueryOperation.lessThanOrEqualTo: opString = '<='; break;
      case QueryOperation.greaterThan: opString = '>'; break;
      case QueryOperation.greaterThanOrEqualTo: opString = '>='; break;
      case QueryOperation.arrayContains: opString = 'array-contains'; break;
    }
    return opString;
    }

class WebFirestoreQuery extends FirestoreQuery {
  WebFirestoreQuery._(this._query);
  final web_fs.Query _query;
  Stream<FirestoreQuerySnapshot> get snapshots =>
      _query.onSnapshot.map(castToAbstract);
  Future<FirestoreQuerySnapshot> get get =>
      _query.get().then(WebFirestoreQuery.castToAbstract);
  FirestoreQuery where(String field, QueryOperation op, dynamic value) =>
    WebFirestoreQuery._(_query.where(field, getOpString(op), value));
  static FirestoreQuerySnapshot castToAbstract(web_fs.QuerySnapshot snap) {
    return FirestoreQuerySnapshot(snap.docs
        .map<FirestoreDocumentSnapshot>(
            WebFirestoreDocumentReference.castToAbstract)
        .toList());
  }
}

class WebFirebaseApp extends FirebaseApp {
  WebFirebaseApp._(this._app);
  final web_fb.App _app;
  factory WebFirebaseApp() {
    if (web_fb.apps.isEmpty) {
      final app = web_fb.initializeApp(
        apiKey: "AIzaSyDGxVKeNQbDvFpCC3CUlcl-MxzSAkEDnqI",
        authDomain: "textos-do-kalil.firebaseapp.com",
        databaseURL: "https://textos-do-kalil.firebaseio.com",
        projectId: "textos-do-kalil",
        storageBucket: "textos-do-kalil.appspot.com",
        messagingSenderId: "110201445649",
      );
      app.auth().setPersistence("local");
      return WebFirebaseApp._(app);
    }
    return WebFirebaseApp._(web_fb.app());
  }
  WebAuthInstance auth() => WebAuthInstance._(_app.auth());
  WebFirestoreInstance firestore() => WebFirestoreInstance._(_app.firestore());
  WebStorageInstance storage() => WebStorageInstance._(_app.storage());
}

class WebAuthInstance extends AuthInstance {
  WebAuthInstance._(this._auth);
  web_fb.Auth _auth;
  Future<WebAuthUser> get currentUser async => Future.delayed(
      Duration(milliseconds: 500), () => WebAuthUser._(_auth.currentUser));
  Future<WebAuthUser> signInWithEmailAndPassword(
      {String email, String password}) async {
    final web_fb.UserCredential credential =
        await _auth.signInWithEmailAndPassword(email, password);
    return WebAuthUser._(credential.user);
  }

  Stream<WebAuthUser> get userStream =>
      _auth.onAuthStateChanged.map((web_fb.User u) => WebAuthUser._(u));

  signInWithGoogleAccount() async {
    try {
      final web_fb.UserCredential credential =
          await _auth.signInWithPopup(web_fb.GoogleAuthProvider());
      return WebAuthUser._(credential.user);
    } catch (e) {
      print("Error in sign in with google: $e");
      return null;
    }
  }

  createUserWithEmailAndPassword({String email, String password}) async {
    final web_fb.UserCredential credential =
        await _auth.createUserWithEmailAndPassword(email, password);
    return WebAuthUser._(credential.user);
  }

  signOut() {
    return _auth.signOut();
  }
}

class WebAuthUser extends AuthUser {
  WebAuthUser._(this._user);
  final web_fb.User _user;

  String get uid => _user?.uid;
  String get displayName => _user?.displayName;
  String get photoURL => _user?.photoURL;
  String get email => _user?.email;

  Future<Null> updateProfile(AuthUserProfile profile) async {
    web_fb.UserProfile info = web_fb.UserProfile();
    if (profile?.shouldUpdate('photoUrl') == true)
      info.photoURL = profile.photoUrl;
    if (profile?.shouldUpdate('displayName') == true)
      info.displayName = profile.displayName;
    return _user.updateProfile(info).then<Null>((_) => null);
  }
}

class WebFirebaseStorageReference extends FirebaseStorageReference {
  WebFirebaseStorageReference._(this._ref);
  final web_fb.StorageReference _ref;
  WebFirebaseStorageReference child(path) {
    return WebFirebaseStorageReference._(_ref.child(path));
  }

  String get path => _ref.fullPath;
  Future<dynamic> downloadURL() => _ref.getDownloadURL();
  WebFirebaseStorageUploadTask put(Uint8List data) =>
      WebFirebaseStorageUploadTask._(_ref.put(data));
}

class WebFirebaseStorageUploadTask extends FirebaseStorageUploadTask {
  WebFirebaseStorageUploadTask._(this._task);
  final web_fb.UploadTask _task;
  void cancel() => _task.cancel();
  void pause() => _task.pause();
  void resume() => _task.resume();
  Stream<FirebaseStorageTaskEvent> get events =>
      _task.onStateChanged.map((web_fb.UploadTaskSnapshot snap) =>
          FirebaseStorageTaskEvent(convertEventType(snap.state),
              snapshot: convertTaskSnapshot(snap)));
}

class WebStorageInstance extends StorageInstance {
  WebStorageInstance._(this._instance);
  final web_fb.Storage _instance;
  FirebaseStorageReference get ref => WebFirebaseStorageReference._(_instance.ref('/'));
}

FirebaseStorageTaskEventType convertEventType(web_fb.TaskState t) {
  switch (t) {
    case web_fb.TaskState.RUNNING:
      return FirebaseStorageTaskEventType.progress;
      break;
    case web_fb.TaskState.PAUSED:
      return FirebaseStorageTaskEventType.pause;
      break;
    case web_fb.TaskState.SUCCESS:
      return FirebaseStorageTaskEventType.success;
      break;
    case web_fb.TaskState.CANCELED:
      return FirebaseStorageTaskEventType.failure;
      break;
    case web_fb.TaskState.ERROR:
      return FirebaseStorageTaskEventType.failure;
      break;
    default:
      return null;
  }
}

FirebaseStorageTaskSnapshot<WebFirebaseStorageReference> convertTaskSnapshot(
        web_fb.UploadTaskSnapshot snap) =>
    FirebaseStorageTaskSnapshot<WebFirebaseStorageReference>(
        WebFirebaseStorageReference._(snap.ref),
        bytesTransferred: snap.bytesTransferred,
        totalByteCount: snap.totalBytes);
