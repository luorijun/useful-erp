import 'package:flutter/material.dart';
import 'package:useful_erp/views/production/production_fom.dart';
import 'package:useful_erp/widgets/dialogs/content_dialog.dart';

import 'production.dart';

editProduction(BuildContext context, [Production? production]) {
  return showDialog(
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
      onCancel: () {},
      onConfirm: () => _state.production,
    );
  }
}
