import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:useful_erp/router.dart';
import 'package:useful_erp/views/inbound/Inbound.dart';
import 'package:useful_erp/views/inbound/inbound_edit_batch.dart';
import 'package:useful_erp/views/outbound/outbound.dart';
import 'package:useful_erp/views/outbound/outbound_edit_batch.dart';
import 'package:useful_erp/views/production/production_view.dart';
import 'package:useful_erp/views/root.dart';
import 'package:useful_erp/views/warehouse/warehouse.dart';

void main() {
  // 初始化数据库
  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 运行程序
  runApp(const Application());

  // 初始化窗口
  doWhenWindowReady(() {
    appWindow.maximize();
  });
}

// 配置应用
class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RouterRoot(
        child: const RouterNode('0'),
        routes: [
          RouteItem(name: 'root', widget: (_) => const Root(), children: [
            RouteItem(name: 'outbound-edit-batch', widget: (_) => OutboundEditBatch()),
            RouteItem(name: 'inbound-edit-batch', widget: (_) => InboundEditBatch()),
            RouteItem(name: 'outbound', widget: (_) => OutboundView()),
            RouteItem(name: 'inbound', widget: (_) => InboundView()),
            RouteItem(name: 'production', widget: (_) => ProductionView()),
            RouteItem(name: 'warehouse', widget: (_) => WarehouseView()),
          ]),
        ],
      ),
    );
  }
}
