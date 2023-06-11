import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dice_roller/src/audio/audio_controller.dart';
import 'package:dice_roller/src/audio/sounds.dart';
import 'package:dice_roller/src/level_selection/dice_game_levels.dart';
import 'package:dice_roller/src/player_progress/player_progress.dart';
import 'package:dice_roller/src/router/router.dart';
import 'package:dice_roller/src/style/palette.dart';
import 'package:dice_roller/src/style/responsive_screen.dart';
import 'package:dice_roller/src/style/rough_button.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var palette = context.read<Palette>();
    var progress = context.watch<PlayerProgress>();

    return Scaffold(
      backgroundColor: palette.backgroundLevelSelection,
      body: ResponsiveScreen(
        topSlot: const Text('Select level', style: TextStyle(fontSize: 30)),
        mainSlot: ListView.separated(
          itemCount: diceGameLevels.length,
          separatorBuilder: (context, index) {
            return const SizedBox(height: 5);
          },
          itemBuilder: (context, index) {
            var level = diceGameLevels.elementAt(index);
            return RoughButton(
              enabled: progress.highestLevelReached >= level.number - 1,
              fillColor: palette.backgroundSettings,
              onTap: () {
                context.read<AudioController>().playSfx(SfxType.buttonTap);
                PlaySessionRoute(level: level.number).go(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    level.number.toString(),
                    style: const TextStyle(fontSize: 22),
                  ),
                  Text('Level #${level.number}'),
                  Text('Dices: ${level.dices} | Sides: ${level.sides}'),
                ],
              ),
            );
          },
        ),
        bottomSlot: RoughButton(onTap: context.pop, child: const Text('Back')),
      ),
    );
  }
}
