library firebase_abstraction;

import 'package:firebase_abstraction/src/mobile/firebase_mobile_implementation.dart'
if (dart.library.html) 'package:firebase_abstraction/src/web/firebase_web_implementation.dart';

export 'src/firebase_abstraction.dart';
import 'src/firebase_abstraction.dart';

FirebaseApp firebaseApp() => FirebaseImplementationApp();
