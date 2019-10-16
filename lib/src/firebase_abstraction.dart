import 'dart:typed_data';

typedef Future<dynamic> TransactionHandler(FirestoreTransaction transaction);

abstract class FirestoreInstance {
  FirestoreDocumentReference doc(String path);
  FirestoreCollectionReference collection(String path);
  runTransaction(TransactionHandler transaction);
}

abstract class FirestoreTransaction {
  Future<FirestoreDocumentSnapshot> get(FirestoreDocumentReference ref);
  Future<void> set(FirestoreDocumentReference ref, Map<String, dynamic> data);
  Future<void> update(
      FirestoreDocumentReference ref, Map<String, dynamic> data);
  Future<void> delete(FirestoreDocumentReference ref);
}

abstract class FirestoreCollectionReference {
  String get path;
  Stream<FirestoreQuerySnapshot> get snapshots;
  Future<FirestoreQuerySnapshot> get get;
  Future<void> add(Map<String, dynamic> data);
  String get id;
  FirestoreQuery where(String field, QueryOperation op, dynamic value);
  FirestoreDocumentReference doc(String path);
}

enum QueryOperation {
  equalTo, lessThan, lessThanOrEqualTo, greaterThan, greaterThanOrEqualTo, arrayContains
}

abstract class FirestoreQuery {
  Stream<FirestoreQuerySnapshot> get snapshots;
  Future<FirestoreQuerySnapshot> get get;
  FirestoreQuery where(String field, QueryOperation op, dynamic value);
}

class FirestoreQuerySnapshot {
  FirestoreQuerySnapshot(this.docs);
  final List<FirestoreDocumentSnapshot> docs;
}

abstract class FirestoreDocumentReference {
  String get path;
  Stream<FirestoreDocumentSnapshot> get snapshots;
  Future<FirestoreDocumentSnapshot> get get;
  Future<void> set(Map<String, dynamic> data);
  Future<void> update(Map<String, dynamic> data);
  String get id;
  Future<void> delete();
  FirestoreCollectionReference collection(String path);
}

class FirestoreDocumentSnapshot {
  FirestoreDocumentSnapshot({this.id, this.data, this.ref, this.exists});
  final String id;
  final Map<String, dynamic> data;
  final FirestoreDocumentReference ref;
  final bool exists;
  dynamic operator [](String key) {
    return data[key];
  }
}

abstract class FirebaseApp {
  AuthInstance auth();
  FirestoreInstance firestore();
  StorageInstance storage();
}

abstract class FirebaseStorageReference {
  FirebaseStorageReference child(path);
  String get path;
  Future<dynamic> downloadURL();
  FirebaseStorageUploadTask put(Uint8List data);
}

abstract class FirebaseStorageUploadTask {
  void cancel();
  void pause();
  void resume();
  Stream<FirebaseStorageTaskEvent> get events;
}

enum FirebaseStorageTaskEventType {
  resume,
  progress,
  pause,
  success,
  failure,
}

class FirebaseStorageTaskEvent {
  FirebaseStorageTaskEvent(this.type, {this.snapshot});
  final FirebaseStorageTaskEventType type;
  final FirebaseStorageTaskSnapshot snapshot;
}

class FirebaseStorageTaskSnapshot<T extends FirebaseStorageReference> {
  FirebaseStorageTaskSnapshot(this.ref,
      {this.bytesTransferred, this.totalByteCount, this.error});
  final T ref;
  final int bytesTransferred;
  final int totalByteCount;
  final int error;
}

abstract class StorageInstance {
  FirebaseStorageReference get ref;
}

abstract class AuthInstance {
  Future<AuthUser> get currentUser;
  Future<AuthUser> signInWithEmailAndPassword({String email, String password});
  Future<AuthUser> signInWithGoogleAccount();
  Future<AuthUser> createUserWithEmailAndPassword(
      {String email, String password});
  signOut();
  Stream<AuthUser> get userStream;
}

abstract class AuthUser {
  String get uid;
  String get displayName;
  String get photoURL;
  String get email;
  Future<void> updateProfile(AuthUserProfile profile);
}

class AuthUserProfile {
  /// Container of data that will be send in update request
  final Map<String, String> _updateData = <String, String>{};

  set displayName(String displayName) =>
      _updateData['displayName'] = displayName;

  String get displayName => _updateData['displayName'];

  set photoUrl(String photoUri) => _updateData['photoUrl'] = photoUri;

  String get photoUrl => _updateData['photoUrl'];

  bool shouldUpdate(String s) => _updateData.containsKey(s);
}
