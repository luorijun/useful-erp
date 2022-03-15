import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:useful_erp/entities/bound.dart';
import 'package:useful_erp/views/production/production_picker.dart';
import 'package:useful_erp/views/warehouse/warehouse_picker.dart';
import 'package:useful_erp/widgets/dialogs/content_dialog.dart';

// ignore: must_be_immutable
class InboundCreate extends StatelessWidget {
  InboundCreate({Key? key}) : super(key: key);

  final _repository = BoundRepository();

  final _production = TextEditingController();
  int? _productionId;

  final _warehouse = TextEditingController();
  int? _warehouseId;

  final _count = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("新增入库记录"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: TextField(
                  controller: _production,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "商品",
                  ),
                ),
              ),
              Container(
                height: 32,
                padding: const EdgeInsets.only(left: 16),
                child: ElevatedButton(
                  child: const Text('选择'),
                  onPressed: () async {
                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (context) {
                        return ProductionPicker();
                      },
                    );
                    if (result == null) return;
                    _production.text = result['name'];
                    _productionId = result['id'];
                  },
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: TextField(
                  controller: _warehouse,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "仓库",
                  ),
                ),
              ),
              Container(
                height: 32,
                padding: const EdgeInsets.only(left: 16),
                child: ElevatedButton(
                  child: const Text('选择'),
                  onPressed: () async {
                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (context) {
                        return WarehousePicker();
                      },
                    );
                    if (result == null) return;
                    _warehouse.text = result['name'];
                    _warehouseId = result['id'];
                  },
                ),
              ),
            ],
          ),
          TextField(
            controller: _count,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              labelText: "数量",
            ),
          ),
        ],
      ),
      onCancel: () {},
      onConfirm: () async {
        // 插入新纪录
        return _repository.create({
          'type': BoundType.RECORD_IN.name,
          'production': _productionId,
          'warehouse': _warehouseId,
          'count': _count.text,
          'createAt': DateTime.now().toString(),
        });
      },
    );
  }
}
