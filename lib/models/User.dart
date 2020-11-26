import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Um wrapper de [FirebaseUser] fornece informações para distinguir o valor inicial.
@immutable
class User {
  final bool isInitialValue;
  final FirebaseUser data;

  const User._(this.data, this.isInitialValue);

  factory User.create(FirebaseUser data) => User._(data, false);

  /// Primeira instância vazia
  static const initial = User._(null, true);
}
