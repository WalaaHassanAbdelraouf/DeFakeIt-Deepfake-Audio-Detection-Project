import 'package:defakeit/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/ThemeBLoC.dart';
import 'core/theme/theme.dart';
import 'features/auth/logic/auth_bloc.dart';
import 'features/auth/logic/auth_event.dart';
import 'features/auth/logic/locale_bloc.dart';
import 'features/home/data/service/audio_service.dart';
import 'features/home/logic/home_bloc/home_bloc.dart';
import 'features/home/data/service/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  final userService = UserService();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(create: (_) => HomeBloc(audioService: AudioService())),
        BlocProvider<AuthBloc>(create: (_) => AuthBloc(userService: userService)..add(AppStarted())),
        BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
        BlocProvider<LocaleBloc>(create: (_) => LocaleBloc()), // إضافة الـ LocaleBlo
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleBloc, LocaleState>( // هنا نستخدم LocaleBloc
      builder: (context, localeState) {
        return BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.themeMode,
              onGenerateRoute: AppRouter.generateRoute,
              initialRoute: '/NavView',
              locale: localeState.locale, // استخدام اللغة من الـ LocaleBloc
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: [
                Locale('en', 'US'),
                Locale('ar', 'AE'),
                Locale('de', 'DE'),
                Locale('fr', 'FR'),
              ],
            );
          },
        );
      },
    );
  }
}
