import 'package:flutter/foundation.dart';
import 'package:dice_roller/src/level_selection/dice_game_levels.dart';

class DiceGameLevelState extends ChangeNotifier {
  DiceGameLevelState({required this.level, required this.onWin});

  final DiceGameLevel level;
  final ValueChanged<Iterable<int>> onWin;

  final Map<int, int> _diceValue = {};

  bool get showResults => _diceValue.length == level.dices;

  void showWiningScreen() => onWin(_diceValue.entries.map((e) => e.value));

  void reset() {
    for (var i = 1; i <= level.dices; i++) {
      _diceValue[i] = 0;
    }
  }

  int getDiceValueFor(int number) {
    assert(number >= 1 && number <= 6,
        'Invalid dice number, Range (1-6) inclusive.');
    return _diceValue[number] ?? 1;
  }

  void setDiceValueFor(int number, int value) {
    _diceValue[number] = value;
    notifyListeners();
  }
}
