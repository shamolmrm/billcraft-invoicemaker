import 'invoice_item_model.dart';

enum InvoiceStatus { draft, unpaid, partiallyPaid, paid, overdue, cancelled }

extension InvoiceStatusExt on InvoiceStatus {
  String get label {
    switch (this) {
      case InvoiceStatus.paid: return 'Paid';
      case InvoiceStatus.unpaid: return 'Unpaid';
      case InvoiceStatus.partiallyPaid: return 'Partially Paid';
      case InvoiceStatus.overdue: return 'Overdue';
      case InvoiceStatus.cancelled: return 'Cancelled';
      default: return 'Draft';
    }
  }

  String get firestoreValue {
    switch (this) {
      case InvoiceStatus.paid: return 'paid';
      case InvoiceStatus.unpaid: return 'unpaid';
      case InvoiceStatus.partiallyPaid: return 'partially_paid';
      case InvoiceStatus.overdue: return 'overdue';
      case InvoiceStatus.cancelled: return 'cancelled';
      default: return 'draft';
    }
  }

  static InvoiceStatus fromString(String? value) {
    switch (value) {
      case 'paid': return InvoiceStatus.paid;
      case 'unpaid': return InvoiceStatus.unpaid;
      case 'partially_paid': return InvoiceStatus.partiallyPaid;
      case 'overdue': return InvoiceStatus.overdue;
      case 'cancelled': return InvoiceStatus.cancelled;
      default: return InvoiceStatus.draft;
    }
  }
}

