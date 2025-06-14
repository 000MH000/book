import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_project_bookstore/core/theme/theme_provider.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile_app_project_bookstore/features/user_profile/presentation/providers/user_profile_providers.dart';
import 'faq_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  final List<String> allGenres = [
    'Fiction', 'Mystery', 'Romance', 'Sci-Fi', 'Fantasy',
    'Biography', 'Self-Help', 'History', 'Thriller'
  ];
  List<String> selectedGenres = [];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _displayNameController = TextEditingController(text: user?.displayName ?? '');
    if (user != null) {
      _loadUserProfile(user.uid);
    }
  }

  Future<void> _loadUserProfile(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && mounted) {
        setState(() {
          selectedGenres = List<String>.from(data['favoriteGenres'] ?? []);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authControllerState = ref.watch(authControllerProvider);
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    final currentTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (user != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          user.displayName?.isNotEmpty == true
                              ? user.displayName!.substring(0, 1).toUpperCase()
                              : (user.email?.substring(0, 1).toUpperCase() ?? 'U'),
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(labelText: 'Display Name'),
                      ),
                      const SizedBox(height: 8),
                      Text(user.email ?? 'No email', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text('Favorite Genres', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            Wrap(
              spacing: 8,
              children: allGenres.map((genre) {
                final selected = selectedGenres.contains(genre);
                return FilterChip(
                  label: Text(genre),
                  selected: selected,
                  onSelected: (bool value) {
                    setState(() {
                      if (value) {
                        selectedGenres.add(genre);
                      } else {
                        selectedGenres.remove(genre);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Settings', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            ListTile(
              title: const Text('App Theme'),
              subtitle: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                  ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.settings)),
                ],
                selected: {currentTheme},
                onSelectionChanged: (newSelection) {
                  ref.read(themeNotifierProvider.notifier).setTheme(newSelection.first);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & FAQ'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FAQScreen()),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
              onPressed: () async {
                final newName = _displayNameController.text.trim();
                final uid = user?.uid;
                if (uid != null && newName.isNotEmpty) {
                  await user!.updateDisplayName(newName);
                  await ref.read(userProfileRepositoryProvider).createUserProfile(
                    uid: uid,
                    email: user.email!,
                    displayName: newName,
                    favoriteGenres: selectedGenres,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: authControllerState.isLoading
                  ? null
                  : () {
                ref.read(authControllerProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
