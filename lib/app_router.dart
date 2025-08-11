import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/survey/survey_list_screen.dart';
import 'screens/survey/survey_detail_screen.dart';
import 'screens/survey/thankyou_screen.dart';
import 'screens/admin/results_screen.dart';
import 'screens/profile_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/surveys':
        return MaterialPageRoute(builder: (_) => const SurveyListScreen());
      case '/surveyDetail':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => SurveyDetailScreen(surveyId: args?['surveyId'] ?? ''));
      case '/thankyou':
        return MaterialPageRoute(builder: (_) => const ThankYouScreen());
      case '/results':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => ResultsScreen(surveyId: args?['surveyId'] ?? ''));
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}