import 'package:defakeit/core/theme/theme.dart';
import 'package:defakeit/features/analysis_history/presentation/analysis_history_screen.dart';
import 'package:defakeit/features/home/presentation/home_screen.dart';
import 'package:defakeit/features/profile/presentation/screens/profile_screen.dart';
import 'package:defakeit/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class NavView extends StatefulWidget {
  const NavView({super.key});

  @override
  State<NavView> createState() => _NavViewState();
}

class _NavViewState extends State<NavView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      body: Stack(
        children: [
          if (_selectedIndex != 2)
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Image.asset(
                isDarkMode ? "assets/images/background_home_transparent.png" : "assets/images/background.png",
                fit: BoxFit.cover,
                //color: isDarkMode ? Colors.white.withOpacity(0.2) : null,
              ),
            ),
          IndexedStack(
            index: _selectedIndex,
            children: const [
              HomeScreen(),
              AnalysisHistoryScreen(),
              ProfileScreen(),
              SettingsScreen(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              backgroundColor:
              Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedLabelStyle: const TextStyle(fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: _buildNavIcon("assets/images/Home.png", 0),
                  label: AppLocalizations.of(context)!.home,
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon("assets/images/Analysis History.png", 1),
                  label: AppLocalizations.of(context)!.analysisHistory,
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon("assets/images/profile.png", 2),
                  label: AppLocalizations.of(context)!.profile,
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon("assets/images/Settings.png", 3),
                  label: AppLocalizations.of(context)!.settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(String assetPath, int index) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        _selectedIndex == index ? const Color(0xFF52859E) : Colors.grey,
        BlendMode.srcIn,
      ),
      child: Image.asset(assetPath, width: 24, height: 24),
    );
  }
}
