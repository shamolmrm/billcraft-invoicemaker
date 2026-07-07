class AppConstants {
  static const String appName = 'BillCraft';
  static const String appTagline = 'Invoice Smarter. Get Paid Faster.';
  static const String appVersion = '1.0.0';

  static const String defaultCurrency = 'USD';
  static const String defaultCurrencySymbol = '\$';
  static const String defaultInvoicePrefix = 'INV';
  static const String defaultEstimatePrefix = 'EST';
  static const int defaultStartingNumber = 1;
  static const int defaultPaymentTerms = 30;

  static const List<String> unitOptions = [
    'pcs', 'hrs', 'days', 'kg', 'lb', 'project', 'service',
    'month', 'year', 'sq ft', 'meter', 'liter', 'box', 'set',
  ];

  static const List<String> categoryOptions = [
    'Electronics', 'Software', 'Services', 'Consulting',
    'Design', 'Development', 'Marketing', 'Legal',
    'Accounting', 'Other',
  ];

  static const List<String> paymentMethods = [
    'Bank Transfer', 'PayPal', 'Cash', 'Credit Card',
    'Cheque', 'Crypto', 'Other',
  ];

  static const List<String> templateIds = [
    'classic', 'modern', 'bold_dark', 'marble', 'minimalist',
    'corporate', 'colorful', 'nature', 'royal', 'sunset',
    'ocean', 'tech_dark', 'pastel', 'gold', 'watercolor',
  ];

  static const List<String> templateNames = [
    'Classic White', 'Modern Teal', 'Bold Dark', 'Marble', 'Minimalist',
    'Corporate Blue', 'Colorful', 'Green Nature', 'Royal Purple', 'Sunset Orange',
    'Ocean Blue', 'Tech Dark', 'Pastel Pink', 'Gold Premium', 'Watercolor Blue',
  ];
}
