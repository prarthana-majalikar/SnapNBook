import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state.dart';

final authProvider = StateProvider<UserSession?>((ref) => null);
