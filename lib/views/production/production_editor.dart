import 'package:flutter/material.dart';
import 'package:useful_erp/views/production/production_fom.dart';
import 'package:useful_erp/widgets/dialogs/content_dialog.dart';

import 'production.dart';

Future<Production?> editProduction(BuildContext context, [Production? production]) async {
  return await showDialog<Production>(
    context: context,
    builder: (context) => ProductionEditor(value: production),
  );
}

class ProductionEditor extends StatelessWidget {
  ProductionEditor({
    Key? key,
    Production? value,
  }) : super(key: key) {
    _state = ProductionFormState(value);
  }

  late final ProductionFormState _state;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("修改商品"),
      content: ProductionForm(state: _state),
      autoPop: false,
      onCancel: () {
        Navigator.pop(context);
      },
      onConfirm: () {
        if (_state.production == null) return;
        Navigator.pop(context, _state.production);
      },
    );
  }
}
