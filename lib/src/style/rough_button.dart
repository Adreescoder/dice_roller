import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dice_roller/src/audio/audio_controller.dart';
import 'package:dice_roller/src/audio/sounds.dart';
import 'package:dice_roller/src/style/palette.dart';

class RoughButton extends StatelessWidget {
  const RoughButton({
    super.key,
    required this.child,
    required this.onTap,
    this.fillColor,
    this.enabled = true,
    this.drawRectangle = false,
    this.imageName = 'assets/images/bar.png',
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
    this.soundEffect = SfxType.buttonTap,
  });

  final Widget child;
  final Color? fillColor;
  final bool enabled;
  final bool drawRectangle;
  final String imageName;
  final SfxType soundEffect;
  final EdgeInsetsGeometry padding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    var palette = context.read<Palette>();
    return RawMaterialButton(
      onPressed: enabled ? () => _onTapHandle(context) : null,
      padding: padding,
      elevation: 5,
      disabledElevation: 5,
      splashColor: Colors.deepOrange,
      fillColor: enabled
          ? (fillColor ?? palette.backgroundButton)
          : palette.backgroundLevelSelection,
      constraints: const BoxConstraints(minWidth: 50, minHeight: 50),
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [if (drawRectangle) Image.asset(imageName), child],
      ),
    );
  }
}

extension on RoughButton {
  void _onTapHandle(BuildContext context) {
    context.read<AudioController>().playSfx(soundEffect);
    onTap();
  }
}
