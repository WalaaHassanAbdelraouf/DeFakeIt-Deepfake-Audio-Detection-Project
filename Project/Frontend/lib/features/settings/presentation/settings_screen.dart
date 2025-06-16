import 'package:defakeit/features/settings/presentation/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/ThemeBLoC.dart';
import '../../../core/theme/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../auth/logic/auth_bloc.dart';
import '../../auth/logic/auth_event.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreen1State();
}

class _SettingsScreen1State extends State<SettingsScreen> {
  int _selectedIndex = 3;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BackButton(),
                Text(
                  AppLocalizations.of(context)!.settings, // استخدام الترجمة هنا
                  style: textTheme.displayMedium,
                ),
                IconButton(
                  icon: Image.asset(
                    'assets/images/logout_icon.png',
                    width: 45,
                    height: 45,
                    color: textTheme.displayMedium?.color,
                  ),
                  onPressed: () {
                    context.read<AuthBloc>().add(LogoutRequested());
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // General Section
          _sectionLabel(AppLocalizations.of(context)!.general), // الترجمة هنا
          _settingsItem(
            title: AppLocalizations.of(context)!.language, // الترجمة هنا
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedLanguage,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      LanguageScreen(selectedLanguage: _selectedLanguage),
                ),
              );
              if (result != null && result is String) {
                setState(() {
                  _selectedLanguage = result;
                });
              }
            },
          ),
          _divider(),

          _settingsItem(
            title: isDarkMode ? AppLocalizations.of(context)!.lightMode : AppLocalizations.of(context)!.darkMode, // الترجمة هنا
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/sun_icon.png',
                  width: 22,
                  height: 22,
                  color: textTheme.bodyMedium?.color,
                ),
                const SizedBox(width: 6),
              ],
            ),
            trailing: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return Switch(
                  value: state.themeMode == ThemeMode.dark,
                  onChanged: (_) {
                    context.read<ThemeBloc>().add(ToggleThemeEvent());
                  },
                  activeColor: AppTheme.secondaryColor,
                );
              },
            ),
            onTap: () {},
          ),
          _divider(),

          _settingsItem(
            title: AppLocalizations.of(context)!.contactUs, // الترجمة هنا
            trailing: const Icon(Icons.chevron_right,
                color: Colors.grey, size: 20),
            onTap: () {},
          ),
          const SizedBox(height: 26),

          // Security Section
          _sectionLabel(AppLocalizations.of(context)!.security), // الترجمة هنا
          _settingsItem(
            title: AppLocalizations.of(context)!.changePassword, // الترجمة هنا
            trailing: const Icon(Icons.chevron_right,
                color: Colors.grey, size: 20),
            onTap: () {
              Navigator.pushNamed(context, '/ChangePasswordScreen');
            },
          ),
          _divider(),

          _settingsItem(
            title: AppLocalizations.of(context)!.privacyPolicy, // الترجمة هنا
            trailing: const Icon(Icons.chevron_right,
                color: Colors.grey, size: 20),
            onTap: _showPrivacyPolicy,
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8, top: 18),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _settingsItem({
    required String title,
    Widget? leading,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            if (leading != null) leading,
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: Theme.of(context).dividerColor.withOpacity(0.2),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(AppLocalizations.of(context)!.privacyPolicy, // الترجمة هنا
            style: Theme.of(context).textTheme.displayMedium),
        content: SingleChildScrollView(
          child: Text(
            AppLocalizations.of(context)!.privacyPolicyContent, // الترجمة هنا
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close, // الترجمة هنا
                style: TextStyle(color: AppTheme.secondaryColor)),
          ),
        ],
      ),
    );
  }
}
