import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:dice_roller/app.dart';
import 'package:dice_roller/src/ads/ads_controller.dart';
import 'package:dice_roller/src/crashlytics/crashlytics.dart';
import 'package:dice_roller/src/games_services/games_services.dart';
import 'package:dice_roller/src/in_app_purchase/in_app_purchase.dart';
import 'package:dice_roller/src/player_progress/persistence/local_storage_player_progress_persistence.dart';
import 'package:dice_roller/src/settings/persistence/local_storage_settings_persistence.dart';

Logger _log = Logger('main.dart');

Future<void> main() async {
  FirebaseCrashlytics? crashlytics;
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   try {
  //     WidgetsFlutterBinding.ensureInitialized();
  //     await Firebase.initializeApp(
  //         options: DefaultFirebaseOptions.currentPlatform);
  //     crashlytics = FirebaseCrashlytics.instance;
  //   } catch (e) {
  //     debugPrint("Firebase couldn't be initialized: $e");
  //   }
  // }
  await guardWithCrashlytics(guardedMain, crashlytics: crashlytics);
}

/// Without logging and crash reporting, this would be `void main()`.
void guardedMain() {
  // Don't log anything below warnings in production.
  if (kReleaseMode) Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: '
        '${record.loggerName}: ${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();

  _log.info('Going full screen');
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  AdsController? adsController;
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   /// Prepare the google_mobile_ads plugin so that the first ad loads
  //   /// faster. This can be done later or with a delay if startup
  //   /// experience suffers.
  //   adsController = AdsController(MobileAds.instance);
  //   adsController.initialize();
  // }

  GamesServicesController? gamesServicesController;
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   gamesServicesController = GamesServicesController()
  //     // Attempt to log the player in.
  //     ..initialize();
  // }

  InAppPurchaseController? inAppPurchaseController;
  // if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
  //   inAppPurchaseController = InAppPurchaseController(InAppPurchase.instance)
  //     // Subscribing to [InAppPurchase.instance.purchaseStream] as soon
  //     // as possible in order not to miss any updates.
  //     ..subscribe();
  //   // Ask the store what the player has bought already.
  //   inAppPurchaseController.restorePurchases();
  // }

  runApp(MainApp(
    adsController: adsController,
    inAppPurchaseController: inAppPurchaseController,
    gamesServicesController: gamesServicesController,
    settingsPersistence: LocalStorageSettingsPersistence(),
    playerProgressPersistence: LocalStoragePlayerProgressPersistence(),
  ));
}
