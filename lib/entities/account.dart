import 'package:useful_erp/utils/repository.dart';

class Account {
  Account(this.name, this.username, this.password);

  final String name;
  final String username;
  final String password;
}

class AccountRepository extends Repository {
  AccountRepository() : super(table: "account");
}
