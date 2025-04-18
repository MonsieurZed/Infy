import 'package:flutter/material.dart';
import 'package:infy/contants/strings.dart';
import 'package:infy/providers/user_provider.dart';
import 'package:infy/ui/web/pages/auth/login_page.dart';
import 'package:infy/ui/web/pages/patients/patients_page.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final List<String> _pageNames = [
    'Tableau de bord',
    'Patients',
    'Soins',
    'Planning',
    'Statistiques',
    'Paramètres',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Barre latérale
          _buildSidebar(),

          // Contenu principal
          Expanded(
            child: Column(
              children: [
                // En-tête avec recherche et profil
                _buildHeader(),

                // Contenu de la page
                Expanded(child: _buildPageContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Construction de la barre latérale
  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Logo et titre de l'application
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medical_services,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.appTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Options de navigation
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(0, Icons.dashboard_outlined, 'Tableau de bord'),
                _buildNavItem(
                  1,
                  Icons.people_alt_outlined,
                  AppStrings.patientLabel,
                ),
                _buildNavItem(
                  2,
                  Icons.medical_services_outlined,
                  AppStrings.careListTitle,
                ),
                _buildNavItem(
                  3,
                  Icons.calendar_today_outlined,
                  AppStrings.planning,
                ),
                _buildNavItem(4, Icons.bar_chart_outlined, 'Statistiques'),
                const Divider(),
                _buildNavItem(5, Icons.settings_outlined, AppStrings.settings),
              ],
            ),
          ),

          // Informations utilisateur et déconnexion
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 16),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final user = userProvider.user;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          (user?.firstName.isNotEmpty == true
                                  ? user!.firstName[0]
                                  : '') +
                              (user?.lastName.isNotEmpty == true
                                  ? user!.lastName[0]
                                  : ''),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                      ),
                      subtitle: Text(user?.email ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () => _handleSignOut(context),
                        tooltip: AppStrings.logout,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Élément de navigation dans la barre latérale
  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
      title: Text(
        title,
        style: TextStyle(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primaryContainer.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  // En-tête avec barre de recherche et profil
  Widget _buildHeader() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2),
        ],
      ),
      child: Row(
        children: [
          // Titre de la page
          Text(
            _pageNames[_selectedIndex],
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Spacer(),

          // Barre de recherche
          Container(
            width: 300,
            height: 45,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Notifications
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
        ],
      ),
    );
  }

  // Contenu principal qui change en fonction de la section sélectionnée
  Widget _buildPageContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const PatientsPage();
      case 2:
        return _buildPlaceholderContent('Gestion des soins');
      case 3:
        return _buildPlaceholderContent('Planning des rendez-vous');
      case 4:
        return _buildPlaceholderContent('Statistiques et rapports');
      case 5:
        return _buildPlaceholderContent('Paramètres');
      default:
        return _buildDashboardContent();
    }
  }

  // Contenu du tableau de bord
  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cartes de statistiques
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildStatsCard(
                  Icons.people,
                  'Patients actifs',
                  '42',
                  Colors.blue,
                  '+5% cette semaine',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildStatsCard(
                  Icons.calendar_today,
                  'Rdv aujourd\'hui',
                  '12',
                  Colors.orange,
                  '3 en attente',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildStatsCard(
                  Icons.check_circle_outline,
                  'Soins terminés',
                  '156',
                  Colors.green,
                  'Ce mois-ci',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildStatsCard(
                  Icons.medical_services,
                  'Nouveaux soins',
                  '28',
                  Colors.purple,
                  'Cette semaine',
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Activité récente et prochains rendez-vous
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Activité récente
              Expanded(
                flex: 3,
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Activité récente',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const Divider(height: 1),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getRandomColor(index),
                              child: Icon(
                                _getRandomIcon(index),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(_getRandomActivity(index)),
                            subtitle: Text(
                              'Il y a ${index + 1} heure${index > 0 ? 's' : ''}',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // Prochains rendez-vous
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Prochains rendez-vous',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const Divider(height: 1),
                      for (var i = 0; i < 4; i++)
                        _buildAppointmentItem(
                          name: 'Patient ${i + 1}',
                          time: '${10 + i}:00',
                          type: _getAppointmentType(i),
                          color: _getRandomColor(i),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Tâches à faire
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Tâches à faire',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Divider(height: 1),
                for (var i = 0; i < 5; i++)
                  CheckboxListTile(
                    value: i % 3 == 0,
                    onChanged: (val) {},
                    title: Text('Tâche de soin ${i + 1}'),
                    subtitle: Text('Date limite: ${i + 20}/04/2025'),
                    secondary: CircleAvatar(
                      backgroundColor: _getRandomColor(i),
                      radius: 16,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Contenu d'espace réservé pour les onglets non implémentés
  Widget _buildPlaceholderContent(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Cette section est en cours de développement.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Revenir au tableau de bord'),
            onPressed: () {
              setState(() {
                _selectedIndex = 0;
              });
            },
          ),
        ],
      ),
    );
  }

  // Carte de statistiques pour le dashboard
  Widget _buildStatsCard(
    IconData icon,
    String title,
    String value,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const Spacer(),
                Icon(
                  Icons.more_vert,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                subtitle,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Élément de rendez-vous
  Widget _buildAppointmentItem({
    required String name,
    required String time,
    required String type,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                type,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Méthodes utilitaires pour la génération de données de démonstration
  Color _getRandomColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  IconData _getRandomIcon(int index) {
    final icons = [
      Icons.person_add,
      Icons.medical_services,
      Icons.edit_document,
      Icons.calendar_today,
      Icons.check_circle,
    ];
    return icons[index % icons.length];
  }

  String _getRandomActivity(int index) {
    final activities = [
      'Nouveau patient ajouté',
      'Soin complété pour Patient 3',
      'Rendez-vous modifié pour Patient 8',
      'Rapport de soin ajouté',
      'Nouveau message reçu',
    ];
    return activities[index % activities.length];
  }

  String _getAppointmentType(int index) {
    final types = [
      'Consultation initiale',
      'Suivi de traitement',
      'Examen complet',
      'Consultation de routine',
    ];
    return types[index % types.length];
  }

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await context.read<UserProvider>().signOut();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${AppStrings.logoutError}: $e')));
    }
  }
}
