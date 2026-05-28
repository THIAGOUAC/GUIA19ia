import 'package:drift/drift.dart';

// ════════════════════════════════════════════════════════════════════════════
// PRODUCTS
// ════════════════════════════════════════════════════════════════════════════

class Products extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text()();
  TextColumn get description => text()();
  RealColumn get price => real()();
  TextColumn get category => text()();
  TextColumn get imageUrl => text()();

  IntColumn get stock => integer().withDefault(const Constant(0))();

  TextColumn get artisan => text().nullable()();
  TextColumn get origin => text().nullable()();

  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ════════════════════════════════════════════════════════════════════════════
// FAVORITES
// ════════════════════════════════════════════════════════════════════════════

class Favorites extends Table {
  IntColumn get productId => integer()();
  TextColumn get productName => text()();

  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {productId};
}

// ════════════════════════════════════════════════════════════════════════════
// SYNC QUEUE 🔥 (CLAVE PARA 20)
// ════════════════════════════════════════════════════════════════════════════

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get action => text()(); // add_favorite, remove_favorite
  IntColumn get productId => integer()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
