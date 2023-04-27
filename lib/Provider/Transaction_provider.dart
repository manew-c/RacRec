import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/Model/Transaction.dart';

class Transaction_provider with ChangeNotifier {
  List<Transaction> transactions = [
    Transaction(dose: 90.98, userlocation: 33.22, date: DateTime.now()),
    Transaction(dose: 10.12, userlocation: 10.22, date: DateTime.now())
  ];
//ดึงข้อมูล
  List<Transaction> getTransaction() {
    return transactions;
  }

  addTransaction(Transaction statement) {
    transactions.add(statement);
  }
}
