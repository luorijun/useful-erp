import 'package:flutter/material.dart';
import 'package:useful_erp/entities/production.dart';
import 'package:useful_erp/utils/input.dart';
import 'package:useful_erp/views/production/production.dart';

class ProductionUpdate extends StatelessWidget {
  ProductionUpdate({
    Key? key,
    required this.state,
    required this.item,
  }) : super(key: key) {
    nameController = TextEditingController(text: item['name'].toString());
    costController = TextEditingController(text: item['cost'].toString());
    priceController = TextEditingController(text: item['price'].toString());
  }

  final ProductionViewState state;
  final Map<String, dynamic> item;

  late TextEditingController nameController;
  late TextEditingController costController;
  late TextEditingController priceController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("修改商品"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "名称",
            ),
          ),
          TextFormField(
            controller: costController,
            inputFormatters: [numberFormatter],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "成本",
            ),
          ),
          TextFormField(
            controller: priceController,
            inputFormatters: [numberFormatter],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "售价",
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Text("取消"),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Text("确定"),
          ),
          onPressed: () {
            ProductionRepository().updateById({
              'id': item['id'],
              'name': nameController.text,
              'cost': costController.text,
              'price': priceController.text,
            });
            Navigator.pop(context);
            state.refreshData();
          },
        ),
      ],
      actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
    );
  }
}
