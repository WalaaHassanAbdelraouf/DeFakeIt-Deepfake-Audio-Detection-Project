part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class AudioPickedState extends HomeState {
  final File audioFile;
  final String fileName;

  const AudioPickedState({required this.audioFile, required this.fileName});

  @override
  List<Object> get props => [audioFile, fileName];
}

class AnalyzingState extends HomeState {}

class AnalysisResultState extends HomeState {
  final bool isFake;
  final double confidence;
  final String audioName;
  final String uploadDate;
  final String? message;

  const AnalysisResultState({
    required this.isFake,
    required this.confidence,
    required this.audioName,
    required this.uploadDate,
    this.message,
  });

  @override
  List<Object?> get props =>
      [isFake, confidence, audioName, uploadDate, message];
}

class ErrorState extends HomeState {
  final String message;

  const ErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

class HistoryLoading extends HomeState {}

class HistoryLoaded extends HomeState {
  final List<Map<String, dynamic>> history;
  final int totalAudios;

  const HistoryLoaded({required this.history, required this.totalAudios});

  @override
  List<Object> get props => [history, totalAudios];
}

class HistoryError extends HomeState {
  final String message;

  const HistoryError({required this.message});

  @override
  List<Object> get props => [message];
}
