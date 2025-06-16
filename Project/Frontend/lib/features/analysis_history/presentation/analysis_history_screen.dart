import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../auth/logic/auth_bloc.dart';
import '../../auth/logic/auth_event.dart';
import '../../auth/logic/auth_state.dart';
import 'audio_analysis_screen.dart';

class AnalysisHistoryScreen extends StatelessWidget {
  const AnalysisHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(GetHistoryRequested());

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HistoryLoaded) {
              final recent7Days = state.history.where((item) {
                final date = DateTime.parse(item['upload_date']);
                return DateTime.now().difference(date).inDays <= 7;
              }).toList();

              final previous30Days = state.history.where((item) {
                final date = DateTime.parse(item['upload_date']);
                return DateTime.now().difference(date).inDays > 7 &&
                    DateTime.now().difference(date).inDays <= 30;
              }).toList();

              return ListView(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.analysisHistory,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SectionList(
                    title: AppLocalizations.of(context)!.previous7days,
                    audios: recent7Days,
                  ),
                  const SizedBox(height: 20),
                  SectionList(
                    title: AppLocalizations.of(context)!.previous30days,
                    audios: previous30Days,
                  ),
                ],
              );
            } else if (state is HistoryError) {
              return Center(
                child: Text(
                  "${AppLocalizations.of(context)!.error}: ${state.message}",
                ),
              );
            } else {
              return Center(
                child: Text(AppLocalizations.of(context)!.noDataAvailable),
              );
            }
          },
        ),
      ),
    );
  }
}

class SectionList extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> audios;

  const SectionList({super.key, required this.title, required this.audios});

  @override
  Widget build(BuildContext context) {
    if (audios.isEmpty) {
      return Text(AppLocalizations.of(context)!.noAudiosIn(title));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {},
              child: Text(AppLocalizations.of(context)!.deleteAll),
            ),
          ],
        ),
        ...audios.map((audio) => AudioListItem(audio: audio)).toList(),
      ],
    );
  }
}

class AudioListItem extends StatelessWidget {
  final Map<String, dynamic> audio;

  const AudioListItem({super.key, required this.audio});

  @override
  Widget build(BuildContext context) {
    String audioName = audio['audio_name'] ?? 'Unknown';
    String uploadDate = audio['upload_date'] ?? '';
    String notes = audio['notes'] ?? 'No notes available';
    String format = audio['format'] ?? 'Unknown format';
    double confidence = audio['confidence'] ?? 0.0;
    double size = audio['size'] ?? 0.0;
    bool isFake = audio['is_fake'] ?? false;
    int audioId = audio['audio_id'] ?? '';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AudioAnalysisScreen(
              audioName: audioName,
              isFake: isFake,
              confidence: confidence,
              uploadDate: uploadDate,
              notes: notes,
              format: format,
              size: size,
            ),
          ),
        );
      },
      child: ListTile(
        leading: const Icon(Icons.mic),
        title: Text(audioName),
        subtitle: Text(uploadDate),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isFake
                  ? AppLocalizations.of(context)!.fake
                  : AppLocalizations.of(context)!.real,
              style: TextStyle(
                color: isFake ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                context
                    .read<AuthBloc>()
                    .add(DeleteAudioRequested(audioId: audioId));
              },
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
