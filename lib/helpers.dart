import 'dart:io';
import 'package:flutter/foundation.dart';

/// Não é Android
bool get isNotAndroid => kIsWeb || Platform.operatingSystem != 'android';

/// Não é iOS
bool get isNotIOS => Platform.operatingSystem != 'ios';
