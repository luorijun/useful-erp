import 'package:flutter/material.dart';
import 'package:useful_erp/entities/warehouse.dart';
import 'package:useful_erp/utils/repository.dart';
import 'package:useful_erp/widgets/dialogs/content_dialog.dart';
import 'package:useful_erp/widgets/table.dart';
import 'package:useful_erp/widgets/templates/table_template.dart';

Future<Map<String, dynamic>?> pickWarehouse(BuildContext context) async {
  return showDialog<Map<String, dynamic>?>(
    context: context,
    builder: (context) => WarehousePicker(),
  );
}

class WarehousePicker extends StatelessWidget {
  WarehousePicker({Key? key}) : super(key: key);

  final _repository = WarehouseRepository();

  final _name = TextEditingController();

  late final _controller = TableTemplateController(
    onCount: (_) async => _repository.count(),
    onRefresh: (_, current, size) async {
      Map<String, Condition> conditions = {};
      if (_name.text.isNotEmpty) {
        conditions['name'] = Condition(_name.text, Operator.like);
      }
      return _repository.findAll(
        current: current,
        size: size,
        conditions: conditions.isNotEmpty ? conditions : null,
      );
    },
    onCreate: (_) async {},
    onUpdate: (_, data) async {},
    onRemove: (_, data) async {},
  );

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('选择仓库'),
      content: TableTemplate<Map<String, dynamic>>(
        controller: _controller,
        dataName: '',
        creatable: false,
        updatable: false,
        removable: false,
        checkable: false,
        columns: [
          ElaTableColumn(
            label: const Text("名称"),
            cellBuilder: (context, row, _) {
              return Text(row['name'].toString());
            },
          ),
        ],
        rowOperations: (context, row) => [
          ElevatedButton(
            child: const Text('选择'),
            onPressed: () {
              Navigator.pop(context, row);
            },
          ),
        ],
        queries: [
          Container(
            width: 192,
            height: 32,
            padding: const EdgeInsets.only(right: 16),
            child: TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: "请输入仓库名",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
              ),
            ),
          )
        ],
      ),
      onCancel: () {},
    );
  }
}
