import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dice_roller/src/audio/audio_controller.dart';
import 'package:dice_roller/src/audio/sounds.dart';
import 'package:dice_roller/src/games_services/games_services.dart';
import 'package:dice_roller/src/router/router.dart';
import 'package:dice_roller/src/settings/settings.dart';
import 'package:dice_roller/src/style/palette.dart';
import 'package:dice_roller/src/style/responsive_screen.dart';
import 'package:dice_roller/src/style/rough_button.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var palette = context.read<Palette>();
    var audioController = context.watch<AudioController>();
    var settingsController = context.watch<SettingsController>();
    var gamesServicesController = context.watch<GamesServicesController?>();
    const spacer10 = SizedBox(height: 10);

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: ResponsiveScreen(
        mainAreaProminence: 0.45,
        mainSlot: Center(
          child: Transform.rotate(
            angle: -0.1,
            child: const Text(
              'The Dice Roller!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 55, height: 1),
            ),
          ),
        ),
        bottomSlot: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          RoughButton(
            onTap: () {
              const PlayRoute().go(context);
              audioController.playSfx(SfxType.buttonTap);
            },
            child: const Text('Play'),
          ),
          spacer10,
          if (gamesServicesController != null) ...[
            _hideUntilReady(
              ready: gamesServicesController.signedIn,
              child: RoughButton(
                onTap: gamesServicesController.showAchievements,
                child: const Text('Achievements'),
              ),
            ),
            spacer10,
            _hideUntilReady(
              ready: gamesServicesController.signedIn,
              child: RoughButton(
                onTap: gamesServicesController.showLeaderboard,
                child: const Text('Leaderboard'),
              ),
            ),
            spacer10,
          ],
          RoughButton(
            // Pass -1 as a level if called from main menu screen,
            // this will allow to continue running session (if any).
            onTap: () => const GameRulesRoute(level: -1).go(context),
            child: const Text('Game Rules'),
          ),
          spacer10,
          RoughButton(
            // Pass -1 as a level if called from main menu screen,
            // this will allow to continue running session (if any).
            onTap: () => const SettingsRoute(level: -1).go(context),
            child: const Text('Settings'),
          ),
          const SizedBox(height: 40),
          ValueListenableBuilder<bool>(
            valueListenable: settingsController.muted,
            builder: (context, muted, child) => RoughButton(
              onTap: settingsController.toggleMuted,
              fillColor: muted ? palette.backgroundMain : palette.redPen,
              child: Icon(muted ? Icons.volume_off : Icons.volume_up, size: 30),
            ),
          ),
          spacer10,
        ]),
      ),
    );
  }
}

extension on MainMenuScreen {
  /// Prevents the game from showing game-services-related menu items
  /// until we're sure the player is signed in.
  ///
  /// This normally happens immediately after game start, so players will not
  /// see any flash. The exception is folks who decline to use Game Center
  /// or Google Play Game Services, or who haven't yet set it up.
  Widget _hideUntilReady({required Widget child, required Future<bool> ready}) {
    return FutureBuilder<bool>(
      future: ready,
      // Use Visibility here so that we have
      // the space for the buttons ready.
      builder: (context, snapshot) => Visibility(
        visible: snapshot.data ?? false,
        maintainState: true,
        maintainSize: true,
        maintainAnimation: true,
        child: child,
      ),
    );
  }
}
