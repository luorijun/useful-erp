import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:useful_erp/utils/events.dart';

// ignore: must_be_immutable
class Pagination extends StatelessWidget {
  Pagination({
    Key? key,
    this.availableSizes,
    int? total,
    int? current,
    int? size,
    this.onChangeCurrent,
    this.onChangeSize,
  }) : super(key: key) {
    this.total = total ?? 0;
    this.size = size ?? 10;

    this.current = current ?? 1;
    this.current = math.max(1, this.current);

    _pageCount = (this.total / this.size).ceil();
    this.current = math.min(_pageCount, this.current);

    pageController = TextEditingController(text: current.toString());
  }

  // 传参
  late int total;
  late int current;
  late int size;
  final List<int>? availableSizes;

  late int _pageCount;
  late TextEditingController pageController;

  // 事件
  final ActionEvent<int>? onChangeCurrent;
  final ActionEvent<int>? onChangeSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 数据总数
        Text('共 $total 条'),
        const SizedBox(width: 16),

        // 页面跳转
        const Text('第 '),
        Container(
          height: 32,
          width: 48,
          color: Colors.white,
          child: TextField(
            controller: pageController,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (onChangeCurrent != null) {
                var page = int.parse(value);
                page = math.max(1, page);
                page = math.min(_pageCount, page);
                onChangeCurrent!(page);
              }
            },
          ),
        ),
        Text(" / $_pageCount 页"),
        const SizedBox(width: 16),

        // 翻页 - 左移
        InkWellIconButton(
          tip: '首页',
          icon: const Icon(Icons.first_page, size: 20),
          disable: current <= 1,
          onPressed: () {
            if (onChangeCurrent != null) onChangeCurrent!(1);
          },
        ),
        InkWellIconButton(
          tip: '上一页',
          icon: const Icon(Icons.chevron_left, size: 20),
          disable: current <= 1,
          onPressed: () {
            if (onChangeCurrent != null) onChangeCurrent!(current - 1);
          },
        ),
        // 翻页 - 右移
        InkWellIconButton(
          tip: '下一页',
          icon: const Icon(Icons.chevron_right, size: 20),
          disable: current >= _pageCount,
          onPressed: () {
            if (onChangeCurrent != null) onChangeCurrent!(current + 1);
          },
        ),
        InkWellIconButton(
          tip: '末页',
          icon: const Icon(Icons.last_page, size: 20),
          disable: current >= _pageCount,
          onPressed: () {
            if (onChangeCurrent != null) onChangeCurrent!(_pageCount);
          },
        ),

        // 页面大小
        const SizedBox(width: 16),
        const Text("页面大小： "),
        Container(
          height: 32,
          width: 92,
          color: Colors.white,
          child: DropdownButtonFormField<int>(
            value: size,
            items: (availableSizes ?? [10, 20, 30]).map((size) {
              return DropdownMenuItem<int>(
                child: Text(size.toString()),
                value: size,
              );
            }).toList(growable: false),
            onChanged: (value) {
              if (onChangeSize != null && value != null) {
                onChangeSize!(value);
              }
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

class InkWellIconButton extends StatelessWidget {
  const InkWellIconButton({
    Key? key,
    required this.icon,
    this.padding = 8,
    required this.onPressed,
    this.tip,
    this.disable = false,
  }) : super(key: key);

  final double padding;
  final Icon icon;
  final String? tip;
  final VoidCallback onPressed;
  final bool disable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: disable ? null : onPressed,
      child: Tooltip(
        message: tip,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Icon(
            icon.icon,
            color: disable ? theme.disabledColor : icon.color,
            size: icon.size,
          ),
        ),
      ),
    );
  }
}
