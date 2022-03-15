import 'dart:math' as math;

import 'package:sqflite/sqflite.dart';

abstract class Repository {
  Repository({
    required this.table,
  });

  final String table;
  final Connection connection = Connection();

  Future<int> count({
    Map<String, dynamic>? conditions,
  }) async {
    final db = await connection.db;

    // 组装查询条件
    String? where;
    List<dynamic>? whereArgs;
    if (conditions != null && conditions.isNotEmpty) {
      where = conditions.keys.map((key) => '$key like ?').join(' and ');
      whereArgs = conditions.values.map((value) => '%$value%').toList(growable: false);
    }

    // 执行查询
    final result = await db.query(
      table,
      columns: ['count(*) as count'],
      where: where,
      whereArgs: whereArgs,
    );
    return result[0]['count'] as int;
  }

  Future<List<Map<String, dynamic>>> findAll({
    int? current,
    int? size,
    Map<String, dynamic>? conditions,
    List<String>? orders,
  }) async {
    final db = await connection.db;

    // 组装查询条件
    String? where;
    List<dynamic>? whereArgs;
    if (conditions != null && conditions.isNotEmpty) {
      where = conditions.keys.map((key) => '$key like ?').join(' and ');
      whereArgs = conditions.values.map((value) => '%$value%').toList(growable: false);
    }

    // 按字段排序
    String? orderBy;
    if (orders != null && orders.isNotEmpty) {
      orderBy = orders.join(',');
    }

    // 执行查询
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      limit: size != null ? math.max(0, size) : size,
      offset: current != null && size != null ? math.max(0, (current - 1) * size) : current,
      orderBy: orderBy,
    );
  }

  Future<Map<String, dynamic>?> findFirst({
    Map<String, dynamic>? conditions,
    List<String>? orders,
  }) async {
    final db = await connection.db;

    // 组装查询条件
    String? where;
    List<dynamic>? whereArgs;
    if (conditions != null && conditions.isNotEmpty) {
      where = conditions.keys.map((key) => '$key like ?').join(' and ');
      whereArgs = conditions.values.map((value) => '%$value%').toList(growable: false);
    }

    // 按字段排序
    String? orderBy;
    if (orders != null && orders.isNotEmpty) {
      orderBy = orders.join(',');
    }

    // 执行查询
    final result = await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: 1,
    );

    if (result.isEmpty) return null;
    return result[0];
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    final db = await connection.db;
    final result = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result[0] : null;
  }

  Future<void> create(Map<String, dynamic> entity) async {
    final db = await connection.db;
    db.insert(table, entity);
  }

  Future<void> updateById(Map<String, dynamic> entity) async {
    final data = Map.of(entity);

    if (!data.containsKey('id')) {
      throw Exception("更新数据时没有传入 id");
    }

    final id = data['id'];
    data.remove('id');

    final db = await connection.db;
    db.update(table, data, where: "id = ?", whereArgs: [id]);
  }

  Future<void> removeById(int id) async {
    final db = await connection.db;
    db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> removeByIds(List<int> ids) async {
    final db = await connection.db;
    db.delete(
      table,
      where: 'id in (${ids.map((_) => '?').join(',')})',
      whereArgs: ids,
    );
  }
}

class Connection {
  Connection._();

  static final _instance = Connection._();

  factory Connection() {
    return _instance;
  }

  Future<Database>? _db;

  Future<Database> get db async {
    if (_db == null) {
      final path = await getDatabasesPath();
      _db = openDatabase(
        "$path/root",
        version: version,
        onCreate: (db, version) {
          db.execute(create);
          db.setVersion(version);
        },
        onUpgrade: (db, oldVersion, newVersion) {
          db.execute(drop);
          db.execute(create);
          db.setVersion(newVersion);
        },
      );
    }
    return _db!;
  }
}

const version = 6;

const drop = '''
drop table if exists production;
drop table if exists warehouse;
drop table if exists bound;
drop table if exists account;
drop table if exists role;
drop table if exists authority;
''';

const create = '''
create table production
(
    id       integer primary key autoincrement,
    name     text    not null,
    price    float   not null default 0,
    cost     float   not null default 0,
    createBy integer null,
    createAt text    null
);

create table warehouse
(
    id        integer primary key autoincrement,
    name      text    not null,
    isDefault boolean null default 0,
    createBy  integer null,
    createAt  text    null
);

create table bound
(
    id           integer primary key autoincrement,
    production   integer not null,
    warehouse    integer not null,
    type         text not null,
    count        integer not null,
    createBy     integer null,
    createAt     text    null
);

create table account
(
    id       integer primary key autoincrement,
    name     text    not null,
    username text    not null,
    password text    not null,
    createBy integer null,
    createAt text    null
);

create table role
(
    id       integer primary key autoincrement,
    name     text    not null,
    createBy integer null,
    createAt text    null
);

create table authority
(
    id       integer primary key autoincrement,
    name     text    not null,
    createBy integer null,
    createAt text    null
);
''';
