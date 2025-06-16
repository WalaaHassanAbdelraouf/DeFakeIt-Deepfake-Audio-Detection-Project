abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  LoginRequested(
      {required this.email, required this.password, this.rememberMe = true});
}

class SignUpRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final bool rememberMe;

  SignUpRequested({
    required this.username,
    required this.email,
    required this.password,
    this.rememberMe = true,
  });
}

class LogoutRequested extends AuthEvent {}

class GetHistoryRequested extends AuthEvent {}

class UpdateUserRequested extends AuthEvent {
  final String username;
  final String email;

  UpdateUserRequested({required this.username, required this.email});

  @override
  List<Object> get props => [username, email];
}


class DeleteAudioRequested extends AuthEvent {
  final int audioId;

  DeleteAudioRequested({required this.audioId});
}

class SaveAnalysisRequested extends AuthEvent {
  final int  audioId ;
  final String audioName;
  final bool isFake;
  final double confidence;
  final String uploadDate;
  final String notes;
  final String format;
  final double size;

  SaveAnalysisRequested({
    required this.audioId,
    required this.audioName,
    required this.isFake,
    required this.confidence,
    required this.uploadDate,
    required this.notes,
    required this.format,
    required this.size,
  });
}

class ChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });
}