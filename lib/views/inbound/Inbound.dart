import 'package:flutter/material.dart';
import 'package:useful_erp/entities/bound.dart';
import 'package:useful_erp/utils/repository.dart';
import 'package:useful_erp/views/inbound/inbound_create.dart';
import 'package:useful_erp/views/inbound/inbound_update.dart';
import 'package:useful_erp/widgets/table.dart';
import 'package:useful_erp/widgets/templates/table_template.dart';
import 'package:useful_erp/widgets/templates/table_view_template.dart';

class InboundView extends StatelessWidget {
  InboundView({Key? key}) : super(key: key);

  final _repository = BoundRepository();

  late final _controller = TableTemplateController<Map<String, dynamic>>(
    onCount: (context) async => _repository.count(conditions: {
      'type': BoundType.RECORD_IN.name,
    }),
    onRefresh: (context, current, size) async => _repository.findAll(
      current: current,
      size: size,
      conditions: {
        'type': Condition(BoundType.RECORD_IN.name),
      },
    ),
    onCreate: (context) async => showDialog(
      context: context,
      builder: (context) => InboundCreate(),
    ),
    onUpdate: (context, data) async => showDialog(
      context: context,
      builder: (context) => InboundUpdate(data),
    ),
    onRemove: (context, data) async => _repository.removeByIds(
      data.map((e) => e['id'] as int).toList(growable: false),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return TableViewTemplate<Map<String, dynamic>>(
      controller: _controller,
      viewName: "登记入库",
      dataName: '入库记录',
      dataComparator: (a, b) => a['id'] == b['id'],
      columns: [
        ElaTableColumn(
          label: const Text('商品'),
          cellBuilder: (context, row, _) {
            return Text(row['production'].toString());
          },
        ),
        ElaTableColumn(
          label: const Text('仓库'),
          cellBuilder: (context, row, _) {
            return Text(row['warehouse'].toString());
          },
        ),
        ElaTableColumn(
          label: const Text('入库时间'),
          cellBuilder: (context, row, _) {
            final d = DateTime.parse(row['createAt'].toString());
            return Text('${d.year}-${d.month}-${d.day} ${d.hour}:${d.minute}:${d.second}');
          },
        ),
        ElaTableColumn(
          label: const Text('数量'),
          cellBuilder: (context, row, _) {
            return Text(row['count'].toString());
          },
        ),
      ],
    );
  }
}
