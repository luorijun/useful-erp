import 'package:flutter/material.dart';

typedef CancelEvent<T> = T? Function();
typedef ConfirmEvent<T> = T? Function();

class ContentDialog<T> extends StatelessWidget {
  const ContentDialog({
    Key? key,
    required this.title,
    required this.content,
    this.autoPop = true,
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  final Widget title;
  final Widget content;
  final bool autoPop;

  final ConfirmEvent<T>? onConfirm;
  final CancelEvent<T>? onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      actions: [
        if (onCancel != null)
          TextButton(
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Text("取消"),
            ),
            onPressed: () {
              final result = onCancel!();
              if (autoPop) Navigator.pop(context, result);
            },
          ),
        if (onConfirm != null)
          ElevatedButton(
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Text("确定"),
            ),
            onPressed: () {
              final result = onConfirm!();
              if (autoPop) Navigator.pop(context, result);
            },
          ),
      ],
    );
  }
}
