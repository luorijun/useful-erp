import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:useful_erp/entities/bound.dart';
import 'package:useful_erp/views/production/production_picker.dart';
import 'package:useful_erp/views/warehouse/warehouse_picker.dart';
import 'package:useful_erp/widgets/dialogs/content_dialog.dart';

// ignore: must_be_immutable
class InboundUpdate extends StatelessWidget {
  InboundUpdate(
    this.item, {
    Key? key,
  }) : super(key: key);

  final Map<String, dynamic> item;

  final _repository = BoundRepository();

  late final TextEditingController _production = TextEditingController(text: item['production'].toString());
  late int? _productionId = item['production'];

  late final TextEditingController _warehouse = TextEditingController(text: item['warehouse'].toString());
  late int? _warehouseId = item['warehouse'];

  late final _count = TextEditingController(text: item['count'].toString());

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("修改入库记录"),
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
        return _repository.updateById({
          'id': item['id'],
          'production': _productionId,
          'warehouse': _warehouseId,
          'count': _count.text,
        });
      },
    );
  }
}
