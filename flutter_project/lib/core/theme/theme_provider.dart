import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global theme mode provider. Toggle between light and dark.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
