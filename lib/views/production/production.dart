class Production {
  late int? id;
  late String? name;
  late String? spec;
  late double? price;
  late double? cost;
  late String? unit;
  late DateTime? createAt;
  late int? createBy;

  Production({
    this.id,
    this.name,
    this.spec,
    this.price = 0,
    this.cost = 0,
    this.unit,
    this.createAt,
    this.createBy,
  });

  @override
  String toString() {
    return 'Production{id: $id, name: $name, spec: $spec, price: $price, cost: $cost, unit: $unit, createAt: $createAt, createBy: $createBy}';
  }
}
