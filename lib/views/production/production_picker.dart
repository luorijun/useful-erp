import 'package:flutter/material.dart';
import 'package:useful_erp/entities/production.dart';
import 'package:useful_erp/widgets/dialogs/content_dialog.dart';
import 'package:useful_erp/widgets/table.dart';
import 'package:useful_erp/widgets/templates/table_template.dart';

Future<Map<String, dynamic>?> pickProduction(BuildContext context) async {
  return showDialog<Map<String, dynamic>?>(
    context: context,
    builder: (context) => ProductionPicker(),
  );
}

class ProductionPicker extends StatelessWidget {
  ProductionPicker({Key? key}) : super(key: key);

  final _repository = ProductionRepository();

  final _name = TextEditingController();

  late final _controller = TableTemplateController(
    onCount: (_) async => _repository.count(),
    onRefresh: (_, current, size) async {
      Map<String, dynamic> conditions = {};
      if (_name.text.isNotEmpty) {
        conditions['name'] = _name.text;
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
      title: const Text('选择商品'),
      content: TableTemplate<Map<String, dynamic>>(
        controller: _controller,
        dataName: '',
        creatable: false,
        updatable: false,
        removable: false,
        checkable: false,
        columns: [
          ElaTableColumn<Map<String, dynamic>>(
            label: const Text("id"),
            cellBuilder: (context, row, _) {
              return Text(row['id'].toString());
            },
          ),
          ElaTableColumn<Map<String, dynamic>>(
            label: const Text("名称"),
            cellBuilder: (context, row, _) {
              return Text(row['name'].toString());
            },
          ),
          ElaTableColumn<Map<String, dynamic>>(
            label: const Text("售价"),
            cellBuilder: (context, row, _) {
              return Text(row['price'].toString());
            },
          ),
          ElaTableColumn<Map<String, dynamic>>(
            label: const Text("成本"),
            cellBuilder: (context, row, _) {
              return Text(row['cost'].toString());
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
                labelText: "请输入商品名",
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
