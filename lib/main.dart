import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/root_shell.dart';
import 'services/library_store.dart';
import 'state/library_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final LibraryStore store = await LibraryStore.open();
  runApp(AniLoomApp(store: store));
}

/// AniLoom — a fully offline, ad-free local anime & video player.
class AniLoomApp extends StatelessWidget {
  const AniLoomApp({super.key, required this.store, this.state});

  final LibraryStore store;
  final LibraryState? state;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LibraryState>(
      create: (_) => (state ?? LibraryState(store))..load(),
      child: MaterialApp(
        title: 'AniLoom',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const RootShell(),
      ),
    );
  }
}
