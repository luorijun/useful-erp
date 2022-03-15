import 'package:flutter/material.dart';
import 'package:useful_erp/entities/warehouse.dart';
import 'package:useful_erp/widgets/dialogs/content_dialog.dart';

class WarehouseUpdate extends StatelessWidget {
  WarehouseUpdate(this.item, {Key? key}) : super(key: key);

  final Map<String, dynamic> item;

  final _repository = WarehouseRepository();

  // 数据字段
  late final _name = TextEditingController(text: item['name'].toString());

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("修改仓库"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: "名称",
            ),
          ),
        ],
      ),
      onCancel: () {},
      onConfirm: () {
        _repository.updateById({
          'id': item['id'],
          'name': _name.text,
        });
      },
    );
  }
}
