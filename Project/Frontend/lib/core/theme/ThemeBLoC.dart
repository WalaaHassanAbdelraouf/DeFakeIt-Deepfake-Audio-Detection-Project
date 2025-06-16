import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Events
abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

// State
class ThemeState {
  final ThemeMode themeMode;

  const ThemeState({required this.themeMode});
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final _storage = const FlutterSecureStorage();

  ThemeBloc() : super(const ThemeState(themeMode: ThemeMode.system)) {
    on<ToggleThemeEvent>(_onToggleTheme);
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final savedTheme = await _storage.read(key: 'themeMode');
    if (savedTheme != null) {
      if (savedTheme == 'dark') {
        emit(const ThemeState(themeMode: ThemeMode.dark));
      } else if (savedTheme == 'light') {
        emit(const ThemeState(themeMode: ThemeMode.light));
      }
    }
  }

  Future<void> _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) async {
    final currentMode = state.themeMode;
    ThemeMode newMode;

    if (currentMode == ThemeMode.system || currentMode == ThemeMode.light) {
      newMode = ThemeMode.dark;
      await _storage.write(key: 'themeMode', value: 'dark');
    } else {
      newMode = ThemeMode.light;
      await _storage.write(key: 'themeMode', value: 'light');
    }

    emit(ThemeState(themeMode: newMode));
  }
}
