import 'package:flutter/material.dart';
import 'package:useful_erp/entities/warehouse.dart';
import 'package:useful_erp/views/warehouse/warehouse_create.dart';
import 'package:useful_erp/views/warehouse/warehouse_update.dart';
import 'package:useful_erp/widgets/table.dart';
import 'package:useful_erp/widgets/templates/table_template.dart';
import 'package:useful_erp/widgets/templates/table_view_template.dart';

class WarehouseView extends StatelessWidget {
  WarehouseView({Key? key}) : super(key: key);

  final WarehouseRepository _repository = WarehouseRepository();

  // 查询表单
  final _name = TextEditingController();

  late final _controller = TableTemplateController<Map<String, dynamic>>(
    onCount: (context) async => _repository.count(),
    onRefresh: (context, current, size) async {
      // 构造查询条件
      final Map<String, dynamic> conditions = {};
      if (_name.text.isNotEmpty) {
        conditions['name'] = _name.text;
      }
      // 执行查询
      return _repository.findAll(
        current: current,
        size: size,
        conditions: conditions.isNotEmpty ? conditions : null,
      );
    },
    onCreate: (context) async => showDialog(
      context: context,
      builder: (context) => WarehouseCreate(),
    ),
    onUpdate: (context, data) async => showDialog(
      context: context,
      builder: (context) => WarehouseUpdate(data),
    ),
    onRemove: (context, data) async => _repository.removeByIds(
      data.map((e) => e['id'] as int).toList(growable: false),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return TableViewTemplate<Map<String, dynamic>>(
      controller: _controller,
      viewName: "仓库管理",
      dataName: "仓库",
      dataComparator: (a, b) => a['id'] == b['id'],
      columns: [
        ElaTableColumn(
          label: const Text("名称"),
          cellBuilder: (context, row, _) {
            return Text(row['name'].toString());
          },
        ),
      ],
      queries: [
        Container(
          width: 192,
          height: 32,
          color: Colors.white,
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _name,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              border: OutlineInputBorder(),
              hintText: '请输入仓库名',
            ),
          ),
        )
      ],
    );
  }
}
