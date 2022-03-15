import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:useful_erp/entities/bound.dart';
import 'package:useful_erp/views/production/production_picker.dart';
import 'package:useful_erp/views/warehouse/warehouse_picker.dart';

class OutboundFormValue {
  OutboundFormValue({
    this.id,
    this.production,
    this.warehouse,
    this.count,
    this.createAt,
  });

  int? id;
  BoundType? type = BoundType.SALE_OUT;
  Map<String, dynamic>? production;
  Map<String, dynamic>? warehouse;
  int? count;
  DateTime? createAt;

  @override
  String toString() {
    return 'OutboundFormValue{id: $id, type: $type, production: $production, warehouse: $warehouse, count: $count, createAt: $createAt}';
  }
}

class OutboundFormController extends ChangeNotifier {
  OutboundFormController([OutboundFormValue? value]) {
    _value = value ?? OutboundFormValue();
  }

  late OutboundFormValue _value;

  final _form = GlobalKey<FormState>();

  OutboundFormValue? get value {
    if (!_form.currentState!.validate()) {
      return null;
    }
    return OutboundFormValue(
      id: _value.id,
      production: _value.production,
      warehouse: _value.warehouse,
      count: _value.count,
      createAt: (_value.createAt ?? DateTime.now()),
    );
  }
}

// ignore: must_be_immutable
class OutboundForm extends StatelessWidget {
  OutboundForm({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final OutboundFormController controller;

  late final _production = TextEditingController(
    text: controller._value.production?['name']?.toString(),
  );
  late final _warehouse = TextEditingController(
    text: controller._value.warehouse?['name']?.toString(),
  );
  late final _count = TextEditingController(
    text: controller._value.count?.toString(),
  );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OutboundFormController(),
      child: Form(
        key: controller._form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: TextFormField(
                    controller: _production,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "商品",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "商品不能为空";
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  height: 32,
                  padding: const EdgeInsets.only(left: 16),
                  child: ElevatedButton(
                    child: const Text('选择'),
                    onPressed: () async {
                      final production = await pickProduction(context);
                      if (production == null) return;
                      controller._value.production = production;
                      _production.text = production['name'];
                    },
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: TextFormField(
                    controller: _warehouse,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "仓库",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "仓库不能为空";
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  height: 32,
                  padding: const EdgeInsets.only(left: 16),
                  child: ElevatedButton(
                    child: const Text('选择'),
                    onPressed: () async {
                      final warehouse = await pickWarehouse(context);
                      if (warehouse == null) return;
                      controller._value.warehouse = warehouse;
                      _warehouse.text = warehouse['name'];
                    },
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _count,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: "数量",
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "数量不能为空";
                }
                return null;
              },
              onChanged: (value) {
                controller._value.count = int.parse(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
