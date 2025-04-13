import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infy/data/constants.dart';
import 'package:infy/data/strings.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences
import 'package:infy/data/private.key.dart';
import 'package:infy/views/pages/nurse/login/loading_page.dart';
import 'package:infy/views/pages/nurse/widget_tree.dart';
import 'package:infy/views/widgets/hero_widget.dart';
import 'package:infy/views/pages/nurse/login/reset_password_page.dart'; // Import for the reset page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool rememberMe = false; // State for "Remember Me"

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _autoLoginInDebugMode();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(PrefsString.savedEmail);
    final savedPassword = prefs.getString(PrefsString.savedPassword);
    final savedRememberMe = prefs.getBool(PrefsString.rememberMe) ?? false;

    if (savedRememberMe) {
      setState(() {
        emailController.text = savedEmail ?? '';
        passwordController.text = savedPassword ?? '';
        rememberMe = savedRememberMe;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString(PrefsString.savedEmail, emailController.text);
      await prefs.setString(PrefsString.savedPassword, passwordController.text);
      await prefs.setBool(PrefsString.rememberMe, true);
    } else {
      await prefs.remove(PrefsString.savedEmail);
      await prefs.remove(PrefsString.savedPassword);
      await prefs.setBool(PrefsString.rememberMe, false);
    }
  }

  Future<void> _autoLoginInDebugMode() async {
    if (kDebugMode) {
      // Automatically log in with the debug account
      setState(() {
        isLoading = true;
      });

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: PrivateString.login, // Debug account email
          password: PrivateString.password, // Debug account password
        );

        // Navigate to the main page after successful login
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoadingPage()),
            (route) => false,
          );
        }
      } catch (e) {
        debugPrint(': $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HeroWidget(title: AppStrings.appTitle),
              const SizedBox(height: 50),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: AppStrings.emailLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: AppStrings.passwordLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.visibility_off),
                    onPressed: () {
                      // Handle password visibility toggle
                    },
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: (value) {
                      setState(() {
                        rememberMe = value ?? false;
                      });
                    },
                  ),
                  const Text(AppStrings.rememberMe),
                ],
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : FilledButton(
                    onPressed: () {
                      onLoginButtonPressed(
                        context,
                        emailController.text,
                        passwordController.text,
                      );
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: const Text(AppStrings.loginButton),
                  ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResetPasswordPage(),
                    ),
                  );
                },
                child: const Text(AppStrings.forgotPassword),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onLoginButtonPressed(
    BuildContext context,
    String email,
    String password,
  ) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Login with Firebase Authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Save credentials if "Remember Me" is checked
      await _saveCredentials();

      // Redirect to the main page after successful login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const WidgetTree();
          },
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      // Display errors
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = AppStrings.userNotFound;
          break;
        case 'wrong-password':
          errorMessage = AppStrings.incorrectPassword;
          break;
        case 'invalid-email':
          errorMessage = AppStrings.invalidEmail;
          break;
        default:
          errorMessage = AppStrings.genericError;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
