import 'package:flutter/material.dart';
import 'package:useful_erp/entities/warehouse.dart';
import 'package:useful_erp/widgets/dialogs/content_dialog.dart';

class WarehouseCreate extends StatelessWidget {
  WarehouseCreate({Key? key}) : super(key: key);

  final _repository = WarehouseRepository();

  // 数据字段
  final _name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("新增仓库"),
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
        _repository.create({
          'name': _name.text,
        });
      },
    );
  }
}
