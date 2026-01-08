import 'package:adon/features/auth/auth_service.dart';
import 'package:flutter/material.dart';

import 'icon_btn_with_counter.dart';

class LogoutIconButton extends StatelessWidget {
  const LogoutIconButton({Key? key}) : super(key: key);

  static Future<void> _logout(BuildContext context) async {
    await AuthService.logout();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/sign_in',
      (route) => false,
    );
  }

  static void showLogout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          await _logout(context);
                        },
                        child: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconBtnWithCounter(
      svgSrc:
          "assets/icons/Log out.svg",
      press: () => LogoutIconButton.showLogout(context),
    );
  }
}
