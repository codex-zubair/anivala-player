import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchanimetv/main.dart';
import 'package:watchanimetv/services/library_store.dart';
import 'package:watchanimetv/state/library_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AniLoom shows the offline home shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final LibraryStore store = await LibraryStore.open();

    await tester.pumpWidget(AniLoomApp(store: store));
    await tester.pumpAndSettle();

    // Branding and the offline privacy chip are present.
    expect(find.text('AniLoom'), findsWidgets);
    expect(find.text('Offline'), findsOneWidget);

    // Continue Watching is the default tab and starts empty.
    expect(find.text('Nothing in progress'), findsOneWidget);

    // All four destinations exist in the bottom bar.
    expect(find.text('Watching'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
  });

  testWidgets('switching to the Library tab shows the empty scan state',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final LibraryStore store = await LibraryStore.open();

    await tester.pumpWidget(AniLoomApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();

    expect(find.text('No videos yet'), findsOneWidget);
    expect(find.text('Scan device'), findsWidgets);
  });

  testWidgets('About tab exposes the privacy policy button',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final LibraryStore store = await LibraryStore.open();

    await tester.pumpWidget(AniLoomApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.text('Read Privacy Policy'), findsOneWidget);
    expect(find.text('Private by design'), findsOneWidget);
  });

  test('LibraryState starts empty and loaded', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final LibraryStore store = await LibraryStore.open();
    final LibraryState state = LibraryState(store);
    await state.load();
    expect(state.loaded, isTrue);
    expect(state.library, isEmpty);
    expect(state.continueWatching, isEmpty);
  });
}
