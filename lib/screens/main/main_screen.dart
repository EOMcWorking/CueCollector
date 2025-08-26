import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/person_card.dart';
import '../../widgets/add_person_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataProvider>(context, listen: false).loadPeople();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cue Collector'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => _showProfileMenu(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search people...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          final filteredPeople = dataProvider.people
              .where((person) => person.name.toLowerCase().contains(_searchQuery))
              .toList();

          if (filteredPeople.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty ? 'No people added yet' : 'No people found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isEmpty 
                        ? 'Tap the + button to add your first person'
                        : 'Try a different search term',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredPeople.length,
            itemBuilder: (context, index) {
              final person = filteredPeople[index];
              return PersonCard(
                person: person,
                onTap: () => context.go('/person/${person.id}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPersonDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return UserAccountsDrawerHeader(
                accountName: Text(authProvider.currentUserName ?? 'User'),
                accountEmail: const Text('Cue Collector'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    (authProvider.currentUserName ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('People'),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.psychology),
            title: const Text('Cue'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to cue overview
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_run),
            title: const Text('Activity'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to activity overview
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Assets'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to assets overview
            },
          ),
          ListTile(
            leading: const Icon(Icons.timeline),
            title: const Text('Review'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to review section
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  child: Text(
                    (authProvider.currentUserName ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  authProvider.currentUserName ?? 'User',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign Out'),
                  onTap: () {
                    Navigator.pop(context);
                    _signOut(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddPersonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddPersonDialog(),
    );
  }

  void _signOut(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false).signOut();
  }
}
