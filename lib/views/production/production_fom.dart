import 'package:flutter/material.dart';
import 'package:useful_erp/utils/input.dart';
import 'package:useful_erp/views/production/production.dart';

class ProductionFormState extends ChangeNotifier {
  ProductionFormState([Production? production]) {
    _production = production ?? Production();
  }

  late final Production _production;

  Production get production {
    return Production(
      id: _production.id,
      name: _production.name,
      spec: _production.spec,
      cost: _production.cost,
      price: _production.price,
      unit: _production.unit,
      createAt: _production.createAt ?? DateTime.now(),
      createBy: _production.createBy,
    );
  }
}

class ProductionForm extends StatelessWidget {
  ProductionForm({
    Key? key,
    required this.state,
  }) : super(key: key) {
    _name = TextEditingController(text: state._production.name);
    _spec = TextEditingController(text: state._production.spec);
    _cost = TextEditingController(text: state._production.cost?.toString() ?? '0');
    _price = TextEditingController(text: state._production.price?.toString() ?? '0');
    _unit = TextEditingController(text: state._production.unit);
  }

  final ProductionFormState state;

  late final TextEditingController _name;
  late final TextEditingController _spec;
  late final TextEditingController _cost;
  late final TextEditingController _price;
  late final TextEditingController _unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _name,
          decoration: const InputDecoration(labelText: "名称"),
          onChanged: (_) => state.production.name = _name.text,
        ),
        TextFormField(
          controller: _spec,
          decoration: const InputDecoration(labelText: "规格"),
          onChanged: (_) => state.production.spec = _name.text,
        ),
        TextFormField(
          controller: _cost,
          inputFormatters: [numberFormatter],
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "成本"),
          onChanged: (_) {
            if (_cost.text.isEmpty) return;
            state.production.cost = double.parse(_cost.text);
          },
        ),
        TextFormField(
          controller: _price,
          inputFormatters: [numberFormatter],
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "售价"),
          onChanged: (_) {
            if (_price.text.isEmpty) return;
            state.production.price = double.parse(_price.text);
          },
        ),
        TextFormField(
          controller: _unit,
          decoration: const InputDecoration(labelText: "单位"),
          onChanged: (_) => state.production.name = _name.text,
        ),
      ],
    );
  }
}
