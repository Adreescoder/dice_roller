import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';
import 'package:dice_roller/src/ads/ads_controller.dart';
import 'package:dice_roller/src/audio/audio_controller.dart';
import 'package:dice_roller/src/audio/sounds.dart';
import 'package:dice_roller/src/game_internals/dice_game_state.dart';
import 'package:dice_roller/src/games_services/games_services.dart';
import 'package:dice_roller/src/games_services/score.dart';
import 'package:dice_roller/src/in_app_purchase/in_app_purchase.dart';
import 'package:dice_roller/src/level_selection/dice_game_levels.dart';
import 'package:dice_roller/src/play_session/dice_widget.dart';
import 'package:dice_roller/src/player_progress/player_progress.dart';
import 'package:dice_roller/src/router/router.dart';
import 'package:dice_roller/src/settings/settings.dart';
import 'package:dice_roller/src/style/confetti.dart';
import 'package:dice_roller/src/style/palette.dart';
import 'package:dice_roller/src/style/responsive_screen.dart';
import 'package:dice_roller/src/style/rough_button.dart';

class PlaySessionScreen extends StatefulWidget {
  const PlaySessionScreen({super.key, required this.level});

  final DiceGameLevel level;

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen>
    with SingleTickerProviderStateMixin {
  static final _log = Logger('PlaySessionScreen');

  late final AnimationController _animation = AnimationController(
    vsync: this,
    upperBound: 5,
    duration: const Duration(seconds: 3),
  );

  bool _isCelebrating = false;
  bool _showResults = false;
  late DateTime _startOfPlay;

  void _onAnimationEnd(status) {
    if (status == AnimationStatus.completed && mounted) _showResults = true;
  }

  Future<void> _playerWon(diceValues) async {
    _log.info('Level ${widget.level.number} won');

    var score = Score(
      diceValues: diceValues,
      level: widget.level,
      duration: DateTime.now().difference(_startOfPlay),
    );

    // Let the player see the game just after winning for a bit.
    await Future<void>.delayed(const Duration(milliseconds: 500));

    setState(() => _isCelebrating = true);

    if (!mounted) return;

    context.read<PlayerProgress>().setLevelReached(widget.level.number);
    context.read<AudioController>().playSfx(SfxType.congrats);

    var gamesServicesController = context.read<GamesServicesController?>();
    if (gamesServicesController != null) {
      // Award achievement.
      if (widget.level.awardsAchievement) {
        await gamesServicesController.awardAchievement(
          android: widget.level.achievementIdAndroid!,
          iOS: widget.level.achievementIdIOS!,
        );
      }
      // Send score to leaderboard.
      await gamesServicesController.submitLeaderboardScore(score);
    }

    /// Give the player some time to see the celebration animation.
    await Future<void>.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    context.go(const WinGameRoute().location, extra: score);
  }

  @override
  void initState() {
    super.initState();
    _startOfPlay = DateTime.now();
    // Preload ad for the win screen.
    var adsRemoved =
        context.read<InAppPurchaseController?>()?.adRemoval.active ?? false;
    if (!adsRemoved) {
      var adsController = context.read<AdsController?>();
      adsController?.preloadAd();
    }
    _animation.addStatusListener(_onAnimationEnd);
  }

  @override
  void dispose() {
    _animation
      ..removeStatusListener(_onAnimationEnd)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var palette = context.read<Palette>();
    var settings = context.read<SettingsController>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DiceGameLevelState(
            level: widget.level,
            onWin: _playerWon,
          ),
        ),
      ],
      child: IgnorePointer(
        ignoring: _isCelebrating,
        child: Scaffold(
          backgroundColor: palette.backgroundPlaySession,
          body: Stack(children: [
            ResponsiveScreen(
              topSlot: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RoughButton(
                    onTap: () => const PlayRoute().go(context),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/images/cross.png',
                      semanticLabel: 'Close session',
                      width: 30,
                    ),
                  ),
                  RoughButton(
                    onTap: () => GameRulesRoute(
                      // Pass the current level number,
                      // will continue on closing rules screen.
                      level: widget.level.number,
                    ).go(context),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/images/box.png',
                      semanticLabel: 'View game rules',
                      width: 30,
                    ),
                  ),
                  RoughButton(
                    onTap: () => SettingsRoute(
                      // Pass the current level number,
                      // will continue on closing rules screen.
                      level: widget.level.number,
                    ).go(context),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/images/settings.png',
                      semanticLabel: 'Settings',
                      width: 30,
                    ),
                  ),
                ],
              ),
              bottomSlot: Consumer<DiceGameLevelState>(
                builder: (_, state, child) => RoughButton(
                  onTap: () {
                    state.reset();
                    _animation.forward(from: 0);
                  },
                  drawRectangle: true,
                  padding: EdgeInsets.zero,
                  child: const Text(
                    'Roll',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Permanent Marker',
                    ),
                  ),
                ),
              ),
              mainSlot: Column(children: [
                Wrap(spacing: 10, children: [
                  Text(
                    'Player: ${settings.playerName.value}',
                    style: const TextStyle(fontSize: 22),
                  ),
                  Text(
                    'Dices: ${widget.level.dices} |'
                    ' Sides: ${widget.level.sides}',
                    style: const TextStyle(fontSize: 22),
                  ),
                ]),
                const SizedBox(height: 20),
                Consumer<DiceGameLevelState>(builder: (_, state, child) {
                  if (_showResults && !_isCelebrating && state.showResults) {
                    state.showWiningScreen();
                  }
                  return LayoutBuilder(builder: (_, constraints) {
                    var width = constraints.biggest.width;
                    var diceWidth = width ~/ 3.5;
                    return Wrap(
                      alignment: WrapAlignment.spaceAround,
                      children: List.generate(widget.level.dices, (index) {
                        return DiceWidget(
                          animation: _animation,
                          width: diceWidth.toDouble(),
                          sidesPerDice: state.level.sides,
                          diceValue: state.getDiceValueFor(index + 1),
                          onEnd: (value) =>
                              state.setDiceValueFor(index + 1, value),
                        );
                      }),
                    );
                  });
                }),
              ]),
            ),
            Positioned.fill(
              child: Visibility(
                visible: _isCelebrating,
                child: Confetti(isStopped: !_isCelebrating),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
