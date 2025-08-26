import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRouteNotifier extends ChangeNotifier {
  AuthRouteNotifier._internal() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((_) {
      if (kDebugMode) {
        print('[AuthRouteNotifier] authState changed -> notifyListeners()');
      }
      notifyListeners();
    });
  }

  static final AuthRouteNotifier _instance = AuthRouteNotifier._internal();
  static AuthRouteNotifier get instance => _instance;

  late final StreamSubscription _sub;

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
