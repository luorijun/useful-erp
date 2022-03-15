import 'package:flutter/material.dart';
import 'package:useful_erp/utils/events.dart';

typedef SelectEvent<T> = void Function(T selected);

// ignore: must_be_immutable
class ElaTable<T> extends StatelessWidget {
  ElaTable({
    Key? key,
    List<ElaTableColumn<T>>? columns,
    List<T>? data,
    this.checkable = false,
    List<T>? checked,
    this.onCheck,
    this.comparator,
    this.selectable = true,
    this.selected,
    this.onSelect,
  }) : super(key: key) {
    this.columns = columns ?? [];
    this.data = data ?? [];
    this.checked = checked ?? [];
  }

  late List<T> data;
  final BoolComparator<T>? comparator;
  late List<ElaTableColumn<T>> columns;

  final bool checkable;
  late List<T> checked;
  final ActionEvent<List<T>>? onCheck;

  final bool selectable;
  final T? selected;
  final SelectEvent<T>? onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 处理表格宽度
    final columnWidthsList = columns.map((column) => column.width).toList();
    if (checkable) columnWidthsList.insert(0, 40);

    final columnWidthMap = {
      for (var i = 0; i < columnWidthsList.length; i++)
        i: (columnWidthsList[i] == null ? const IntrinsicColumnWidth(flex: 1) : FixedColumnWidth(columnWidthsList[i]!)),
    };

    int i = 0;

    // 表头行

    // 数据行
    final body = [
      for (var i = 0; i < data.length; i++)
        TableRow(
          children: [
            if (checkable)
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Checkbox(
                  value: checked.any((test) => comparator != null ? comparator!(test, data[i]) : test == data[i]),
                  onChanged: (value) {
                    if (onCheck == null) return;
                    if (value == true) {
                      checked.add(data[i]);
                    } else {
                      checked.removeWhere((test) {
                        return comparator == null ? test == data[i] : comparator!(test, data[i]);
                      });
                    }
                    onCheck!(checked);
                  },
                ),
              ),
            ...columns.map((column) {
              final cell = column.cellBuilder == null ? Container() : column.cellBuilder!(context, data[i], i);
              return Container(
                height: 40,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: cell,
              );
            }).toList(growable: false),
          ],
        )
    ];

    return Column(
      children: [
        // 渲染表格
        Table(
          columnWidths: columnWidthMap,
          children: [
            // ==============================
            // 表头
            // ==============================
            TableRow(
              children: [
                // 复选框
                if (checkable)
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Checkbox(
                      tristate: true,
                      value: checked.isEmpty
                          ? false
                          : checked.length == data.length
                              ? true
                              : null,
                      onChanged: (value) {
                        if (onCheck == null) return;
                        switch (value) {
                          case true:
                            onCheck!(List.of(data));
                            break;
                          case null:
                          case false:
                            if (checked.length == data.length) {
                              onCheck!([]);
                            } else {
                              onCheck!(List.of(data));
                            }
                            break;
                        }
                      },
                    ),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: theme.dividerColor)),
                    ),
                  ),
                ...columns.map((column) {
                  // 计算描边
                  final isFirst = !checkable && i++ == 0;
                  final border = isFirst
                      ? Border(
                          bottom: BorderSide(color: theme.dividerColor),
                        )
                      : Border(
                          left: BorderSide(color: theme.dividerColor),
                          bottom: BorderSide(color: theme.dividerColor),
                        );

                  return Container(
                    height: 40,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: column.label,
                    decoration: BoxDecoration(border: border),
                  );
                }).toList(growable: false),
              ],
            ),
            // ==============================
            // 数据
            // ==============================
            if (data.isNotEmpty) ...body,
          ],
        ),
        if (data.isEmpty)
          Container(
            height: 40,
            alignment: Alignment.center,
            child: const Text('暂无数据'),
          ),
      ],
    );
  }
}

typedef TableCellBuilder<T> = Widget Function(
  BuildContext context,
  T row,
  int index,
);

class ElaTableColumn<T> {
  ElaTableColumn({
    this.label,
    this.cellBuilder,
    this.width,
    this.alignment = Alignment.center,
  });

  final Widget? label;
  final TableCellBuilder<T>? cellBuilder;
  final double? width;
  final Alignment alignment;
}
