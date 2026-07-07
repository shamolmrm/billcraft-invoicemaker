import 'package:uuid/uuid.dart';

class InvoiceItemModel {
  final String id;
  final String description;
  final String? itemNotes;
  final double quantity;
  final String unit;
  final double price;
  final double? discountPercent;
  final double? taxPercent;

  InvoiceItemModel({
    String? id,
    required this.description,
    this.itemNotes,
    required this.quantity,
    this.unit = 'pcs',
    required this.price,
    this.discountPercent,
    this.taxPercent,
  }) : id = id ?? const Uuid().v4();

  double get amount {
    double base = quantity * price;
    if (discountPercent != null && discountPercent! > 0) {
      base -= base * discountPercent! / 100;
    }
    if (taxPercent != null && taxPercent! > 0) {
      base += base * taxPercent! / 100;
    }
    return base;
  }

  double get baseAmount => quantity * price;
  double get discountAmount => discountPercent != null ? baseAmount * discountPercent! / 100 : 0;
  double get taxAmount {
    double base = baseAmount - discountAmount;
    return taxPercent != null ? base * taxPercent! / 100 : 0;
  }

  InvoiceItemModel copyWith({
    String? description,
    String? itemNotes,
    double? quantity,
    String? unit,
    double? price,
    double? discountPercent,
    double? taxPercent,
  }) {
    return InvoiceItemModel(
      id: id,
      description: description ?? this.description,
      itemNotes: itemNotes ?? this.itemNotes,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      discountPercent: discountPercent ?? this.discountPercent,
      taxPercent: taxPercent ?? this.taxPercent,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'description': description,
        'itemNotes': itemNotes,
        'quantity': quantity,
        'unit': unit,
        'price': price,
        'discountPercent': discountPercent,
        'taxPercent': taxPercent,
      };

  factory InvoiceItemModel.fromMap(Map<String, dynamic> map) => InvoiceItemModel(
        id: map['id'],
        description: map['description'] ?? '',
        itemNotes: map['itemNotes'],
        quantity: (map['quantity'] ?? 1).toDouble(),
        unit: map['unit'] ?? 'pcs',
        price: (map['price'] ?? 0).toDouble(),
        discountPercent: map['discountPercent']?.toDouble(),
        taxPercent: map['taxPercent']?.toDouble(),
      );
}
