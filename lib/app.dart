import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dice_roller/src/ads/ads_controller.dart';
import 'package:dice_roller/src/app_lifecycle/app_lifecycle.dart';
import 'package:dice_roller/src/audio/audio_controller.dart';
import 'package:dice_roller/src/games_services/games_services.dart';
import 'package:dice_roller/src/in_app_purchase/in_app_purchase.dart';
import 'package:dice_roller/src/player_progress/persistence/player_progress_persistence.dart';
import 'package:dice_roller/src/player_progress/player_progress.dart';
import 'package:dice_roller/src/router/router.dart';
import 'package:dice_roller/src/settings/persistence/settings_persistence.dart';
import 'package:dice_roller/src/settings/settings.dart';
import 'package:dice_roller/src/style/palette.dart';
import 'package:dice_roller/src/style/snack_bar.dart';

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
    required this.adsController,
    required this.inAppPurchaseController,
    required this.gamesServicesController,
    required this.settingsPersistence,
    required this.playerProgressPersistence,
  });

  final AdsController? adsController;
  final InAppPurchaseController? inAppPurchaseController;
  final GamesServicesController? gamesServicesController;
  final SettingsPersistence settingsPersistence;
  final PlayerProgressPersistence playerProgressPersistence;

  static final _router = GoRouter(routes: $appRoutes);

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => PlayerProgress(playerProgressPersistence)
                ..getLatestFromStore()),
          ChangeNotifierProvider<InAppPurchaseController?>.value(
              value: inAppPurchaseController),
          Provider<AdsController?>.value(value: adsController),
          Provider<GamesServicesController?>.value(
              value: gamesServicesController),
          Provider<SettingsController>(
            lazy: false,
            create: (_) => SettingsController(persistence: settingsPersistence)
              ..loadStateFromPersistence(),
          ),
          ProxyProvider2<SettingsController, ValueNotifier<AppLifecycleState>,
              AudioController>(
            lazy: false,
            create: (_) => AudioController()..initialize(),
            update: (_, settings, lifecycleNotifier, audioController) {
              if (audioController == null) throw ArgumentError.notNull();
              audioController
                ..attachSettings(settings)
                ..attachLifecycleNotifier(lifecycleNotifier);
              return audioController;
            },
            dispose: (_, audioController) => audioController.dispose(),
          ),
          Provider(create: (_) => Palette()),
        ],
        child: Builder(builder: (context) {
          final palette = context.read<Palette>();
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'The Dice Game',
            routerConfig: _router,
            scaffoldMessengerKey: scaffoldMessengerKey,
            theme: ThemeData.from(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: palette.darkPen,
                background: palette.backgroundMain,
              ),
              textTheme: TextTheme(
                bodyMedium: TextStyle(
                  color: palette.ink,
                  fontFamily: 'Permanent Marker',
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
