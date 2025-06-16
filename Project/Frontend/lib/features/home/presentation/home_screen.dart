import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';  // استيراد ملف الترجمة
import '../../auth/logic/auth_bloc.dart';
import '../../auth/logic/auth_state.dart';
import 'record_audio_screen.dart';
import 'upload_audio_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = "User";
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    try {
      final username = await _storage.read(key: 'username');
      if (username != null && username.isNotEmpty) {
        setState(() {
          _username = username;
        });
      }
    } catch (e) {
      debugPrint("Error loading username: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // اختصار الترجمة
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UserUpdatedState) {
          setState(() {
            _username = state.username;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${loc.hi}, $_username",
                  style: textTheme.bodyMedium,
                ),
                const Spacer(),
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 140),
                      Text(
                        loc.readyToCheckAudio,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const UploadAudioScreen()),
                                );
                              },
                              icon: const Icon(
                                Icons.file_upload,
                                color: Color(0xFFA4A3A3),
                              ),
                              label: Text(loc.uploadFile),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF4F4F4),
                                foregroundColor: const Color(0xFFA4A3A3),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const RecordAudioScreen()),
                                );
                              },
                              icon: const Icon(
                                Icons.mic,
                                color: Color(0xFFA4A3A3),
                              ),
                              label: Text(loc.record),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF4F4F4),
                                foregroundColor: const Color(0xFFA4A3A3),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 26, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
