import 'package:useful_erp/utils/repository.dart';

enum BoundType {
  RECORD_IN,
  SALE_OUT,
}

class BoundRepository extends Repository {
  BoundRepository() : super(table: "bound");
}
