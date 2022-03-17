import 'package:flutter/material.dart';
import 'package:useful_erp/entities/bound.dart';
import 'package:useful_erp/entities/production.dart';
import 'package:useful_erp/utils/repository.dart';
import 'package:useful_erp/views/production/production.dart';
import 'package:useful_erp/views/production/production_editor.dart';
import 'package:useful_erp/widgets/table.dart';
import 'package:useful_erp/widgets/templates/table_template.dart';
import 'package:useful_erp/widgets/templates/table_view_template.dart';

class ProductionView extends StatelessWidget {
  ProductionView({Key? key}) : super(key: key);

  final _repository = ProductionRepository();
  final _boundRepository = BoundRepository();

  final _queryName = TextEditingController();

  late final _controller = TableTemplateController<Production>(
    onCount: (_) async {
      return _repository.count();
    },
    onRefresh: (_, current, size) async {
      final Map<String, Condition> conditions = {};
      if (_queryName.text.isNotEmpty) {
        conditions['name'] = Condition(_queryName.text, Operator.like);
      }

      final result = await _repository.findAll(
        current: current,
        size: size,
        conditions: conditions.isEmpty ? null : conditions,
      );

      return result.map((map) {
        return Production(
          id: map['id'],
          name: map['name'],
          spec: map['spec'],
          cost: map['cost'],
          price: map['price'],
          unit: map['unit'],
          createAt: DateTime.parse(map['createAt']),
          createBy: null,
        );
      }).toList(growable: false);
    },
    onCreate: (context) async {
      final result = await editProduction(context);
      if (result == null) return;
      _repository.create({
        'name': result.name,
        'spec': result.spec,
        'cost': result.cost,
        'price': result.price,
        'unit': result.unit,
        'createAt': result.createAt.toString(),
      });
    },
    onUpdate: (context, data) async {
      final result = await editProduction(context, data);
      if (result == null) return;
      _repository.updateById({
        'id': result.id,
        'name': result.name,
        'spec': result.spec,
        'cost': result.cost,
        'price': result.price,
        'unit': result.unit,
        'createAt': result.createAt.toString(),
      });
    },
    onRemove: (_, data) async {
      _repository.removeByIds(
        data.map((item) => item.id!).toList(growable: false),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return TableViewTemplate<Production>(
      controller: _controller,
      viewName: "商品管理",
      dataName: "商品",
      dataComparator: (a, b) => a.id == b.id,
      queries: [
        Container(
          width: 192,
          height: 32,
          margin: const EdgeInsets.only(right: 16),
          color: Colors.white,
          child: TextField(
            controller: _queryName,
            decoration: const InputDecoration(
              labelText: "请输入商品名",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(8),
            ),
          ),
        ),
      ],
      columns: [
        ElaTableColumn<Production>(
          label: const Text("名称"),
          cellBuilder: (context, production, index) => Text("${production.name}"),
        ),
        ElaTableColumn<Production>(
          label: const Text("规格"),
          cellBuilder: (context, production, index) => Text("${production.spec}"),
        ),
        ElaTableColumn<Production>(
          label: const Text("成本"),
          cellBuilder: (context, production, index) => Text("${production.cost}"),
        ),
        ElaTableColumn<Production>(
          label: const Text("售价"),
          cellBuilder: (context, production, index) => Text("${production.price}"),
        ),
        ElaTableColumn<Production>(
          label: const Text("单位"),
          cellBuilder: (context, production, index) => Text(production.unit ?? ''),
        ),
        ElaTableColumn<Production>(
          label: const Text("数量"),
          cellBuilder: (context, production, index) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _boundRepository.findAll(conditions: {
                'production': Condition(production.id.toString()),
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text("NaN");
                }

                final data = snapshot.data!;
                if (data.isEmpty) {
                  return const Text("0");
                }

                final count = data.map((bound) {
                  final type = BoundType.values.firstWhere((item) => item.name == bound['type']);
                  switch (type) {
                    case BoundType.RECORD_IN:
                      return int.parse(bound['count']);
                    case BoundType.SALE_OUT:
                      return -int.parse(bound['count']);
                  }
                }).reduce((value, count) {
                  return value + count;
                });

                return Text("$count");
              },
            );
          },
        ),
      ],
    );
  }
}
