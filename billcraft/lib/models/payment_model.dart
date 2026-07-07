import 'package:uuid/uuid.dart';

class PaymentModel {
  final String id;
  final String invoiceId;
  final double amount;
  final DateTime date;
  final String method;
  final String? note;

  PaymentModel({
    String? id,
    required this.invoiceId,
    required this.amount,
    required this.date,
    required this.method,
    this.note,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'invoiceId': invoiceId,
        'amount': amount,
        'date': date.toIso8601String(),
        'method': method,
        'note': note,
      };

  factory PaymentModel.fromMap(Map<String, dynamic> map) => PaymentModel(
        id: map['id'],
        invoiceId: map['invoiceId'] ?? '',
        amount: (map['amount'] ?? 0).toDouble(),
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
        method: map['method'] ?? 'Cash',
        note: map['note'],
      );
}
