import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_erp/entities/bound.dart';
import 'package:useful_erp/views/outbound/outbound_editor.dart';
import 'package:useful_erp/views/outbound/outbound_form.dart';
import 'package:useful_erp/widgets/dialogs/content_dialog.dart';
import 'package:useful_erp/widgets/table.dart';

class OutboundOrderEditorState extends ChangeNotifier {
  OutboundOrderEditorState([List<OutboundFormValue>? items]) {
    this.items = items ?? [];
  }

  late List<OutboundFormValue> items;

  addItem(OutboundFormValue item) {
    items.add(item);
    notifyListeners();
  }

  replaceItem(OutboundFormValue item, int index) {
    items[index] = item;
    notifyListeners();
  }

  removeItem(int index) {
    items.removeAt(index);
    notifyListeners();
  }
}

class OutboundOrderEditor extends StatelessWidget {
  OutboundOrderEditor({Key? key, OutboundOrderEditorState? controller}) : super(key: key) {
    this.controller = controller ?? OutboundOrderEditorState();
  }

  final formController = OutboundFormController();

  final _boundRepository = BoundRepository();

  late final OutboundOrderEditorState controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (BuildContext context) => controller,
      child: ContentDialog(
        title: const Text("销售单"),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 销售单
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      height: 32,
                      child: Builder(builder: (context) {
                        final state = context.read<OutboundOrderEditorState>();
                        return ElevatedButton(
                          child: const Text("添加"),
                          onPressed: () async {
                            final result = await showDialog<OutboundFormValue>(
                              context: context,
                              builder: (context) => OutboundEditor(),
                            );
                            if (result != null) {
                              state.addItem(result);
                            }
                          },
                        );
                      }),
                    ),
                  ),
                  // 商品条目
                  Container(
                    width: 512,
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Builder(builder: (context) {
                      final state = context.watch<OutboundOrderEditorState>();
                      return ElaTable<OutboundFormValue>(
                        checkable: false,
                        data: state.items,
                        columns: [
                          ElaTableColumn<OutboundFormValue>(
                            label: const Text("商品"),
                            cellBuilder: (context, item, _) {
                              return Text(item.production?['name'].toString() ?? '');
                            },
                          ),
                          ElaTableColumn<OutboundFormValue>(
                            label: const Text("仓库"),
                            cellBuilder: (context, item, _) {
                              return Text(item.warehouse?['name'].toString() ?? '');
                            },
                          ),
                          ElaTableColumn<OutboundFormValue>(
                            label: const Text("单价"),
                            cellBuilder: (context, item, _) {
                              return Text(item.production?['price'].toString() ?? '');
                            },
                          ),
                          ElaTableColumn<OutboundFormValue>(
                            label: const Text("数量"),
                            cellBuilder: (context, item, index) {
                              return Text(item.count.toString());
                            },
                          ),
                          ElaTableColumn(
                            label: const Text("操作"),
                            cellBuilder: (context, outbound, index) {
                              return Row(
                                children: [
                                  TextButton(
                                    child: const Text("修改"),
                                    onPressed: () async {
                                      final newOutbound = await editOutbound(context, outbound);
                                      if (newOutbound == null) return;
                                      state.replaceItem(newOutbound, index);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text("删除"),
                                    style: TextButton.styleFrom(
                                      primary: theme.errorColor,
                                    ),
                                    onPressed: () {
                                      state.removeItem(index);
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
            // 间隔
            const SizedBox(width: 32),
            // 结算
            SizedBox(
              width: 256,
              child: Builder(builder: (context) {
                final state = context.watch<OutboundOrderEditorState>();

                // 计算总价
                final totalPrice = state.items.isNotEmpty
                    ? state.items.map((item) => item.production?['price'] * item.count).reduce((a, b) => a + b)
                    : 0;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in state.items)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${item.production?['name']} x ${item.count}"),
                          Text("${(item.production?['price'] as double) * (item.count ?? 0)}"),
                        ],
                      ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.ideographic,
                      children: [
                        const Text("收款金额"),
                        Text(
                          "$totalPrice",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
        onCancel: () {},
        onConfirm: () {
          for (var item in controller.items) {
            _boundRepository.create({
              'type': item.type?.name,
              'production': item.production?['id'],
              'warehouse': item.warehouse?['id'],
              'count': item.count,
              'createAt': item.createAt.toString(),
            });
          }
        },
      ),
    );
  }
}
