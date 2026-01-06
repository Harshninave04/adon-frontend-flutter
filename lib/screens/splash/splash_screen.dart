import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../features/auth/auth_service.dart';
import '../init_screen.dart';
import '../sign_in/sign_in_screen.dart';
import 'components/splash_content.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int currentPage = 0;
  bool isCheckingAuth = true;
  bool isLoggedIn = false;
  
  List<Map<String, String>> splashData = [
    {
      "text": "Welcome to AdOn, Let's shop!",
      "image": "assets/images/splash_1.png"
    },
    {
      "text":
          "We help people conect with store \naround United State of America",
      "image": "assets/images/splash_2.png"
    },
    {
      "text": "We show the easy way to shop. \nJust stay at home with us",
      "image": "assets/images/splash_3.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    print('🚀 App started - checking auth status');
    
    // Check if user has a valid token
    final loggedIn = await AuthService.isLoggedIn();
    print('🔍 Token exists in storage: $loggedIn');
    
    if (loggedIn) {
      // Try to verify/refresh the token
      print('🔄 Validating token with backend...');
      final tokenValid = await AuthService.loginWithToken();
      print('✔️ Token validation result: $tokenValid');
      
      if (tokenValid) {
        // Token is valid, navigate to home
        print('✅ Navigating to InitScreen (home)');
        if (mounted) {
          Navigator.pushReplacementNamed(context, InitScreen.routeName);
        }
        return;
      }
    }
    
    // No valid token, show splash screens
    print('❌ No valid token - showing splash screens');
    setState(() {
      isCheckingAuth = false;
      isLoggedIn = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking auth
    if (isCheckingAuth) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: PageView.builder(
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemCount: splashData.length,
                  itemBuilder: (context, index) => SplashContent(
                    image: splashData[index]["image"],
                    text: splashData[index]['text'],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          splashData.length,
                          (index) => AnimatedContainer(
                            duration: kAnimationDuration,
                            margin: const EdgeInsets.only(right: 5),
                            height: 6,
                            width: currentPage == index ? 20 : 6,
                            decoration: BoxDecoration(
                              color: currentPage == index
                                  ? kPrimaryColor
                                  : const Color(0xFFD8D8D8),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 3),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, SignInScreen.routeName);
                        },
                        child: const Text("Continue"),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
