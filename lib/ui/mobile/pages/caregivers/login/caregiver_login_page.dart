import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:provider/provider.dart';
import 'package:infy/contants/constants.dart';
import 'package:infy/contants/strings.dart';
import 'package:infy/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences
import 'package:infy/ui/mobile/pages/caregivers/login/caregiver_loading_page.dart';
import 'package:infy/ui/mobile/pages/caregivers/login/caregiver_signup_page.dart'; // Import for the signup page
import 'package:infy/ui/mobile/pages/caregivers/widget_tree.dart';
import 'package:infy/ui/mobile/widgets/logo_hero_widget.dart';
import 'package:infy/ui/mobile/pages/caregivers/login/caregiver_reset_password_page.dart'; // Import for the reset page

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
  bool obscurePassword = true; // For password visibility toggle

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(PrefsString.savedEmail);
    final savedPassword = prefs.getString(PrefsString.savedPassword);
    final savedRememberMe = prefs.getBool(PrefsString.rememberMe) ?? false;

    if (savedRememberMe && savedEmail != null && savedPassword != null) {
      setState(() {
        emailController.text = savedEmail;
        passwordController.text = savedPassword;
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
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: AppStrings.emailLabel,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
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
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: obscurePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleLogin(context),
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
                      userProvider.isLoading
                          ? const CircularProgressIndicator()
                          : FilledButton(
                            onPressed: () => _handleLogin(context),
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

  Future<void> _handleLogin(BuildContext context) async {
    // Validate inputs before showing loading indicator
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    debugPrint('_handleLogin: Email: $email, Password: [hidden]');

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.enterAllFields)));
      debugPrint('_handleLogin: Empty fields detected');
      return;
    }

    // Show loading only after validation passes
    setState(() {
      isLoading = true;
    });
    debugPrint('_handleLogin: Set isLoading to true');

    try {
      debugPrint('_handleLogin: Attempting to sign in...');
      // Use UserProvider for authentication
      await context.read<UserProvider>().signIn(email, password);
      debugPrint('_handleLogin: signIn completed');

      // Save credentials if "Remember Me" is checked
      await _saveCredentials();
      debugPrint('_handleLogin: Credentials saved if needed');

      // Get the current user provider state using read instead of Provider.of for efficiency
      final userProvider = context.read<UserProvider>();
      debugPrint('_handleLogin: User status: ${userProvider.status}');

      // Check authentication status properly
      if (userProvider.status == AuthStatus.authenticated) {
        debugPrint('_handleLogin: Authentication successful, adding delay');
        // Ensure Firebase Auth is fully updated by adding a small delay
        // Use a Timer instead of Future.delayed to avoid blocking the UI thread
        Future.microtask(() async {
          await Future.delayed(const Duration(milliseconds: 500));

          if (!mounted) return;

          // Double-check Firebase authentication state
          final firebaseUser = FirebaseAuth.instance.currentUser;
          debugPrint('_handleLogin: Firebase user: ${firebaseUser?.uid}');

          if (firebaseUser != null && mounted) {
            debugPrint('_handleLogin: Navigating to WidgetTree');
            // Navigate to main app if authenticated
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const WidgetTree()),
              (route) => false,
            );
          } else if (mounted) {
            debugPrint('_handleLogin: Navigating to CaregiverLoadingPage');
            // If Firebase auth isn't ready yet, show a loading page temporarily
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CaregiverLoadingPage(),
              ),
            );
          }
        });
      } else if (userProvider.error != null) {
        // Show error if there is one
        debugPrint('_handleLogin: Authentication error: ${userProvider.error}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(userProvider.error!)));
      } else {
        debugPrint('_handleLogin: No error but not authenticated either');
      }
    } catch (e) {
      // Show error in case there's an exception not caught by UserProvider
      debugPrint('Login error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        debugPrint('_handleLogin: Set isLoading to false');
      }
    }
  }
}
