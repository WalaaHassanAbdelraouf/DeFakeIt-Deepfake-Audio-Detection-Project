import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/APIs/post_login.dart';
import '../../../core/APIs/post_signUp.dart';
import '../../../core/APIs/post_update_user.dart';
import '../../../core/constant/APIs_constants.dart';
import '../../home/data/service/user_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final UserService userService;

  AuthBloc({required this.userService}) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<GetHistoryRequested>(_onGetHistoryRequested);
    on<UpdateUserRequested>(_onUpdateUserRequested);
    on<DeleteAudioRequested>(_onDeleteAudioRequested);
    on<SaveAnalysisRequested>(_onSaveAnalysisRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    String? email = await _storage.read(key: 'email');
    String? password = await _storage.read(key: 'password');
    String? token = await _storage.read(key: 'token');
    String? username = await _storage.read(key: 'username');

    if (email != null && password != null) {
      final newToken = await login(email, password, rememberMe: true);
      if (newToken != null) {
        await _storage.write(key: 'token', value: newToken);
        await userService.loadUserData();
        emit(Authenticated(username: username));
      } else {
        await _storage.deleteAll();
        emit(Unauthenticated(
            message: "Login credentials have changed. Please log in again."));
      }
    } else if (token != null) {
      await userService.loadUserData();
      emit(Authenticated(username: username));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final token = await login(event.email, event.password,
          rememberMe: event.rememberMe);
      if (token != null) {
        await _storage.write(key: 'token', value: token);
        await userService.loadUserData();
        emit(Authenticated());
      } else {
        emit(AuthError("Invalid credentials"));
      }
    } catch (e) {
      emit(AuthError("Login failed: $e"));
    }
  }

  Future<void> _onSignUpRequested(
      SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final token = await signup(event.username, event.email, event.password,
          rememberMe: event.rememberMe);
      if (token != null) {
        await _storage.write(key: 'token', value: token);
        await userService.setUser(username: event.username, email: event.email);
        emit(Authenticated());
      } else {
        emit(AuthError("Sign up failed"));
      }
    } catch (e) {
      emit(AuthError("Sign up error: $e"));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    await _storage.deleteAll();
    emit(Unauthenticated());
  }

  Future<void> _onGetHistoryRequested(
      GetHistoryRequested event, Emitter<AuthState> emit) async {
    emit(HistoryLoading());
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        emit(HistoryError(message: 'Token not found.'));
        return;
      }

      final response = await http.get(
        Uri.parse('${APIsConstants.baseURL}/history'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Map<String, dynamic>> history =
        data.cast<Map<String, dynamic>>();
        emit(HistoryLoaded(history: history));
      } else if (response.statusCode == 401) {
        await _storage.deleteAll();
        emit(Unauthenticated(message: "Session expired. Please log in again."));
      } else {
        emit(HistoryError(message: 'Failed to load history: ${response.body}'));
      }
    } on http.ClientException catch (e) {
      if (e.message.contains('timeout')) {
        emit(HistoryError(
            message: 'Server is offline. Please try again later.'));
      } else {
        emit(HistoryError(message: e.toString()));
      }
    } catch (e) {
      emit(HistoryError(message: e.toString()));
    }
  }

  Future<void> _onUpdateUserRequested(
      UpdateUserRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final newToken = await updateUser(event.username, event.email);

      if (newToken != null) {
        await Future.wait([
          _storage.write(key: 'username', value: event.username),
          _storage.write(key: 'email', value: event.email),
          _storage.write(key: 'token', value: newToken),
        ]);

        await userService.setUser(username: event.username, email: event.email);

        // Emit the state after updating the user
        emit(UserUpdatedState(username: event.username, email: event.email));
      } else {
        emit(AuthError("Failed to update user profile"));
      }
    } on Exception catch (e) {
      if (e.toString().contains("No token found")) {
        await _storage.deleteAll();
        emit(Unauthenticated(message: "Session expired. Please log in again."));
      } else {
        emit(AuthError('Update error: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDeleteAudioRequested(
      DeleteAudioRequested event, Emitter<AuthState> emit) async {
    emit(HistoryLoading());
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        emit(HistoryError(message: 'Token not found.'));
        return;
      }

      final response = await http.delete(
        Uri.parse('${APIsConstants.baseURL}/delete_history/${event.audioId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final historyResponse = await http.get(
          Uri.parse('${APIsConstants.baseURL}/history'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (historyResponse.statusCode == 200) {
          final List<dynamic> data = jsonDecode(historyResponse.body);
          final List<Map<String, dynamic>> history =
          data.cast<Map<String, dynamic>>();
          emit(HistoryLoaded(history: history));
        } else {
          emit(HistoryError(message: 'Failed to load history: ${historyResponse.body}'));
        }
      } else {
        emit(HistoryError(message: 'Failed to delete audio: ${response.body}'));
      }
    } catch (e) {
      emit(HistoryError(message: e.toString()));
    }
  }

  Future<void> _onSaveAnalysisRequested(
      SaveAnalysisRequested event, Emitter<AuthState> emit) async {
    emit(HistoryLoading());
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        emit(HistoryError(message: 'Token not found.'));
        return;
      }

      final response = await http.post(
        Uri.parse('${APIsConstants.baseURL}/history'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'audio_id':event.audioId,
          'audio_name': event.audioName,
          'is_fake': event.isFake,
          'confidence': event.confidence,
          'upload_date': event.uploadDate,
          'notes': event.notes,
          'format': event.format,
          'size': event.size,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        add(GetHistoryRequested());
      } else {
        emit(HistoryError(message: 'Failed to save analysis: ${response.body}'));
      }
    } catch (e) {
      emit(HistoryError(message: e.toString()));
    }
  }


  Future<void> _onChangePasswordRequested(
      ChangePasswordRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(ChangePasswordLoading());

    try {
      final token = await _storage.read(key: 'token');

      if (token == null) {
        emit(ChangePasswordFailure(error: 'Session expired. Please log in again.'));
        return;
      }

      final response = await http.post(
        Uri.parse('${APIsConstants.baseURL}/reset_password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // If your API requires Bearer token auth
        },
        body: jsonEncode({
          'reset_token': token,
          'new_password': event.newPassword,
        }),
      );

      if (response.statusCode == 200) {
        emit(ChangePasswordSuccess(message: 'Password updated successfully'));
      } else {
        final data = jsonDecode(response.body);
        emit(ChangePasswordFailure(error: data['message'] ?? 'Failed to update password'));
      }
    } catch (e) {
      emit(ChangePasswordFailure(error: e.toString()));
    }
  }
}
