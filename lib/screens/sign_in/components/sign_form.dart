import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../helper/keyboard.dart';
import '../../forgot_password/forgot_password_screen.dart';
import '../../../features/auth/auth_service.dart';
import '../../init_screen.dart';

class SignForm extends StatefulWidget {
  const SignForm({super.key});

  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;
  bool isLoading = false;
  String? email, password;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email
          TextFormField(
            decoration: InputDecoration(
              hintText: "Username or Email",
              prefixIcon: const Icon(Icons.person_outline),
              filled: true,
              fillColor: Colors.white,
              border: outlineInputBorder(),
              enabledBorder: outlineInputBorder(),
              focusedBorder: outlineInputBorder(),
            ),
            onSaved: (value) => email = value,
          ),

          const SizedBox(height: 20),

          // Password
          TextFormField(
            obscureText: obscurePassword,
            decoration: InputDecoration(
              hintText: "Password",
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.white,
              border: outlineInputBorder(),
              enabledBorder: outlineInputBorder(),
              focusedBorder: outlineInputBorder(),
            ),
            onSaved: (value) => password = value,
          ),

          const SizedBox(height: 12),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, ForgotPasswordScreen.routeName);
              },
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isLoading ? null : () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  KeyboardUtil.hideKeyboard(context);

                  setState(() {
                    isLoading = true;
                  });

                  print('🔑 Attempting login with email: $email');
                  final success = await AuthService.login(
                    email: email!,
                    password: password!,
                  );
                  print('🔑 Login result: $success');

                  setState(() {
                    isLoading = false;
                  });

                  if (success) {
                    print('✅ Login successful - navigating to InitScreen');
                    // Clear navigation stack and go to InitScreen
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        InitScreen.routeName,
                        (route) => false,
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Login failed. Please check your credentials.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
