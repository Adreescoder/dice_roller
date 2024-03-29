import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:dice_roller/src/player_progress/persistence/player_progress_persistence.dart';

/// Encapsulates the player's progress.
class PlayerProgress extends ChangeNotifier {
  /// Creates an instance of [PlayerProgress] backed by an injected
  /// persistence [store].
  PlayerProgress(PlayerProgressPersistence store) : _store = store;

  final PlayerProgressPersistence _store;

  static const maxHighestScoresPerPlayer = 0;

  int _highestLevelReached = 0;

  /// The highest level that the player has reached so far.
  int get highestLevelReached => _highestLevelReached;

  /// Fetches the latest data from the backing persistence store.
  Future<void> getLatestFromStore() async {
    var level = await _store.getHighestLevelReached();
    if (level > _highestLevelReached) {
      _highestLevelReached = level;
      notifyListeners();
    } else if (level < _highestLevelReached) {
      await _store.saveHighestLevelReached(_highestLevelReached);
    }
  }

  /// Resets the player's progress so it's like if they just started
  /// playing the game for the first time.
  void reset() {
    _highestLevelReached = 0;
    notifyListeners();
    _store.saveHighestLevelReached(_highestLevelReached);
  }

  /// Registers [level] as reached.
  ///
  /// If this is higher than [highestLevelReached], it will update that
  /// value and save it to the injected persistence store.
  void setLevelReached(int level) {
    if (level > _highestLevelReached) {
      _highestLevelReached = level;
      notifyListeners();
      unawaited(_store.saveHighestLevelReached(level));
    }
  }
}
