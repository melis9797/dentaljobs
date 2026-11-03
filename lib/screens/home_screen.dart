import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import '../supabase_client.dart';
import 'blog_tab.dart';
import 'browse_screen.dart';
import 'my_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, _) {
        // Keying by user id resets the tabs when someone signs in or out.
        final userId = supabase.auth.currentUser?.id;
        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: [
              const BrowseScreen(),
              if (blogEnabled) BlogTab(key: ValueKey('blog-$userId')),
              MyScreen(key: ValueKey('my-$userId')),
              ProfileScreen(key: ValueKey('profile-$userId')),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.work_outline),
                selectedIcon: Icon(Icons.work),
                label: 'İlanlar',
              ),
              if (blogEnabled)
                const NavigationDestination(
                  icon: Icon(Icons.forum_outlined),
                  selectedIcon: Icon(Icons.forum),
                  label: 'Blog',
                ),
              const NavigationDestination(
                icon: Icon(Icons.list_alt_outlined),
                selectedIcon: Icon(Icons.list_alt),
                label: 'İlanlarım',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }
}
