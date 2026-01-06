import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../features/auth/auth_service.dart';
import '../../sign_in/sign_in_screen.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  String? name;
  String? email;
  String? mobile;
  String? password;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: outlineInputBorder(),
      enabledBorder: outlineInputBorder(),
      focusedBorder: outlineInputBorder(),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Signup Successful 🎉",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Your account has been created successfully.\nPlease login to continue.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(
                context,
                SignInScreen.routeName,
              );
            },
            child: const Text(
              "Login",
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          /// FULL NAME
          TextFormField(
            decoration: _inputDecoration(
              hint: "Full Name",
              icon: Icons.person_outline,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return "Name is required";
              }
              return null;
            },
            onSaved: (v) => name = v!.trim(),
          ),

          const SizedBox(height: 20),

          /// EMAIL
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(
              hint: "Email",
              icon: Icons.email_outlined,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return "Email is required";
              }
              return null;
            },
            onSaved: (v) => email = v!.trim(),
          ),

          const SizedBox(height: 20),

          /// MOBILE NUMBER
          TextFormField(
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(
              hint: "Mobile Number",
              icon: Icons.phone_outlined,
            ),
            validator: (v) {
              if (v == null || v.trim().length != 10) {
                return "Enter valid 10 digit mobile number";
              }
              return null;
            },
            onSaved: (v) => mobile = v!.trim(),
          ),

          const SizedBox(height: 20),

          /// PASSWORD
          TextFormField(
            controller: _passwordController,
            obscureText: obscurePassword,
            decoration: _inputDecoration(
              hint: "Password",
              icon: Icons.lock_outline,
              suffix: IconButton(
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
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return "Password is required";
              }
              if (v.length < 8) {
                return "Password must be at least 8 characters";
              }
              return null;
            },
            onSaved: (v) => password = v,
          ),

          const SizedBox(height: 20),

          /// CONFIRM PASSWORD (UI ONLY)
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: obscureConfirmPassword,
            decoration: _inputDecoration(
              hint: "Confirm Password",
              icon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    obscureConfirmPassword = !obscureConfirmPassword;
                  });
                },
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return "Confirm password required";
              }
              if (v != _passwordController.text) {
                return "Passwords do not match";
              }
              return null;
            },
          ),

          const SizedBox(height: 30),

          /// CREATE ACCOUNT BUTTON
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
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;

                      _formKey.currentState!.save();
                      setState(() => isLoading = true);

                      final success = await AuthService.signup(
                        name: name!,
                        email: email!,
                        mobileNumber: mobile!,
                        password: password!,
                      );

                      setState(() => isLoading = false);

                      if (success) {
                        _showSuccessDialog();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Signup failed. Please try again."),
                          ),
                        );
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Create Account",
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
