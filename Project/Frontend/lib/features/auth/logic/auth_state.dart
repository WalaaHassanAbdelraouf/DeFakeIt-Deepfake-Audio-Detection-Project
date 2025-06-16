abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String? username;

  Authenticated({this.username});

  List<Object?> get props => [username];
}

class Unauthenticated extends AuthState {
  final String? message;
  Unauthenticated({this.message});
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class HistoryLoading extends AuthState {}

class HistoryLoaded extends AuthState {
  final List<Map<String, dynamic>> history;
  HistoryLoaded({required this.history});
}

class HistoryError extends AuthState {
  final String message;
  HistoryError({required this.message});
}

class AnalysisSaved extends AuthState {}


class ChangePasswordLoading extends AuthState {}

class ChangePasswordSuccess extends AuthState {
  final String message;
  ChangePasswordSuccess({required this.message});
}

class ChangePasswordFailure extends AuthState {
  final String error;
  ChangePasswordFailure({required this.error});
}

class UserUpdatedState extends AuthState {
  final String username;
  final String email;

  UserUpdatedState({required this.username, required this.email});

  @override
  List<Object> get props => [username, email];
}
