import 'package:flutter/cupertino.dart';

import '../../core/constant/route_names.dart';
import '../../features/home/presentation/view/screen/home_screen.dart';
import '../../features/main/presentation/view/screen/main_screen.dart';
import '../../features/splash/splash_screen.dart';

class AppRoutes {
  static const String initialRoute = RouteNames.splashScreen;

  static final Map<String, WidgetBuilder> routes = {
    RouteNames.splashScreen: (context) => const SplashScreen(),
    RouteNames.home: (context) => const HomeScreen(),
    RouteNames.mainScreen: (context) => const MainScreen(),

  };
}