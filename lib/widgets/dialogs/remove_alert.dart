import 'package:flutter/material.dart';

class RemoveAlert extends StatelessWidget {
  const RemoveAlert({
    Key? key,
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  final Function? onConfirm;
  final Function? onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(children: const [
        Icon(
          Icons.error,
          color: Colors.orange,
        ),
        SizedBox(width: 8),
        Text(
          "删除提醒",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ]),
      content: const Text(
        "删除后将无法恢复，确定要删除吗？",
      ),
      actions: [
        TextButton(
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Text("取消"),
          ),
          onPressed: () {
            if (onCancel != null) onCancel!();
          },
        ),
        ElevatedButton(
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Text("确定"),
          ),
          onPressed: () {
            if (onConfirm != null) onConfirm!();
          },
        ),
      ],
    );
  }
}
