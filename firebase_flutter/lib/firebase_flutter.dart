library firebase_flutter;
export 'firebase_flutter_implementation.dart'
if (dart.library.html) 'package:firebase_web/firebase_web.dart' show getFirebaseApp;
