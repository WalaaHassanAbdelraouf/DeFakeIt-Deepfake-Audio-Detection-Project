import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/service/audio_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AudioService audioService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _hasAnalyzed = false;

  HomeBloc({required this.audioService}) : super(HomeInitial()) {
    on<AudioPicked>(_onAudioPicked);
    on<StartAnalysis>(_onStartAnalysis);
    on<ClearPickedAudio>(_onClearPickedAudio);
    on<AnalysisFailed>(_onAnalysisFailed);
    on<GetAudiosCount>(_onGetAudiosCount);
  }

  void _onAudioPicked(AudioPicked event, Emitter<HomeState> emit) {
    _hasAnalyzed = false;
    emit(
        AudioPickedState(audioFile: event.audioFile, fileName: event.fileName));
  }

  Future<void> _onStartAnalysis(
      StartAnalysis event, Emitter<HomeState> emit) async {
    if (_hasAnalyzed) return;

    emit(AnalyzingState());
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        emit(const ErrorState(message: 'Please login to analyze audio'));
        return;
      }

      final result = await audioService.uploadAudio(event.audioFile, token);
      _hasAnalyzed = true;

      emit(AnalysisResultState(
        isFake: result.isFake,
        confidence: result.confidence,
        audioName: result.audioName,
        uploadDate: result.uploadDate,
        message: result.message,
      ));
    } on InvalidTokenException {
      await _storage.deleteAll();
      emit(const ErrorState(message: 'Session expired. Please log in again.'));
    } on ServerOfflineException {
      emit(const ErrorState(
          message: 'Server is offline. Please try again later.'));
    } catch (e) {
      emit(ErrorState(message: 'Failed to analyze audio: $e'));
    }
  }

  void _onClearPickedAudio(ClearPickedAudio event, Emitter<HomeState> emit) {
    _hasAnalyzed = false;
    emit(HomeInitial());
  }

  void _onAnalysisFailed(AnalysisFailed event, Emitter<HomeState> emit) {
    emit(ErrorState(message: event.message));
  }

  Future<void> _onGetAudiosCount(
      GetAudiosCount event, Emitter<HomeState> emit) async {
    emit(HistoryLoading());

    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        emit(const ErrorState(message: 'Please login to view history'));
        return;
      }

      final history = await audioService.getAudioHistory(token);
      emit(HistoryLoaded(history: history, totalAudios: history.length));
    } on InvalidTokenException {
      await _storage.deleteAll();
      emit(const ErrorState(message: 'Session expired. Please log in again.'));
    } on ServerOfflineException {
      emit(const ErrorState(
          message: 'Server is offline. Please try again later.'));
    } catch (e) {
      emit(ErrorState(message: 'Failed to fetch history: $e'));
    }
  }
}
