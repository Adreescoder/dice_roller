enum SfxType { huhsh, wssh, buttonTap, congrats, erase, swishSwish }

List<String> soundTypeToFilename(SfxType type) => switch (type) {
      SfxType.huhsh => const [],
      SfxType.wssh => const [],
      SfxType.buttonTap => const [],
      SfxType.congrats => const [],
      SfxType.erase => const [],
      SfxType.swishSwish => const [],
    };

/// Allows control over loudness of different SFX types.
double soundTypeToVolume(SfxType type) => switch (type) {
      SfxType.huhsh => 0.4,
      SfxType.wssh => 0.2,
      SfxType.buttonTap ||
      SfxType.congrats ||
      SfxType.erase ||
      SfxType.swishSwish =>
        1,
    };
