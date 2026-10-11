import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/library_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import 'about_screen.dart';
import 'continue_watching_screen.dart';
import 'library_screen.dart';
import 'settings_screen.dart';

/// Root shell with the four AniLoom destinations. Uses an [IndexedStack] so
/// scroll position and state are preserved between tabs.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final LibraryState state = context.watch<LibraryState>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: BrandHeader(showSubtitle: _index == 0),
        actions: <Widget>[
          if (_index != 1 && state.totalVideos > 0)
            Center(
              child: Pill(
                label: '${state.totalVideos} videos',
                color: AppTheme.accent2,
              ),
            ),
          const SizedBox(width: 12),
          const Center(child: OfflineChip()),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _index,
          children: <Widget>[
            ContinueWatchingScreen(
              onOpenLibrary: () => setState(() => _index = 1),
            ),
            const LibraryScreen(),
            const SettingsScreen(),
            const AboutScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int i) => setState(() => _index = i),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline_rounded),
            selectedIcon: Icon(Icons.play_circle_fill_rounded),
            label: 'Watching',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library_rounded),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline_rounded),
            selectedIcon: Icon(Icons.info_rounded),
            label: 'About',
          ),
        ],
      ),
    );
  }
}
