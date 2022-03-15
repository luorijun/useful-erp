import 'package:flutter/material.dart';
import 'package:useful_erp/views/outbound/outbound_form.dart';
import 'package:useful_erp/widgets/dialogs/content_dialog.dart';

Future<OutboundFormValue?> editOutbound(BuildContext context, [OutboundFormValue? value]) async {
  return showDialog(
    context: context,
    builder: (context) => OutboundEditor(value: value),
  );
}

class OutboundEditor extends StatelessWidget {
  OutboundEditor({
    Key? key,
    this.value,
  }) : super(key: key);

  final OutboundFormValue? value;

  late final controller = OutboundFormController(value);

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("新增出库记录"),
      content: OutboundForm(controller: controller),
      autoPop: false,
      onCancel: () {
        Navigator.pop(context);
      },
      onConfirm: () {
        final value = controller.value;
        if (value == null) return;
        Navigator.pop(context, value);
      },
    );
  }
}
