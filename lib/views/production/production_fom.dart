import 'package:flutter/material.dart';
import 'package:useful_erp/utils/input.dart';
import 'package:useful_erp/views/production/production.dart';

class ProductionFormState extends ChangeNotifier {
  ProductionFormState([Production? production]) {
    _production = production;
  }

  late final Production? _production;

  Production get production {
    if (_production != null) {
      return Production(
        createAt: DateTime.now(),
      );
    }

    return Production(
      id: _production!.id,
      name: _production!.name,
      cost: _production!.cost,
      price: _production!.price,
      createAt: _production!.createAt ?? DateTime.now(),
      createBy: _production!.createBy,
    );
  }
}

class ProductionForm extends StatelessWidget {
  ProductionForm({
    Key? key,
    required this.state,
  }) : super(key: key) {
    _name = TextEditingController(text: state.production.name);
    _cost = TextEditingController(text: state.production.cost?.toString() ?? '0');
    _price = TextEditingController(text: state.production.price?.toString() ?? '0');
  }

  final ProductionFormState state;

  late final TextEditingController _name;
  late final TextEditingController _cost;
  late final TextEditingController _price;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: "名称",
          ),
          onChanged: (_) => state.production.name = _name.text,
        ),
        TextFormField(
          controller: _cost,
          inputFormatters: [numberFormatter],
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "成本",
          ),
          onChanged: (_) {
            if (_cost.text.isEmpty) return;
            state.production.cost = double.parse(_cost.text);
          },
        ),
        TextFormField(
          controller: _price,
          inputFormatters: [numberFormatter],
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "售价",
          ),
          onChanged: (_) {
            if (_price.text.isEmpty) return;
            state.production.price = double.parse(_price.text);
          },
        ),
      ],
    );
  }
}
