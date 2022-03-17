import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_erp/entities/production.dart';
import 'package:useful_erp/views/production/production_create.dart';
import 'package:useful_erp/views/production/production_update.dart';
import 'package:useful_erp/widgets/dialogs/remove_alert.dart';
import 'package:useful_erp/widgets/dialogs/warning_dialog.dart';
import 'package:useful_erp/widgets/pagination.dart';
import 'package:useful_erp/widgets/table.dart';

class ProductionView extends StatelessWidget {
  ProductionView({Key? key}) : super(key: key);

  final TextEditingController _queryNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (BuildContext context) => ProductionViewState(
        queryName: _queryNameController,
      ),
      child: Column(children: [
        // 页面头
        Container(
          height: 92,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.ideographic,
            children: [
              // 标题
              Text("商品管理", style: theme.textTheme.headline2),
            ],
          ),
        ),

        // 页面内容
        Expanded(
          child: Column(children: [
            // 操作栏
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 操作栏 - 左边
                  Row(children: [
                    SizedBox(
                      height: 32,
                      child: Builder(builder: (context) {
                        final state = context.read<ProductionViewState>();
                        return ElevatedButton(
                          child: const Text("新增商品"),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return ProductionCreate(
                                  state: state,
                                );
                              },
                            );
                          },
                        );
                      }),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 32,
                      child: Builder(builder: (context) {
                        final state = context.read<ProductionViewState>();
                        return ElevatedButton(
                          child: const Text("批量删除"),
                          style: ElevatedButton.styleFrom(
                            primary: theme.errorColor,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                if (state.checked.isEmpty) {
                                  return WarningDialog(
                                    title: const Text('异常提示'),
                                    content: const Text('没有选中数据，无法执行删除操作'),
                                    onConfirm: () {
                                      Navigator.pop(context);
                                    },
                                  );
                                } else {
                                  return RemoveAlert(
                                    onCancel: () {
                                      Navigator.pop(context);
                                    },
                                    onConfirm: () {
                                      Navigator.pop(context);
                                      state.removeChecked();
                                    },
                                  );
                                }
                              },
                            );
                          },
                        );
                      }),
                    ),
                  ]),
                  // 操作栏 - 右边
                  Row(children: [
                    Container(
                      width: 192,
                      height: 32,
                      color: Colors.white,
                      child: TextField(
                        controller: _queryNameController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(8),
                          border: OutlineInputBorder(),
                          labelText: "请输入商品名",
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 32,
                      child: Builder(builder: (context) {
                        final state = context.read<ProductionViewState>();
                        return ElevatedButton(
                          child: const Text("查询"),
                          onPressed: () {
                            state.refreshData();
                          },
                        );
                      }),
                    ),
                  ]),
                ],
              ),
            ),

            // 数据表
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: SingleChildScrollView(
                  child: Container(
                    child: Consumer<ProductionViewState>(
                      builder: (context, state, _) {
                        return ElaTable<Map<String, dynamic>>(
                          data: state.pageData,
                          comparator: (a, b) => a['id'] == b['id'],
                          checkable: true,
                          checked: state.checked,
                          onCheck: state.check,
                          columns: [
                            ElaTableColumn<Map<String, dynamic>>(
                              label: const Text("id"),
                              cellBuilder: (context, row, _) {
                                return Text(row['id'].toString());
                              },
                            ),
                            ElaTableColumn<Map<String, dynamic>>(
                              label: const Text("名称"),
                              cellBuilder: (context, row, _) {
                                return Text(row['name'].toString());
                              },
                            ),
                            ElaTableColumn<Map<String, dynamic>>(
                              label: const Text("售价"),
                              cellBuilder: (context, row, _) {
                                return Text(row['price'].toString());
                              },
                            ),
                            ElaTableColumn<Map<String, dynamic>>(
                              label: const Text("成本"),
                              cellBuilder: (context, row, _) {
                                return Text(row['cost'].toString());
                              },
                            ),
                            ElaTableColumn<Map<String, dynamic>>(
                              label: const Text("操作"),
                              cellBuilder: (context, row, _) {
                                return Row(children: [
                                  TextButton(
                                    child: const Text("修改"),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return ProductionUpdate(
                                            item: row,
                                            state: state,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    child: const Text("删除"),
                                    style: TextButton.styleFrom(
                                      primary: theme.errorColor,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return RemoveAlert(
                                            onCancel: () {
                                              Navigator.pop(context);
                                            },
                                            onConfirm: () {
                                              Navigator.pop(context);
                                              state.remove(row);
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
                        );
                      },
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // 分页
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
              child: Builder(builder: (context) {
                final state = context.watch<ProductionViewState>();
                return Pagination(
                  total: state.pageTotal,
                  current: state.pageCurrent,
                  size: state.pageSize,
                  availableSizes: const [10, 20, 30],
                  onChangeCurrent: state.changeCurrent,
                  onChangeSize: state.changeSize,
                );
              }),
            ),
          ]),
        ),
      ]),
    );
  }
}

class ProductionViewState extends ChangeNotifier {
  // 页面数据
  late List<Map<String, dynamic>> pageData = [];
  late int pageCurrent = 1;
  late int pageSize = 10;
  late int pageTotal = 0;

  // 查询
  final TextEditingController queryName;

  // 操作
  late List<Map<String, dynamic>> checked = [];

  final ProductionRepository _repository = ProductionRepository();

  ProductionViewState({required this.queryName}) {
    refreshData();
  }

  // ==============================
  // region 数据查询
  // ==============================

  refreshData() async {
    pageTotal = await _repository.count();

    Map<String, dynamic> conditions = {};
    if (queryName.text.isNotEmpty) {
      conditions.putIfAbsent('name', () => queryName.text);
    }

    pageData = await _repository.findAll(
      current: pageCurrent,
      size: pageSize,
      conditions: conditions,
    );
    checked = [];
    notifyListeners();
  }

  changeCurrent(int value) {
    pageCurrent = value;
    refreshData();
  }

  changeSize(int value) {
    pageSize = value;
    pageCurrent = 1;
    refreshData();
  }

  // endregion

  // ==============================
  // region 数据选择
  // ==============================

  check(List<Map<String, dynamic>> checked) {
    this.checked = checked;
    notifyListeners();
  }

  // endregion

  // ==============================
  // region 数据操作
  // ==============================

  remove(item) {
    _repository.removeById(item['id']);
    refreshData();
  }

  removeChecked() {
    _repository.removeByIds(checked.map((e) {
      return e['id'] as int;
    }).toList(growable: false));
    refreshData();
  }

// endregion
}
