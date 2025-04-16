import 'package:flutter/material.dart';
import 'package:infy/data/contants/strings.dart';
import 'package:infy/data/providers/user_provider.dart';
import 'package:infy/views/pages/caregivers/login/caregiver_login_page.dart';
import 'package:infy/views/widgets/logo_hero_widget.dart';
import 'package:provider/provider.dart';

class CaregiverSignupPage extends StatefulWidget {
  const CaregiverSignupPage({super.key});

  @override
  State<CaregiverSignupPage> createState() => _CaregiverSignupPageState();
}

class _CaregiverSignupPageState extends State<CaregiverSignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _onSignupButtonPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Verify passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.passwordsDoNotMatch)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the UserProvider to register
      await Provider.of<UserProvider>(context, listen: false).signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
      );

      // Check if registration was successful by examining the user's status
      if (context.read<UserProvider>().status == AuthStatus.authenticated) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.accountCreated)),
          );

          // Navigate to login page or directly to the main app
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      }
      // If we're here but not authenticated, UserProvider.error should contain the error
    } catch (e) {
      // Error is already handled by UserProvider and displayed via Consumer
      // Just log the error for debugging
      debugPrint('Signup error: $e');
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
      appBar: AppBar(title: const Text(AppStrings.signupTitle)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LogoHeroWidget(),
              const SizedBox(height: 30),

              // Écouter les erreurs du UserProvider
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  if (userProvider.error != null && !_isLoading) {
                    // Afficher l'erreur s'il y en a une
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(userProvider.error!)),
                      );
                    });
                  }
                  return Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Prénom
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: AppStrings.firstNameLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.firstNameRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Nom de famille
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: AppStrings.lastNameLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.lastNameRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: AppStrings.emailLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.emailRequired;
                            }
                            // Simple email validation
                            if (!value.contains('@') || !value.contains('.')) {
                              return AppStrings.invalidEmailError;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Mot de passe
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: AppStrings.passwordLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.passwordRequired;
                            }
                            if (value.length < 6) {
                              return AppStrings.passwordTooShort;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Confirmation du mot de passe
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: AppStrings.confirmPasswordLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.confirmPasswordRequired;
                            }
                            if (value != _passwordController.text) {
                              return AppStrings.passwordsDoNotMatch;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25),

                        // Bouton d'inscription
                        userProvider.isLoading || _isLoading
                            ? const CircularProgressIndicator()
                            : FilledButton(
                              onPressed: _onSignupButtonPressed,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                AppStrings.signupButton,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                        const SizedBox(height: 15),

                        // Lien vers la page de connexion
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(AppStrings.alreadyHaveAccount),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(AppStrings.loginButton),
                            ),
                          ],
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
    );
  }
}
