import 'package:defakeit/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/logic/locale_bloc.dart';// تأكد من إضافة import للـ LocaleBloc
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageScreen extends StatefulWidget {
  final String selectedLanguage;

  const LanguageScreen({Key? key, this.selectedLanguage = 'English'}) : super(key: key);

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final List<String> _languages = ['Arabic', 'English', 'French', 'German'];
  String _selectedLanguage = 'English';
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.selectedLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final filteredLanguages = _languages
        .where((lang) => lang.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF233C7B);
    final iconColor = isDarkMode ? Colors.white70 : const Color(0xFF233C7B);
    final searchBarColor = isDarkMode ? Colors.grey[800] : Colors.grey[100];
    final dividerColor = isDarkMode ? Colors.grey[700] : const Color(0xFFE5E5E5);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ✅ Background Image with dark overlay if needed
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Image.asset(
              isDarkMode ? "assets/images/background_home_transparent.png" : "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context, _selectedLanguage),
                        child: Icon(Icons.arrow_back_ios, color: iconColor),
                      ),
                      Text(
                        AppLocalizations.of(context)!.language,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      Icon(Icons.language, color: iconColor, size: 24),
                    ],
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: searchBarColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      style: GoogleFonts.poppins(fontSize: 15, color: textColor),
                      decoration: InputDecoration(
                        hintText:   AppLocalizations.of(context)!.searchLanguage,
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchText = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Language list
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredLanguages.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                      color: dividerColor,
                    ),
                    itemBuilder: (context, index) {
                      var lang = filteredLanguages[index];

                      return ListTile(
                        title: Text(
                          lang,
                          style: GoogleFonts.poppins(
                            color: textColor,
                            fontSize: 16,
                          ),
                        ),
                        trailing: _selectedLanguage == lang
                            ? Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppTheme.textColorLightDarkBlue : textColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          ),
                        )
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedLanguage = lang;
                          });

                          // تغيير اللغة باستخدام LocaleBloc
                          if (lang == 'Arabic') {
                            context.read<LocaleBloc>().add(ChangeLocale('ar'));
                          } else if (lang == 'English') {
                            context.read<LocaleBloc>().add(ChangeLocale('en'));
                          } else if (lang == 'French') {
                            context.read<LocaleBloc>().add(ChangeLocale('fr'));
                          } else if (lang == 'German') {
                            context.read<LocaleBloc>().add(ChangeLocale('de'));
                          }

                          // اغلاق الشاشة بعد اختيار اللغة
                          Navigator.pop(context, lang);
                        },
                      );
                    },
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