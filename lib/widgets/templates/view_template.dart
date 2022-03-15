import 'package:flutter/material.dart';

class ViewTemplate extends StatelessWidget {
  const ViewTemplate({
    Key? key,
    required this.name,
    this.content,
  }) : super(key: key);

  final String name;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 页头
        Container(
          height: 92,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          alignment: Alignment.centerLeft,
          child: Text(name, style: theme.textTheme.headline2),
        ),

        // 页面
        Expanded(
          child: Container(
            child: content,
          ),
        ),

        // 页脚
      ],
    );
  }
}
