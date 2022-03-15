import 'package:flutter/material.dart';
import 'package:useful_erp/utils/events.dart';
import 'package:useful_erp/widgets/table.dart';
import 'package:useful_erp/widgets/templates/table_template.dart';
import 'package:useful_erp/widgets/templates/view_template.dart';

typedef CountEvent = Future<int> Function(BuildContext context);
typedef RefreshEvent<T> = Future<List<T>> Function(BuildContext context, int current, int size);
typedef CreateEvent = Future<void> Function(BuildContext context);
typedef UpdateEvent<T> = Future<void> Function(BuildContext context, T data);
typedef RemoveEvent<T> = Future<void> Function(BuildContext context, List<T> list);

class TableViewTemplateController<T> extends ChangeNotifier {
  TableViewTemplateController({
    required this.onCount,
    required this.onRefresh,
    required this.onCreate,
    required this.onUpdate,
    required this.onRemove,
  });

  final CountEvent onCount;
  final RefreshEvent<T> onRefresh;
  final CreateEvent onCreate;
  final UpdateEvent<T> onUpdate;
  final RemoveEvent<T> onRemove;

  // ==============================
  // 展示数据
  // ==============================

  late List<T> pageData = [];
  late int pageCurrent = 1;
  late int pageSize = 10;
  late int pageTotal = 0;

  refreshData(BuildContext context) async {
    pageTotal = await onCount(context);
    pageData = await onRefresh(context, pageCurrent, pageSize);
    checked.clear();
    notifyListeners();
  }

  changeCurrent(BuildContext context, int value) {
    pageCurrent = value;
    refreshData(context);
  }

  changeSize(BuildContext context, int value) {
    pageSize = value;
    pageCurrent = 1;
    refreshData(context);
  }

  // ==============================
  // 选择数据
  // ==============================

  late List<T> checked = [];

  check(List<T> checked) {
    this.checked = checked;
    notifyListeners();
  }

  // ==============================
  // 操作数据
  // ==============================

  create(BuildContext context) async {
    await onCreate(context);
    refreshData(context);
  }

  update(BuildContext context, T item) async {
    await onUpdate(context, item);
    refreshData(context);
  }

  remove(BuildContext context, T item) async {
    await onRemove(context, [item]);
    refreshData(context);
  }

  removeChecked(BuildContext context) async {
    await onRemove(context, checked);
    refreshData(context);
  }
}

class TableViewTemplate<T> extends StatelessWidget {
  const TableViewTemplate({
    Key? key,
    required this.viewName,
    required this.dataName,
    this.dataComparator,
    this.actions,
    this.queries,
    required this.columns,
    this.controller,
  }) : super(key: key);

  final String viewName;

  final String dataName;
  final BoolComparator<T>? dataComparator;

  final List<Widget>? actions;
  final List<Widget>? queries;
  final List<ElaTableColumn<T>> columns;

  final TableTemplateController<T>? controller;

  @override
  Widget build(BuildContext context) {
    return ViewTemplate(
      name: viewName,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: TableTemplate(
          dataName: dataName,
          dataComparator: dataComparator,
          columns: columns,
          actions: actions,
          queries: queries,
          controller: controller,
        ),
      ),
    );
  }
}
