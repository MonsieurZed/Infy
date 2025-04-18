import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:infy/contants/constants.dart';
import 'package:infy/contants/strings.dart';
import 'package:infy/providers/user_provider.dart';
import 'package:infy/ui/web/pages/auth/reset_password_page.dart';
import 'package:infy/ui/web/pages/auth/signup_page.dart';
import 'package:infy/ui/web/pages/dashboard/dashboard_page.dart';
import 'package:infy/ui/web/pages/home_page.dart';
import 'package:infy/ui/web/widgets/web_logo_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;

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
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = savedRememberMe;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString(PrefsString.savedEmail, _emailController.text);
      await prefs.setString(
        PrefsString.savedPassword,
        _passwordController.text,
      );
      await prefs.setBool(PrefsString.rememberMe, true);
    } else {
      await prefs.remove(PrefsString.savedEmail);
      await prefs.remove(PrefsString.savedPassword);
      await prefs.setBool(PrefsString.rememberMe, false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      // Use UserProvider for authentication
      await context.read<UserProvider>().signIn(email, password);

      // Save credentials if "Remember Me" is checked
      await _saveCredentials();

      // Get the current user provider state
      final userProvider = context.read<UserProvider>();

      // Check authentication status
      if (userProvider.status == AuthStatus.authenticated && mounted) {
        // Ensure Firebase Auth is fully updated
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // Double-check Firebase authentication state
        final firebaseUser = FirebaseAuth.instance.currentUser;

        if (firebaseUser != null && mounted) {
          // Navigate to dashboard if authenticated
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      // Error is handled by UserProvider, but we can add additional error handling if needed
      debugPrint('Login error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          },
          tooltip: AppStrings.backToHome,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 450,
            ), // Légèrement plus large
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const WebLogoWidget(size: 100),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.welcomeBack,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 32),

                    // Auth errors listener
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        if (userProvider.error != null && !_isLoading) {
                          // Show error if there is one
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(userProvider.error!)),
                            );
                          });
                        }
                        return Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email field
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: AppStrings.emailLabel,
                                  hintText: AppStrings.emailHint,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.email_outlined),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppStrings.emailRequired;
                                  }
                                  if (!value.contains('@') ||
                                      !value.contains('.')) {
                                    return AppStrings.invalidEmailError;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password field
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: AppStrings.passwordLabel,
                                  hintText: AppStrings.passwordHint,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleLogin(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppStrings.passwordRequired;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Row for Remember me and Forgot password
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                  ),
                                  const Text(AppStrings.rememberMe),
                                ],
                              ),

                              // Separate row for forgot password to avoid overflow
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const ResetPasswordPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(AppStrings.forgotPassword),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Login button
                              userProvider.isLoading || _isLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : FilledButton(
                                    onPressed: _handleLogin,
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                    ),
                                    child: const Text(
                                      AppStrings.loginButton,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                              const SizedBox(height: 20),

                              // Signup link
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
                                              (context) => const SignupPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(AppStrings.signupButton),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Back to home button
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomePage(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                icon: const Icon(Icons.home),
                                label: const Text(AppStrings.backToHome),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