class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String clientId;
  final String clientName;
  final String clientEmail;
  final String clientAddress;
  final String? clientPhone;
  final String? clientCompany;
  final DateTime issueDate;
  final DateTime dueDate;
  final String? poNumber;
  final List<InvoiceItemModel> items;
  final double subtotal;
  final double discountPercent;
  final double discountAmount;
  final double taxPercent;
  final double taxAmount;
  final double total;
  final double amountPaid;
  final double balanceDue;
  final InvoiceStatus status;
  final String? paymentMethod;
  final String? notes;
  final String? terms;
  final String templateId;
  final String currency;
  final String currencySymbol;
  final String? signatureUrl;
  final String? logoUrl;
  final bool isEstimate;
  final String? validUntil;
  final String? convertedToInvoiceId;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.clientId,
    required this.clientName,
    this.clientEmail = '',
    this.clientAddress = '',
    this.clientPhone,
    this.clientCompany,
    required this.issueDate,
    required this.dueDate,
    this.poNumber,
    required this.items,
    required this.subtotal,
    this.discountPercent = 0,
    this.discountAmount = 0,
    this.taxPercent = 0,
    this.taxAmount = 0,
    required this.total,
    this.amountPaid = 0,
    required this.balanceDue,
    this.status = InvoiceStatus.unpaid,
    this.paymentMethod,
    this.notes,
    this.terms,
    this.templateId = 'modern',
    this.currency = 'USD',
    this.currencySymbol = '\$',
    this.signatureUrl,
    this.logoUrl,
    this.isEstimate = false,
    this.validUntil,
    this.convertedToInvoiceId,
    required this.createdAt,
    required this.updatedAt,
  });

  double get amountPaidPercent => total > 0 ? (amountPaid / total * 100) : 0;

  bool get isActuallyOverdue =>
      (status == InvoiceStatus.unpaid || status == InvoiceStatus.partiallyPaid) &&
      DateTime.now().isAfter(dueDate);

  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  InvoiceModel copyWith({
    String? invoiceNumber,
    String? clientId,
    String? clientName,
    String? clientEmail,
    String? clientAddress,
    String? clientPhone,
    String? clientCompany,
    DateTime? issueDate,
    DateTime? dueDate,
    String? poNumber,
    List<InvoiceItemModel>? items,
    double? subtotal,
    double? discountPercent,
    double? discountAmount,
    double? taxPercent,
    double? taxAmount,
    double? total,
    double? amountPaid,
    double? balanceDue,
    InvoiceStatus? status,
    String? paymentMethod,
    String? notes,
    String? terms,
    String? templateId,
    String? currency,
    String? currencySymbol,
    String? signatureUrl,
    String? logoUrl,
  }) {
    return InvoiceModel(
      id: id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientAddress: clientAddress ?? this.clientAddress,
      clientPhone: clientPhone ?? this.clientPhone,
      clientCompany: clientCompany ?? this.clientCompany,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      poNumber: poNumber ?? this.poNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmount: discountAmount ?? this.discountAmount,
      taxPercent: taxPercent ?? this.taxPercent,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      amountPaid: amountPaid ?? this.amountPaid,
      balanceDue: balanceDue ?? this.balanceDue,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      templateId: templateId ?? this.templateId,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      isEstimate: isEstimate,
      validUntil: validUntil,
      convertedToInvoiceId: convertedToInvoiceId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'clientId': clientId,
        'clientName': clientName,
        'clientEmail': clientEmail,
        'clientAddress': clientAddress,
        'clientPhone': clientPhone,
        'clientCompany': clientCompany,
        'issueDate': issueDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'poNumber': poNumber,
        'items': items.map((e) => e.toMap()).toList(),
        'subtotal': subtotal,
        'discountPercent': discountPercent,
        'discountAmount': discountAmount,
        'taxPercent': taxPercent,
        'taxAmount': taxAmount,
        'total': total,
        'amountPaid': amountPaid,
        'balanceDue': balanceDue,
        'status': status.firestoreValue,
        'paymentMethod': paymentMethod,
        'notes': notes,
        'terms': terms,
        'templateId': templateId,
        'currency': currency,
        'currencySymbol': currencySymbol,
        'signatureUrl': signatureUrl,
        'logoUrl': logoUrl,
        'isEstimate': isEstimate,
        'validUntil': validUntil,
        'convertedToInvoiceId': convertedToInvoiceId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory InvoiceModel.fromMap(Map<String, dynamic> map) => InvoiceModel(
        id: map['id'] ?? '',
        invoiceNumber: map['invoiceNumber'] ?? '',
        clientId: map['clientId'] ?? '',
        clientName: map['clientName'] ?? '',
        clientEmail: map['clientEmail'] ?? '',
        clientAddress: map['clientAddress'] ?? '',
        clientPhone: map['clientPhone'],
        clientCompany: map['clientCompany'],
        issueDate: DateTime.tryParse(map['issueDate'] ?? '') ?? DateTime.now(),
        dueDate: DateTime.tryParse(map['dueDate'] ?? '') ?? DateTime.now(),
        poNumber: map['poNumber'],
        items: (map['items'] as List<dynamic>?)
                ?.map((e) => InvoiceItemModel.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
        subtotal: (map['subtotal'] ?? 0).toDouble(),
        discountPercent: (map['discountPercent'] ?? 0).toDouble(),
        discountAmount: (map['discountAmount'] ?? 0).toDouble(),
        taxPercent: (map['taxPercent'] ?? 0).toDouble(),
        taxAmount: (map['taxAmount'] ?? 0).toDouble(),
        total: (map['total'] ?? 0).toDouble(),
        amountPaid: (map['amountPaid'] ?? 0).toDouble(),
        balanceDue: (map['balanceDue'] ?? 0).toDouble(),
        status: InvoiceStatusExt.fromString(map['status']),
        paymentMethod: map['paymentMethod'],
        notes: map['notes'],
        terms: map['terms'],
        templateId: map['templateId'] ?? 'modern',
        currency: map['currency'] ?? 'USD',
        currencySymbol: map['currencySymbol'] ?? '\$',
        signatureUrl: map['signatureUrl'],
        logoUrl: map['logoUrl'],
        isEstimate: map['isEstimate'] ?? false,
        validUntil: map['validUntil'],
        convertedToInvoiceId: map['convertedToInvoiceId'],
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      );
}
