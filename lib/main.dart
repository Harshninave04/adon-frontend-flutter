// import 'package:flutter/material.dart';
// import 'package:adon/screens/splash/splash_screen.dart';

// import 'routes.dart';
// import 'theme.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'AdOn',
//       theme: AppTheme.lightTheme(context),
//       initialRoute: SplashScreen.routeName,
//       routes: routes,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:adon/screens/splash/splash_screen.dart';

import 'routes.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AdOn',
      theme: AppTheme.lightTheme(context),

      // Always start from Splash
      initialRoute: SplashScreen.routeName,

      // Named routes
      routes: routes,

      // OPTIONAL but recommended
      navigatorObservers: [
        // Helps avoid unwanted back stack issues
        HeroController(),
      ],
    );
  }
}
