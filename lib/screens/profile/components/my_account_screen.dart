import 'package:adon/features/profile/profile_service.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart'; // Ensure this points to your color constants

class MyAccountScreen extends StatefulWidget {
  static String routeName = "/my_account";

  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;

  String? name;
  String? email;
  String? mobileNumber;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final data = await ProfileService.getMyProfile();
    if (data != null) {
      setState(() {
        name = data['name'];
        email = data['email'];
        mobileNumber = data['mobileNumber'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => isLoading = true);

      final success = await ProfileService.updateProfile({
        "name": name,
        "email": email,
        "mobileNumber": mobileNumber,
      });

      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? "Profile updated!" : "Update failed"),
            backgroundColor: success ? kPrimaryColor : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Account")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // --- Name Field ---
                    TextFormField(
                      initialValue: name,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        hintText: "Enter your name",
                        suffixIcon: Icon(Icons.person),
                      ),
                      onSaved: (newValue) => name = newValue,
                    ),
                    const SizedBox(height: 20),

                    // --- Email Field (ReadOnly or Editable) ---
                    TextFormField(
                      initialValue: email,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        hintText: "Enter your email",
                        suffixIcon: Icon(Icons.email),
                      ),
                      onSaved: (newValue) => email = newValue,
                    ),
                    const SizedBox(height: 20),

                    // --- Mobile Field ---
                    TextFormField(
                      initialValue: mobileNumber,
                      decoration: const InputDecoration(
                        labelText: "Mobile Number",
                        hintText: "Enter your mobile",
                        suffixIcon: Icon(Icons.phone),
                      ),
                      onSaved: (newValue) => mobileNumber = newValue,
                    ),
                    const SizedBox(height: 40),

                    // --- Save Button ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: _updateProfile,
                        child: const Text(
                          "Save Changes",
                          style: TextStyle(fontSize: 18, color: Colors.white),
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
