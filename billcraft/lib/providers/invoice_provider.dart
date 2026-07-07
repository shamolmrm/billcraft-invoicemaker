import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/invoice_model.dart';
import '../models/payment_model.dart';

class InvoiceProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _sub;
  String? _userId;

  List<InvoiceModel> _invoices = [];
  List<InvoiceModel> _estimates = [];
  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  InvoiceStatus? _filterStatus;
  String _searchQuery = '';

  List<InvoiceModel> get invoices => _filteredInvoices;
  List<InvoiceModel> get allInvoices => _invoices;
  List<InvoiceModel> get estimates => _estimates;
  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  InvoiceStatus? get filterStatus => _filterStatus;
  String get searchQuery => _searchQuery;

  List<InvoiceModel> get _filteredInvoices {
    List<InvoiceModel> result = _invoices;
    if (_filterStatus != null) {
      result = result.where((i) => i.status == _filterStatus).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((i) =>
              i.clientName.toLowerCase().contains(q) ||
              i.invoiceNumber.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  void setFilter(InvoiceStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  double get totalSales => _invoices.fold(0, (acc, inv) => acc + inv.total);
  double get totalPaid =>
      _invoices.fold(0, (acc, inv) => acc + inv.amountPaid);
  double get totalOutstanding =>
      _invoices.fold(0, (acc, inv) => acc + inv.balanceDue);
  double get totalOverdue => _invoices
      .where((i) => i.status == InvoiceStatus.overdue)
      .fold(0, (acc, inv) => acc + inv.balanceDue);

  List<InvoiceModel> get recentInvoices => _invoices.take(5).toList();
  List<InvoiceModel> get overdueInvoices =>
      _invoices.where((i) => i.status == InvoiceStatus.overdue).toList();
  List<InvoiceModel> get upcomingInvoices => _invoices
      .where((i) =>
          i.status == InvoiceStatus.unpaid &&
          i.daysUntilDue >= 0 &&
          i.daysUntilDue <= 7)
      .toList();

  InvoiceModel? getById(String id) {
    try {
      return _invoices.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  List<InvoiceModel> getByClientId(String clientId) =>
      _invoices.where((i) => i.clientId == clientId).toList();

  List<PaymentModel> getPaymentsForInvoice(String invoiceId) =>
      _payments.where((p) => p.invoiceId == invoiceId).toList();

  // Called by app.dart via ProxyProvider when auth state changes
  void loadForUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _sub?.cancel();
    _sub = null;

    if (userId == null) {
      _invoices = [];
      _estimates = [];
      _payments = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _sub = _db
        .collection('users')
        .doc(userId)
        .collection('invoices')
        .snapshots()
        .listen(
      (snap) {
        final all =
            snap.docs.map((d) => InvoiceModel.fromMap(d.data())).toList();
        _invoices = all.where((i) => !i.isEstimate).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _estimates = all.where((i) => i.isEstimate).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  CollectionReference<Map<String, dynamic>>? get _col {
    if (_userId == null) return null;
    return _db.collection('users').doc(_userId).collection('invoices');
  }

  Future<void> addInvoice(InvoiceModel invoice) async {
    await _col?.doc(invoice.id).set(invoice.toMap());
  }

  Future<void> updateInvoice(InvoiceModel invoice) async {
    await _col?.doc(invoice.id).update(invoice.toMap());
  }

  Future<void> deleteInvoice(String id) async {
    await _col?.doc(id).delete();
  }

  Future<void> recordPayment(PaymentModel payment) async {
    if (_userId == null) return;
    _payments.add(payment);

    final inv = getById(payment.invoiceId);
    if (inv == null) return;

    final newPaid = inv.amountPaid + payment.amount;
    final newBalance = inv.total - newPaid;
    InvoiceStatus newStatus;
    if (newBalance <= 0) {
      newStatus = InvoiceStatus.paid;
    } else if (newPaid > 0) {
      newStatus = InvoiceStatus.partiallyPaid;
    } else {
      newStatus = InvoiceStatus.unpaid;
    }

    final updated = inv.copyWith(
      amountPaid: newPaid,
      balanceDue: newBalance < 0 ? 0 : newBalance,
      status: newStatus,
    );

    await _col?.doc(inv.id).update(updated.toMap());
  }

  Future<void> addEstimate(InvoiceModel estimate) async {
    await _col?.doc(estimate.id).set(estimate.toMap());
  }

  Future<void> updateEstimate(InvoiceModel estimate) async {
    await _col?.doc(estimate.id).update(estimate.toMap());
  }

  Future<void> deleteEstimate(String id) async {
    await _col?.doc(id).delete();
  }

  Future<void> convertEstimateToInvoice(String estimateId) async {
    final col = _col;
    if (col == null) return;

    InvoiceModel? est;
    try {
      est = _estimates.firstWhere((e) => e.id == estimateId);
    } catch (_) {
      return;
    }

    final invoice = InvoiceModel(
      id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
      invoiceNumber: generateNextInvoiceNumber(),
      clientId: est.clientId,
      clientName: est.clientName,
      clientEmail: est.clientEmail,
      clientAddress: est.clientAddress,
      issueDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      items: est.items,
      subtotal: est.subtotal,
      discountPercent: est.discountPercent,
      discountAmount: est.discountAmount,
      taxPercent: est.taxPercent,
      taxAmount: est.taxAmount,
      total: est.total,
      amountPaid: 0,
      balanceDue: est.total,
      status: InvoiceStatus.unpaid,
      templateId: est.templateId,
      currency: est.currency,
      currencySymbol: est.currencySymbol,
      isEstimate: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await Future.wait([
      col.doc(invoice.id).set(invoice.toMap()),
      col.doc(estimateId).delete(),
    ]);
  }

  String generateNextInvoiceNumber() {
    return 'INV${(_invoices.length + 1).toString().padLeft(5, '0')}';
  }

  String generateNextEstimateNumber() {
    return 'EST${(_estimates.length + 1).toString().padLeft(5, '0')}';
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
