import 'package:uuid/uuid.dart';

class ClientModel {
  final String id;
  final String name;
  final String? company;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? zip;
  final String? country;
  final String? notes;
  final double totalInvoiced;
  final double totalPaid;
  final double outstanding;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClientModel({
    String? id,
    required this.name,
    this.company,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.notes,
    this.totalInvoiced = 0,
    this.totalPaid = 0,
    this.outstanding = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get fullAddress {
    final parts = [address, city, state, zip, country]
        .where((e) => e != null && e.isNotEmpty)
        .join(', ');
    return parts;
  }

  ClientModel copyWith({
    String? name,
    String? company,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? zip,
    String? country,
    String? notes,
    double? totalInvoiced,
    double? totalPaid,
    double? outstanding,
  }) {
    return ClientModel(
      id: id,
      name: name ?? this.name,
      company: company ?? this.company,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      country: country ?? this.country,
      notes: notes ?? this.notes,
      totalInvoiced: totalInvoiced ?? this.totalInvoiced,
      totalPaid: totalPaid ?? this.totalPaid,
      outstanding: outstanding ?? this.outstanding,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'company': company,
        'email': email,
        'phone': phone,
        'address': address,
        'city': city,
        'state': state,
        'zip': zip,
        'country': country,
        'notes': notes,
        'totalInvoiced': totalInvoiced,
        'totalPaid': totalPaid,
        'outstanding': outstanding,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ClientModel.fromMap(Map<String, dynamic> map) => ClientModel(
        id: map['id'],
        name: map['name'] ?? '',
        company: map['company'],
        email: map['email'] ?? '',
        phone: map['phone'],
        address: map['address'],
        city: map['city'],
        state: map['state'],
        zip: map['zip'],
        country: map['country'],
        notes: map['notes'],
        totalInvoiced: (map['totalInvoiced'] ?? 0).toDouble(),
        totalPaid: (map['totalPaid'] ?? 0).toDouble(),
        outstanding: (map['outstanding'] ?? 0).toDouble(),
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      );
}
