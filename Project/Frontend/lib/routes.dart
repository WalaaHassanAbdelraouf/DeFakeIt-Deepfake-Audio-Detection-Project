import 'package:defakeit/features/auth/presentation/create_new_password_screen.dart';
import 'package:defakeit/features/auth/presentation/splash_screen.dart';
import 'package:defakeit/features/auth/presentation/welcome_screen.dart';
import 'package:flutter/material.dart';

// Auth screens
import 'features/auth/presentation/changePassword.dart';
import 'features/auth/presentation/done_change_password.dart';
import 'features/auth/presentation/forgot_password_screen.dart';
import 'features/auth/presentation/login_screen.dart';

// Home screens
import 'features/auth/presentation/signup_screen.dart';
import 'features/auth/presentation/verify_code_screen.dart';
import 'features/home/presentation/detection_result_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/home/presentation/loading_screen.dart';
import 'features/home/presentation/record_audio_screen.dart';

// Other features
import 'features/analysis_history/presentation/analysis_history_screen.dart';
import 'features/home/presentation/upload_audio_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/settings/presentation/language.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'nav_view.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case '/forgotPassword':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case '/verification':
        return MaterialPageRoute(builder: (_) => const VerifyCodeScreen());

      case '/createNewPassword':
        return MaterialPageRoute(
            builder: (_) => const CreateNewPasswordScreen());

      case '/doneChangePass':
        return MaterialPageRoute(builder: (_) => const DoneChangePassword());

      case '/home':
        return MaterialPageRoute(builder: (_) => const NavView());

      case '/upload':
        return MaterialPageRoute(builder: (_) => const UploadAudioScreen());

      case '/record':
        return MaterialPageRoute(builder: (_) => const RecordAudioScreen());

      case '/loading':
        return MaterialPageRoute(builder: (_) => const LoadingScreen());

      case '/detectionResult':
        final args = settings.arguments as Map?;
        return MaterialPageRoute(
          builder: (_) => DetectionResultScreen(
            isFake: args?['isFake'] as bool? ?? false,
            confidence: args?['confidence'] as double? ?? 0.0,
            audioName: args?['audioName'] as String? ?? '',
            uploadDate: args?['uploadDate'] as String? ?? '',
            message: args?['message'] as String?,
          ),
        );

      case '/analysis_history':
        return MaterialPageRoute(builder: (_) => const AnalysisHistoryScreen());

      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case '/NavView':
        return MaterialPageRoute(builder: (_) => const NavView());

      case '/ChangePasswordScreen':
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());

      case '/language':
        return MaterialPageRoute(builder: (_) => const LanguageScreen());

      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case '/CreateNewPasswordScreen':
        return MaterialPageRoute(builder: (_) => const CreateNewPasswordScreen());

      case '/DoneChangePassword':
        return MaterialPageRoute(builder: (_) => const DoneChangePassword());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
