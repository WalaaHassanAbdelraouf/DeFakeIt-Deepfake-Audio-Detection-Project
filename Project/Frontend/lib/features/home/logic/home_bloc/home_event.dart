part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class AudioPicked extends HomeEvent {
  final File audioFile;
  final String fileName;

  const AudioPicked(this.audioFile, this.fileName);

  @override
  List<Object> get props => [audioFile, fileName];
}

class StartAnalysis extends HomeEvent {
  final File audioFile;

  const StartAnalysis(this.audioFile);

  @override
  List<Object> get props => [audioFile];
}

class ClearPickedAudio extends HomeEvent {}

class AnalysisFailed extends HomeEvent {
  final String message;

  const AnalysisFailed(this.message);

  @override
  List<Object> get props => [message];
}

class GetAudiosCount extends HomeEvent {}
