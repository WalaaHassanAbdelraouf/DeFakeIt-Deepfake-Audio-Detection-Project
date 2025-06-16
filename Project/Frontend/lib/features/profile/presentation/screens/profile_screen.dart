import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/theme/theme.dart';
import '../../../home/logic/home_bloc/home_bloc.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = const FlutterSecureStorage();
  Map<String, dynamic> _userData = {
    'username': 'User',
    'email': 'user@example.com',
    'totalAudios': 0,
  };
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    context.read<HomeBloc>().add(GetAudiosCount());
  }

  Future<void> _loadUserData() async {
    try {
      final username = await _storage.read(key: 'username');
      final email = await _storage.read(key: 'email');

      setState(() {
        _userData = {
          'username': username ?? 'User',
          'email': email ?? 'user@example.com',
          'totalAudios': _userData['totalAudios'],
        };
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0,
        ),
        backgroundColor: isDarkMode ?AppTheme.backgroundDark : AppTheme.backgroundLight,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    height: 360 + MediaQuery.of(context).padding.top,
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppTheme.textColorLightDarkBlue : AppTheme.primaryColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(80),
                        bottomRight: Radius.circular(80),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person,
                              size: 110, color: isDarkMode ? AppTheme.textColorLightDarkBlue : AppTheme.primaryColor,),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          _userData['username'],
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // User Info Section
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildInfoCard(
                          context,
                          title: local.email,
                          value: _userData['email'],
                          icon: Icons.email,
                          color: isDarkMode ? AppTheme.textColorLightDarkBlue : AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 15),
                        BlocConsumer<HomeBloc, HomeState>(
                          listener: (context, state) {
                            if (state is HistoryLoaded) {
                              setState(() {
                                _userData['totalAudios'] =
                                    state.totalAudios;
                              });
                            }
                          },
                          builder: (context, state) {
                            if (state is HistoryLoading) {
                              return _buildInfoCard(
                                context,
                                title: local.totalAudios,
                                value: local.loading,
                                icon: Icons.audio_file,
                                color: isDarkMode ? AppTheme.textColorLightDarkBlue : AppTheme.primaryColor,
                              );
                            }
                            return _buildInfoCard(
                              context,
                              title: local.totalAudios,
                              value: '${_userData['totalAudios']}',
                              icon: Icons.audio_file,
                                color: isDarkMode ? AppTheme.textColorLightDarkBlue : AppTheme.primaryColor,
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final updated = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditProfileScreen(
                                    initialUsername:
                                    _userData['username'],
                                    initialEmail: _userData['email'],
                                  ),
                                ),
                              );
                              if (updated == true) {
                                setState(() => _isRefreshing = true);
                                await _loadUserData();
                                await _storage.write(
                                  key: 'username',
                                  value: _userData['username'],
                                );
                                await _storage.write(
                                  key: 'email',
                                  value: _userData['email'],
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode ? AppTheme.textColorLightDarkBlue : AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15),
                            ),
                            child: Text(
                              local.editProfile.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isRefreshing)
              Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required String title,
        required String value,
        required IconData icon,
        required Color color,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textColorLightGray,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.textColorLightDarkBlue,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}