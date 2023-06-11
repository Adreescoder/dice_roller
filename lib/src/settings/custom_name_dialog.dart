import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dice_roller/src/settings/settings.dart';
import 'package:dice_roller/src/style/rough_button.dart';

class CustomNameDialog extends StatefulWidget {
  const CustomNameDialog({super.key, required this.animation});

  final Animation<double> animation;

  static Future<void> show(context) async => showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          CustomNameDialog(animation: animation));

  @override
  State<CustomNameDialog> createState() => _CustomNameDialogState();
}

class _CustomNameDialogState extends State<CustomNameDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void didChangeDependencies() {
    _controller.text = context.read<SettingsController>().playerName.value;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: widget.animation,
        curve: Curves.easeOutCubic,
      ),
      child: SimpleDialog(
        contentPadding: const EdgeInsets.all(16),
        title: const Text('Player Name'),
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 12,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onChanged: (value) {
              context.read<SettingsController>().setPlayerName(value);
            },
            // Player tapped 'Submit'/'Done' on their keyboard.
            onSubmitted: (_) => context.pop(),
          ),
          const SizedBox(height: 16),
          RoughButton(onTap: context.pop, child: const Text('Close')),
        ],
      ),
    );
  }
}
