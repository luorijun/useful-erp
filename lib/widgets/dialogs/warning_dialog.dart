import 'package:flutter/material.dart';

class WarningDialog extends StatelessWidget {
  const WarningDialog({
    Key? key,
    this.title,
    this.content,
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  final Widget? title;
  final Widget? content;
  final Function? onConfirm;
  final Function? onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(children: [
        const Icon(
          Icons.error,
          color: Colors.orange,
        ),
        const SizedBox(width: 8),
        title ?? Container(),
      ]),
      content: content,
      actions: [
        if (onCancel != null)
          TextButton(
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Text("取消"),
            ),
            onPressed: () {
              onCancel!();
            },
          ),
        if (onConfirm != null)
          ElevatedButton(
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Text("确定"),
            ),
            onPressed: () {
              onConfirm!();
            },
          ),
      ],
    );
  }
}
