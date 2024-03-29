import 'package:flutter_test/flutter_test.dart';
import 'package:dice_roller/app.dart';
import 'package:dice_roller/src/player_progress/persistence/memory_player_progress_persistence.dart';
import 'package:dice_roller/src/settings/persistence/memory_settings_persistence.dart';

void main() {
  testWidgets('smoke test', (tester) async {
    // Build our game and trigger a frame.
    await tester.pumpWidget(MainApp(
      settingsPersistence: MemoryOnlySettingsPersistence(),
      playerProgressPersistence: MemoryOnlyPlayerProgressPersistence(),
      adsController: null,
      gamesServicesController: null,
      inAppPurchaseController: null,
    ));

    // Verify that the 'Play' button is shown.
    expect(find.text('Play'), findsOneWidget);

    // Verify that the 'Settings' button is shown.
    expect(find.text('Settings'), findsOneWidget);

    // Go to 'Settings'.
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Music'), findsOneWidget);

    // Go back to main menu.
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    // Tap 'Play'.
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(find.text('Select level'), findsOneWidget);

    // Tap level 1.
    await tester.tap(find.text('Level #1'));
    await tester.pumpAndSettle();

    // Find the first level's "tutorial" text.
    expect(find.text('Drag the slider to 5% or above!'), findsOneWidget);
  });
}
