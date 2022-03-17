import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:useful_erp/entities/bound.dart';
import 'package:useful_erp/entities/production.dart';
import 'package:useful_erp/entities/warehouse.dart';
import 'package:useful_erp/utils/repository.dart';
import 'package:useful_erp/views/outbound/outbound_editor.dart';
import 'package:useful_erp/views/outbound/outbound_form.dart';
import 'package:useful_erp/views/outbound/outbound_order_editor.dart';
import 'package:useful_erp/widgets/table.dart';
import 'package:useful_erp/widgets/templates/table_template.dart';
import 'package:useful_erp/widgets/templates/table_view_template.dart';

class Outbound extends StatelessWidget {
  Outbound({Key? key}) : super(key: key);

  final _repository = BoundRepository();
  final _productionRepository = ProductionRepository();
  final _warehouseRepository = WarehouseRepository();

  late final _controller = TableTemplateController<OutboundFormValue>(
    onCount: (context) async => _repository.count(conditions: {
      'type': BoundType.SALE_OUT.name,
    }),
    onRefresh: (context, current, size) async {
      final result = await _repository.findAll(
        current: current,
        size: size,
        conditions: {
          'type': Condition(BoundType.SALE_OUT.name),
        },
      );
      return Future.wait(result.map((bound) async {
        return OutboundFormValue(
          id: bound['id'],
          production: await _productionRepository.getById(bound['production']),
          warehouse: await _warehouseRepository.getById(bound['warehouse']),
          count: bound['count'] as int,
          createAt: DateTime.parse(bound['createAt']),
        );
      }).toList(growable: false));
    },
    onCreate: (context) async => showDialog(
      context: context,
      builder: (context) => OutboundOrderEditor(),
    ),
    onUpdate: (context, data) async {
      final outbound = await editOutbound(context, data);
      if (outbound != null) {
        log('update, ${outbound.id}');
        _repository.updateById({
          'id': outbound.id,
          'production': outbound.production?['id'],
          'warehouse': outbound.warehouse?['id'],
          'count': outbound.count,
        });
      }
    },
    onRemove: (context, data) async => _repository.removeByIds(
      data.map((e) => e.id!).toList(growable: false),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return TableViewTemplate<OutboundFormValue>(
      controller: _controller,
      viewName: "销售出库",
      dataName: "出库记录",
      dataComparator: (a, b) => a.id == b.id,
      columns: [
        ElaTableColumn(
          label: const Text('商品'),
          cellBuilder: (context, row, _) {
            return Text(row.production?['name']);
          },
        ),
        ElaTableColumn(
          label: const Text('仓库'),
          cellBuilder: (context, row, _) {
            return Text(row.warehouse?['name'] ?? '');
          },
        ),
        ElaTableColumn(
          label: const Text('入库时间'),
          cellBuilder: (context, row, _) {
            final d = row.createAt!;
            return Text('${d.year}-${d.month}-${d.day} ${d.hour}:${d.minute}:${d.second}');
          },
        ),
        ElaTableColumn(
          label: const Text('数量'),
          cellBuilder: (context, row, _) {
            return Text(row.count.toString());
          },
        ),
      ],
    );
  }
}
