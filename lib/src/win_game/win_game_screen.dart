import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dice_roller/src/ads/ads_controller.dart';
import 'package:dice_roller/src/ads/banner_ad_widget.dart';
import 'package:dice_roller/src/games_services/score.dart';
import 'package:dice_roller/src/in_app_purchase/in_app_purchase.dart';
import 'package:dice_roller/src/router/router.dart';
import 'package:dice_roller/src/style/palette.dart';
import 'package:dice_roller/src/style/responsive_screen.dart';
import 'package:dice_roller/src/style/rough_button.dart';

class WinGameScreen extends StatelessWidget {
  const WinGameScreen({super.key, required this.score});

  final Score score;

  @override
  Widget build(BuildContext context) {
    var adsControllerAvailable = context.watch<AdsController?>() != null;
    var adsRemoved =
        context.watch<InAppPurchaseController?>()?.adRemoval.active ?? false;
    var palette = context.read<Palette>();
    var spacer10 = Divider(thickness: 2, color: palette.pen);
    const testStyle = TextStyle(fontSize: 20);

    return Scaffold(
      backgroundColor: palette.background4,
      body: ResponsiveScreen(
        topSlot: const Text('Game Result', style: TextStyle(fontSize: 50)),
        mainSlot: ListView(children: <Widget>[
          if (adsControllerAvailable && !adsRemoved)
            const Expanded(child: Center(child: BannerAdWidget())),
          spacer10,
          Text('Score: ${score.finalScore}', style: testStyle),
          spacer10,
          Text('Time: ${score.formattedTime}', style: testStyle),
          spacer10,
          Text(score.descAllRollValues, style: testStyle),
          Text(score.descSumAndAverage, style: testStyle),
          spacer10,
          ...score.results.map((e) => Text(e.reason, style: testStyle)),
          spacer10,
          Text(score.descBonusFactor, style: testStyle),
          spacer10,
          Text(score.descFinalScore, style: testStyle),
          spacer10,
        ]),
        bottomSlot: RoughButton(
          onTap: () => const PlayRoute().go(context),
          child: const Text('Continue', style: testStyle),
        ),
      ),
    );
  }
}
