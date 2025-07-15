import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DB extends ChangeNotifier {
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    return await openDatabase(
      '${(await getApplicationSupportDirectory()).path}/${(kDebugMode) ? 'dev-' : ''}gtd.db',
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE inbox(id INTEGER PRIMARY KEY, entry TEXT)',
        );
        await db.execute(
          'CREATE TABLE projects(id INTEGER PRIMARY KEY, title TEXT, maybe INTEGER)',
        );
        await db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY, entry TEXT, project INTEGER, date TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<List<(int, String)>> getInbox() async {
    final queryResult = await (await database).query('inbox');
    final List<(int, String)> list = [];

    for (final {'id': id as int, 'entry': entry as String} in queryResult) {
      list.add((id, entry));
    }

    return list;
  }

  Future<void> addInboxEntry(String entry) async {
    (await database).insert('inbox', {'entry': entry});
    notifyListeners();
  }

  Future<void> removeInboxEntry(int id) async {
    (await database).delete('inbox', where: 'id = ?', whereArgs: [id]);
    notifyListeners();
  }

  Future<List<(int, String)>> getProjects(bool maybe) async {
    int maybeInt = (maybe) ? 1 : 0;
    final queryResult = await (await database).query(
      'projects',
      where: 'maybe = ?',
      whereArgs: [maybeInt],
    );

    List<(int, String)> list = [];
    for (final {'id': id as int, 'title': title as String} in queryResult) {
      list.add((id, title));
    }

    return list;
  }

  Future<void> addProject(String title, bool maybe) async {
    int maybeInt = (maybe) ? 1 : 0;
    (await database).insert('projects', {'title': title, 'maybe': maybeInt});
    notifyListeners();
  }

  Future<void> removeProject(int id) async {
    (await database).delete('projects', where: 'id = ?', whereArgs: [id]);
    notifyListeners();
  }

  Future<String> getProjectTitle(int id) async {
    final queryResult = await (await database).query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );

    return queryResult.first['title'] as String;
  }

  Future<List<(int, String)>> getTasks(int projectID) async {
    final queryResult = await (await database).query(
      'tasks',
      where: 'project = ?',
      whereArgs: [projectID],
    );
    final List<(int, String)> list = [];

    for (final {'id': id as int, 'entry': entry as String} in queryResult) {
      list.add((id, entry));
    }

    return list;
  }

  Future<void> addTask(String entry, int projectID, DateTime? date) async {
    (await database).insert('tasks', {
      'entry': entry,
      'project': projectID,
      'date': date?.toIso8601String() ?? '',
    });
    notifyListeners();
  }

  Future<void> removeTask(int id) async {
    (await database).delete('tasks', where: 'id = ?', whereArgs: [id]);
    notifyListeners();
  }

  Future<void> swapTasks(int id1, int id2) async {
    for (var op in [(id1, -1), (id2, id1), (-1, id2)]) {
      await (await database).update(
        'tasks',
        {'id': op.$2},
        where: 'id = ?',
        whereArgs: [op.$1],
      );
    }

    notifyListeners();
  }

  Future<void> toggleMaybe(int id) async {
    final query = await (await database).query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    int newMaybe = (query.first['maybe'] == 0) ? 1 : 0;

    await (await database).update(
      'tasks',
      {'maybe': newMaybe},
      where: 'id = ?',
      whereArgs: [id],
    );

    notifyListeners();
  }

  Future<void> changeTask(int id, String entry) async {
    await (await database).update(
      'tasks',
      {'entry': entry},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  void notify() {
    notifyListeners();
  }
}
