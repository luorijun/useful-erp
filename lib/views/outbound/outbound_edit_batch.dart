import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_erp/entities/bound.dart';
import 'package:useful_erp/entities/production.dart';
import 'package:useful_erp/entities/warehouse.dart';
import 'package:useful_erp/utils/repository.dart';
import 'package:useful_erp/widgets/dialogs/warning_dialog.dart';
import 'package:useful_erp/widgets/table.dart';
import 'package:useful_erp/widgets/templates/table_template.dart';
import 'package:useful_erp/widgets/templates/view_template.dart';

class OutboundEditBatchState extends ChangeNotifier {
  List<Map<String, dynamic>> selected = [];
  Map<int, int> counts = {};

  count(Map<String, dynamic> production, int count) {
    counts[production['id']] = count;
  }

  add(Map<String, dynamic> production) {
    final index = selected.indexWhere((item) => item['id'] == production['id']);
    if (index == -1) {
      selected.add({
        ...production,
        'count': counts[production['id']] ?? 1,
      });
    }
    notifyListeners();
  }

  remove(Map<String, dynamic> production) {
    selected.removeWhere((element) => element['id'] == production['id']);
    notifyListeners();
  }

  clear() {
    selected = [];
    counts = {};
    notifyListeners();
  }
}

class OutboundEditBatch extends StatelessWidget {
  OutboundEditBatch({Key? key}) : super(key: key);

  final _productionRepository = ProductionRepository();
  final _warehouseRepository = WarehouseRepository();
  final _outboundRepository = BoundRepository();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OutboundEditBatchState(),
      child: ViewTemplate(
        name: '销售出库',
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 商品选择
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _productionRepository.findAll(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    // 商品列表
                    return ProductionSelector();
                  },
                ),
              ),
            ),

            // 结算单
            Container(
              width: 384,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 商品列项
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 表头
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("商品"),
                          Text("单价"),
                          Text("数量"),
                          Text("小计"),
                        ],
                      ),
                      Builder(builder: (context) {
                        final state = context.watch<OutboundEditBatchState>();
                        return Column(
                          children: state.selected.map((e) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    "${e['name']}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    "${e['price']}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    "${e['count']}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    "${e['price'] * e['count']}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            );
                          }).toList(growable: false),
                        );
                      }),
                    ],
                  ),
                  // 统计和结算
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 48),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "总计",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Builder(builder: (context) {
                              final state = context.watch<OutboundEditBatchState>();
                              final value = state.selected.isNotEmpty
                                  ? state.selected
                                      .map(
                                        (e) => e['price'] * e['count'],
                                      )
                                      .reduce(
                                        (value, element) => value + element,
                                      )
                                  : 0;
                              return Text(
                                value.toString(),
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: Builder(builder: (context) {
                          final state = context.read<OutboundEditBatchState>();
                          return ElevatedButton(
                            child: const Text("结算"),
                            onPressed: () async {
                              if (state.selected.isEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return WarningDialog(
                                      title: const Text('无法结算'),
                                      content: const Text("请先选择商品"),
                                      onConfirm: () => Navigator.pop(context),
                                    );
                                  },
                                );
                                return;
                              }
                              final warehouses = await _warehouseRepository.findAll(size: 1);
                              if (warehouses.isEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return WarningDialog(
                                      title: const Text('无法结算'),
                                      content: const Text("在结算前，需要有至少一个仓库，第一个仓库会作为默认仓库"),
                                      onConfirm: () => Navigator.pop(context),
                                    );
                                  },
                                );
                                return;
                              }

                              final now = DateTime.now();
                              for (var selected in state.selected) {
                                _outboundRepository.create({
                                  'type': BoundType.SALE_OUT.name,
                                  'production': selected['id'].toString(),
                                  'warehouse': warehouses[0]['id'].toString(),
                                  'count': selected['count'],
                                  'createAt': now.toString(),
                                });
                              }
                              state.clear();
                            },
                          );
                        }),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductionSelector extends StatelessWidget {
  ProductionSelector({Key? key}) : super(key: key);

  final _name = TextEditingController();
  final _repository = ProductionRepository();
  late final _controller = TableTemplateController(
    onCount: (_) async => _repository.count(),
    onRefresh: (_, current, size) async {
      Map<String, Condition> conditions = {};
      if (_name.text.isNotEmpty) {
        conditions['name'] = Condition(_name.text, Operator.like);
      }
      return _repository.findAll(
        current: current,
        size: size,
        conditions: conditions.isNotEmpty ? conditions : null,
      );
    },
    onCreate: (_) async {},
    onUpdate: (_, data) async {},
    onRemove: (_, data) async {},
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TableTemplate<Map<String, dynamic>>(
      controller: _controller,
      dataName: '',
      dataComparator: (a, b) => a['id'] == b['id'],
      creatable: false,
      updatable: false,
      removable: false,
      checkable: false,
      columns: [
        ElaTableColumn<Map<String, dynamic>>(
          label: const Text("名称"),
          cellBuilder: (context, row, _) {
            return Text(row['name'].toString());
          },
        ),
        ElaTableColumn<Map<String, dynamic>>(
          label: const Text("单价"),
          cellBuilder: (context, row, _) {
            return Text(row['price'].toString());
          },
        ),
        ElaTableColumn<Map<String, dynamic>>(
          label: const Text("数量"),
          cellBuilder: (context, row, _) {
            final state = context.read<OutboundEditBatchState>();
            return NumberField(
              value: state.counts[row['id']],
              onChange: (value) {
                state.count(row, value);
              },
            );
          },
        ),
      ],
      rowOperations: (context, item) {
        final state = context.watch<OutboundEditBatchState>();
        return [
          if (state.selected.indexWhere((element) => element['id'] == item['id']) == -1)
            ElevatedButton(
              child: const Text("选择"),
              onPressed: () => state.add(item),
            )
          else
            ElevatedButton(
              child: const Text("取消"),
              style: ElevatedButton.styleFrom(primary: theme.errorColor),
              onPressed: () => state.remove(item),
            )
        ];
      },
      queries: [
        Container(
          width: 192,
          height: 32,
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: "请输入商品名",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(8),
            ),
          ),
        )
      ],
    );
  }
}

class NumberField extends StatelessWidget {
  const NumberField({Key? key, required this.onChange, this.value}) : super(key: key);

  final int? value;
  final Function(int value) onChange;

  @override
  Widget build(BuildContext context) {
    final _controller = TextEditingController(text: value?.toString() ?? '1');
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(Icons.add),
              ),
              onTap: () {
                final value = int.parse(_controller.text) + 1;
                _controller.text = (value).toString();
                onChange(value);
              },
            ),
          ),
        ),
        SizedBox(
          width: 32,
          height: 32,
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(8),
            ),
            onChanged: (value) {
              onChange(int.parse(value));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(Icons.remove),
              ),
              onTap: () {
                final value = max(int.parse(_controller.text) - 1, 1);
                _controller.text = (value).toString();
                onChange(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}
