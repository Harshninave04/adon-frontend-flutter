import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:adon/constants.dart';
import 'package:adon/screens/create-event/create-event_screen.dart';
import 'package:adon/screens/home/home_screen.dart';
import 'package:adon/screens/profile/profile_screen.dart';

const Color inActiveIconColor = Color(0xFFB6B6B6);

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  static String routeName = "/";

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  int currentSelectedIndex = 0;

  void updateCurrentIndex(int index) {
    setState(() {
      currentSelectedIndex = index;
    });
  }

  final pages = [
    const HomeScreen(),
    const AddEventScreen(),
    const Center(
      child: Text("Chat"),
    ),
    const ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // If on home tab, exit app. Otherwise, go back to home tab
        if (currentSelectedIndex != 0) {
          setState(() {
            currentSelectedIndex = 0;
          });
          return false;
        }
        // Exit the app
        return true;
      },
      child: Scaffold(
        body: pages[currentSelectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    index: 0,
                    iconPath: "assets/icons/Shop Icon.svg",
                  ),
                  _buildNavItem(
                    index: 1,
                    iconPath: "assets/icons/Plus Icon.svg",
                  ),
                  _buildNavItem(
                    index: 2,
                    iconPath: "assets/icons/Chat bubble Icon.svg",
                  ),
                  _buildNavItem(
                    index: 3,
                    iconPath: "assets/icons/User Icon.svg",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String iconPath,
  }) {
    final isSelected = currentSelectedIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => updateCurrentIndex(index),
        borderRadius: BorderRadius.circular(12),
        splashColor: kPrimaryColor.withOpacity(0.2),
        highlightColor: kPrimaryColor.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryLightColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SvgPicture.asset(
            iconPath,
            height: 24,
            width: 24,
            colorFilter: ColorFilter.mode(
              isSelected ? kPrimaryColor : inActiveIconColor,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
