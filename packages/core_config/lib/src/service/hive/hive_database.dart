// REUSABLE SERVICE: Works in any project.
// REQUIRES: hive_ce_flutter package in pubspec.yaml
// CHANGE: Register your own Hive adapters and open your own boxes in setup().
import 'package:hive_ce_flutter/hive_flutter.dart';

class HiveDatabase {
  factory HiveDatabase() => _instance;

  HiveDatabase._();

  static final HiveDatabase _instance = HiveDatabase._();

  // Box<AddNotificationModel>? notificationBox;
  // Box<FavoritesModel>? favoritesBox;

  Future<void> setup() async {
    await Hive.initFlutter();

    // if (!Hive.isAdapterRegistered(AddNotificationModelAdapter().typeId)) {
    //   Hive.registerAdapter(AddNotificationModelAdapter());
    // }

    // if (!Hive.isAdapterRegistered(FavoritesModelAdapter().typeId)) {
    //   Hive.registerAdapter(FavoritesModelAdapter());
    // }

    // notificationBox = await Hive.openBox<AddNotificationModel>(
    //   'notification_box',
    // );

    // favoritesBox = await Hive.openBox<FavoritesModel>(
    //   'favorites_box',
    // );
  }

  Future<void> clearAllBox() async {
    // await notificationBox?.clear();
    // await favoritesBox?.clear();
  }
}
