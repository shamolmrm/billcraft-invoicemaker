class BusinessModel {
  final String name;
  final String? logoUrl;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String? taxNumber;
  final String? bankDetails;
  final double defaultTaxRate;
  final int defaultPaymentTerms;
  final String currency;
  final String currencySymbol;
  final String invoicePrefix;
  final String estimatePrefix;
  final int invoiceStartNumber;
  final String? defaultNotes;
  final String? defaultTerms;
  final String? signatureUrl;

  const BusinessModel({
    this.name = 'Your Business',
    this.logoUrl,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.taxNumber,
    this.bankDetails,
    this.defaultTaxRate = 0,
    this.defaultPaymentTerms = 30,
    this.currency = 'USD',
    this.currencySymbol = '\$',
    this.invoicePrefix = 'INV',
    this.estimatePrefix = 'EST',
    this.invoiceStartNumber = 1,
    this.defaultNotes,
    this.defaultTerms,
    this.signatureUrl,
  });

  BusinessModel copyWith({
    String? name,
    String? logoUrl,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? taxNumber,
    String? bankDetails,
    double? defaultTaxRate,
    int? defaultPaymentTerms,
    String? currency,
    String? currencySymbol,
    String? invoicePrefix,
    String? estimatePrefix,
    int? invoiceStartNumber,
    String? defaultNotes,
    String? defaultTerms,
    String? signatureUrl,
  }) {
    return BusinessModel(
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      taxNumber: taxNumber ?? this.taxNumber,
      bankDetails: bankDetails ?? this.bankDetails,
      defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
      defaultPaymentTerms: defaultPaymentTerms ?? this.defaultPaymentTerms,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      estimatePrefix: estimatePrefix ?? this.estimatePrefix,
      invoiceStartNumber: invoiceStartNumber ?? this.invoiceStartNumber,
      defaultNotes: defaultNotes ?? this.defaultNotes,
      defaultTerms: defaultTerms ?? this.defaultTerms,
      signatureUrl: signatureUrl ?? this.signatureUrl,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'logoUrl': logoUrl,
        'address': address,
        'phone': phone,
        'email': email,
        'website': website,
        'taxNumber': taxNumber,
        'bankDetails': bankDetails,
        'defaultTaxRate': defaultTaxRate,
        'defaultPaymentTerms': defaultPaymentTerms,
        'currency': currency,
        'currencySymbol': currencySymbol,
        'invoicePrefix': invoicePrefix,
        'estimatePrefix': estimatePrefix,
        'invoiceStartNumber': invoiceStartNumber,
        'defaultNotes': defaultNotes,
        'defaultTerms': defaultTerms,
        'signatureUrl': signatureUrl,
      };

  factory BusinessModel.fromMap(Map<String, dynamic> map) => BusinessModel(
        name: map['name'] ?? 'Your Business',
        logoUrl: map['logoUrl'],
        address: map['address'],
        phone: map['phone'],
        email: map['email'],
        website: map['website'],
        taxNumber: map['taxNumber'],
        bankDetails: map['bankDetails'],
        defaultTaxRate: (map['defaultTaxRate'] ?? 0).toDouble(),
        defaultPaymentTerms: (map['defaultPaymentTerms'] ?? 30),
        currency: map['currency'] ?? 'USD',
        currencySymbol: map['currencySymbol'] ?? '\$',
        invoicePrefix: map['invoicePrefix'] ?? 'INV',
        estimatePrefix: map['estimatePrefix'] ?? 'EST',
        invoiceStartNumber: map['invoiceStartNumber'] ?? 1,
        defaultNotes: map['defaultNotes'],
        defaultTerms: map['defaultTerms'],
        signatureUrl: map['signatureUrl'],
      );
}
