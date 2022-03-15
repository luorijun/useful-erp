import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_erp/utils/events.dart';
import 'package:useful_erp/widgets/dialogs/remove_alert.dart';
import 'package:useful_erp/widgets/dialogs/warning_dialog.dart';
import 'package:useful_erp/widgets/pagination.dart';
import 'package:useful_erp/widgets/table.dart';
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

  final TableViewTemplateController<T>? controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ViewTemplate(
      name: viewName,
      content: ChangeNotifierProvider<TableViewTemplateController<T>>(
        create: (context) {
          if (controller == null) {
            return TableViewTemplateController(
              onCount: (_) async => 0,
              onRefresh: (_, c, s) async => [],
              onCreate: (_) async {},
              onUpdate: (_, e) async {},
              onRemove: (_, e) async {},
            );
          }

          controller!.refreshData(context);
          return controller!;
        },
        child: Column(children: [
          // 操作栏
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 左半部分
                Row(children: [
                  // 新增
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      height: 32,
                      child: Builder(builder: (context) {
                        final state = context.read<TableViewTemplateController<T>>();
                        return ElevatedButton(
                          child: Text("新增$dataName"),
                          onPressed: () {
                            state.create(context);
                          },
                        );
                      }),
                    ),
                  ),
                  // 批量删除
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      height: 32,
                      child: Builder(builder: (context) {
                        final state = context.read<TableViewTemplateController<T>>();
                        return ElevatedButton(
                          child: const Text("批量删除"),
                          style: ElevatedButton.styleFrom(
                            primary: theme.errorColor,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                // 选择数据提示
                                if (state.checked.isEmpty) {
                                  return WarningDialog(
                                    title: const Text('异常提示'),
                                    content: const Text('没有选中数据，无法执行删除操作'),
                                    onConfirm: () {
                                      Navigator.pop(context);
                                    },
                                  );
                                }

                                // 删除数据提示
                                return RemoveAlert(
                                  onCancel: () {
                                    Navigator.pop(context);
                                  },
                                  onConfirm: () {
                                    Navigator.pop(context);
                                    state.removeChecked(context);
                                  },
                                );
                              },
                            );
                          },
                        );
                      }),
                    ),
                  ),
                  // 传入参数
                  ...?actions,
                ]),

                // 右半部分
                Row(children: [
                  ...?queries,
                  if (queries?.isNotEmpty ?? false)
                    SizedBox(
                      height: 32,
                      child: Builder(builder: (context) {
                        final state = context.read<TableViewTemplateController<T>>();
                        return ElevatedButton(
                          child: const Text("查询"),
                          onPressed: () => state.refreshData(context),
                        );
                      }),
                    ),
                ]),
              ],
            ),
          ),

          // 表格
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Builder(builder: (context) {
                    final state = context.watch<TableViewTemplateController<T>>();

                    return ElaTable<T>(
                      comparator: dataComparator ?? (a, b) => a == b,
                      checkable: true,
                      checked: state.checked,
                      data: state.pageData,
                      columns: [
                        // 数据列
                        ...columns,
                        // 操作列
                        ElaTableColumn(
                          label: const Text("操作"),
                          cellBuilder: (context, item, _) {
                            return Row(children: [
                              TextButton(
                                child: const Text("修改"),
                                onPressed: () {
                                  state.update(context, item);
                                },
                              ),
                              TextButton(
                                child: const Text("删除"),
                                style: TextButton.styleFrom(
                                  primary: theme.errorColor,
                                ),
                                onPressed: () {
                                  // 删除数据提示
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return RemoveAlert(
                                        onCancel: () {
                                          Navigator.pop(context);
                                        },
                                        onConfirm: () {
                                          Navigator.pop(context);
                                          state.remove(context, item);
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ]);
                          },
                        ),
                      ],
                      onCheck: state.check,
                    );
                  }),
                ),
              ),
            ),
          ),

          // 分页
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
            child: Builder(builder: (context) {
              final state = context.watch<TableViewTemplateController<T>>();

              return Pagination(
                total: state.pageTotal,
                current: state.pageCurrent,
                size: state.pageSize,
                availableSizes: const [10, 20, 30],
                onChangeCurrent: (current) => state.changeCurrent(context, current),
                onChangeSize: (size) => state.changeSize(context, size),
              );
            }),
          ),
        ]),
      ),
    );
  }
}
