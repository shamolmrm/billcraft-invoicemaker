import 'package:uuid/uuid.dart';

class ItemModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String unit;
  final double? taxRate;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemModel({
    String? id,
    required this.name,
    this.description,
    required this.price,
    this.unit = 'pcs',
    this.taxRate,
    this.category,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  ItemModel copyWith({
    String? name,
    String? description,
    double? price,
    String? unit,
    double? taxRate,
    String? category,
  }) {
    return ItemModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      taxRate: taxRate ?? this.taxRate,
      category: category ?? this.category,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'unit': unit,
        'taxRate': taxRate,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ItemModel.fromMap(Map<String, dynamic> map) => ItemModel(
        id: map['id'],
        name: map['name'] ?? '',
        description: map['description'],
        price: (map['price'] ?? 0).toDouble(),
        unit: map['unit'] ?? 'pcs',
        taxRate: map['taxRate']?.toDouble(),
        category: map['category'],
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      );
}
