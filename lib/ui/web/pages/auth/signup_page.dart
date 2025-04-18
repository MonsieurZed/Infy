import 'package:flutter/material.dart';
import 'package:infy/contants/strings.dart';
import 'package:infy/providers/user_provider.dart';
import 'package:infy/ui/web/pages/auth/login_page.dart';
import 'package:infy/ui/web/widgets/web_logo_widget.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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

  Future<void> _handleSignup() async {
    // Validate form before proceeding
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

    // Prepare data
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Use UserProvider to register the new user
      await context.read<UserProvider>().signUp(
        email,
        password,
        firstName,
        lastName,
      );

      // Check if registration was successful
      if (context.read<UserProvider>().status == AuthStatus.authenticated &&
          mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.accountCreated)),
        );

        // Navigate to login page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      // Error is already handled by UserProvider
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
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
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
                    const WebLogoWidget(size: 90),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.createAccount,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),

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
                            children: [
                              // Name fields row (side by side on larger screens)
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  if (constraints.maxWidth > 500) {
                                    // Side by side for wider screens
                                    return Row(
                                      children: [
                                        Expanded(child: _buildFirstNameField()),
                                        const SizedBox(width: 16),
                                        Expanded(child: _buildLastNameField()),
                                      ],
                                    );
                                  } else {
                                    // Stacked for narrower screens
                                    return Column(
                                      children: [
                                        _buildFirstNameField(),
                                        const SizedBox(height: 16),
                                        _buildLastNameField(),
                                      ],
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 16),

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
                                textInputAction: TextInputAction.next,
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
                              const SizedBox(height: 16),

                              // Confirm Password field
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: InputDecoration(
                                  labelText: AppStrings.confirmPasswordLabel,
                                  hintText: AppStrings.confirmPasswordHint,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.lock_outlined),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _obscureConfirmPassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleSignup(),
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
                              const SizedBox(height: 24),

                              // Signup button
                              userProvider.isLoading || _isLoading
                                  ? const CircularProgressIndicator()
                                  : FilledButton(
                                    onPressed: _handleSignup,
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                    ),
                                    child: const Text(
                                      AppStrings.signupButton,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                              const SizedBox(height: 16),

                              // Login link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(AppStrings.alreadyHaveAccount),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const LoginPage(),
                                        ),
                                      );
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
          ),
        ),
      ),
    );
  }

  Widget _buildFirstNameField() {
    return TextFormField(
      controller: _firstNameController,
      decoration: InputDecoration(
        labelText: AppStrings.firstNameLabel,
        hintText: AppStrings.firstNameHint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: const Icon(Icons.person_outline),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.firstNameRequired;
        }
        return null;
      },
    );
  }

  Widget _buildLastNameField() {
    return TextFormField(
      controller: _lastNameController,
      decoration: InputDecoration(
        labelText: AppStrings.lastNameLabel,
        hintText: AppStrings.lastNameHint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: const Icon(Icons.person_outline),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.lastNameRequired;
        }
        return null;
      },
    );
  }
}
