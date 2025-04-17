import 'package:flutter/material.dart';
import 'package:infy/data/utils/app_logger.dart';
import 'package:provider/provider.dart';
import 'package:infy/data/contants/strings.dart';
import 'package:infy/data/providers/user_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isInitialized = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only initialize data once to avoid repeated calls
    if (!_isInitialized) {
      _initUserData();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _initUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
    }
  }

  Future<void> _saveProfile() async {
    // Validate form first and return early if invalid, before any UI update
    if (!_formKey.currentState!.validate()) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    // Get user provider with listen: false to avoid rebuilds
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;

    if (user == null) {
      AppLogger.snackbar(context, AppStrings.userNotLoggedIn);
      return;
    }

    // Show loading indicator only after validation is complete
    setState(() {
      _isSaving = true;
    });

    try {
      // Use isolated operation for profile update
      await userProvider.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.profileUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.errorUpdatingProfile}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.logout,
            onPressed: () async {
              try {
                await Provider.of<UserProvider>(
                  context,
                  listen: false,
                ).signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/welcome');
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${AppStrings.errorLogout}: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = userProvider.user;
          if (user == null) {
            return const Center(child: Text(AppStrings.userNotLoggedIn));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Email (non modifiable)
                  TextFormField(
                    initialValue: user.email,
                    decoration: const InputDecoration(
                      labelText: AppStrings.emailLabel,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    readOnly: true,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),

                  // Prénom
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.firstNameLabel,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.enterFirstName;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Nom
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.lastNameLabel,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.enterLastName;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Date de création
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text(AppStrings.createdAt),
                    subtitle: Text(
                      user.createdAt.toLocal().toString().split('.')[0],
                    ),
                  ),

                  // Date de dernière mise à jour
                  ListTile(
                    leading: const Icon(Icons.update),
                    title: const Text(AppStrings.updatedAt),
                    subtitle: Text(
                      user.updatedAt.toLocal().toString().split('.')[0],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bouton de sauvegarde
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(AppStrings.saveChanges),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
