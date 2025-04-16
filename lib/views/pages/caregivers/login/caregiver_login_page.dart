import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infy/data/contants/constants.dart';
import 'package:infy/data/contants/strings.dart';
import 'package:infy/data/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences
import 'package:infy/private.folder/private.key.dart';
import 'package:infy/views/pages/caregivers/login/caregiver_loading_page.dart';
import 'package:infy/views/pages/caregivers/login/caregiver_signup_page.dart'; // Import for the signup page
import 'package:infy/views/pages/caregivers/widget_tree.dart';
import 'package:infy/views/widgets/logo_hero_widget.dart';
import 'package:infy/views/pages/caregivers/login/caregiver_reset_password_page.dart'; // Import for the reset page

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
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _autoLoginInDebugMode();
    // });
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
        // Utiliser le UserProvider au lieu de FirebaseAuth directement
        await Provider.of<UserProvider>(
          context,
          listen: false,
        ).signIn(PrivateString.login, PrivateString.password);

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
              LogoHeroWidget(),
              const SizedBox(height: 50),
              // Écouter les erreurs du UserProvider
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  if (userProvider.error != null && !isLoading) {
                    // Afficher l'erreur s'il y en a une
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(userProvider.error!)),
                      );
                    });
                  }
                  return Column(
                    children: [
                      // ...Le reste du contenu...
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
                      userProvider.isLoading || isLoading
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
                      const SizedBox(height: 15),
                      // Lien vers la page d'inscription
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(AppStrings.dontHaveAccount),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const CaregiverSignupPage(),
                                ),
                              );
                            },
                            child: const Text(AppStrings.signupButton),
                          ),
                        ],
                      ),
                    ],
                  );
                },
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
      // Utiliser le UserProvider pour la connexion
      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).signIn(email.trim(), password.trim());

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
    } catch (e) {
      // L'erreur est déjà gérée par le UserProvider
      debugPrint('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
