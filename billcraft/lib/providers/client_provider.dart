import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/client_model.dart';

class ClientProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _sub;
  String? _userId;

  List<ClientModel> _clients = [];
  String _searchQuery = '';

  List<ClientModel> get clients => _filteredClients;
  String get searchQuery => _searchQuery;

  List<ClientModel> get _filteredClients {
    if (_searchQuery.isEmpty) return _clients;
    final q = _searchQuery.toLowerCase();
    return _clients
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            (c.company?.toLowerCase().contains(q) ?? false) ||
            c.email.toLowerCase().contains(q))
        .toList();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void loadForUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _sub?.cancel();
    _sub = null;

    if (userId == null) {
      _clients = [];
      notifyListeners();
      return;
    }

    _sub = _db
        .collection('users')
        .doc(userId)
        .collection('clients')
        .snapshots()
        .listen(
      (snap) {
        _clients = snap.docs
            .map((d) => ClientModel.fromMap(d.data()))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        notifyListeners();
      },
      onError: (_) => notifyListeners(),
    );
  }

  CollectionReference<Map<String, dynamic>>? get _col {
    if (_userId == null) return null;
    return _db.collection('users').doc(_userId).collection('clients');
  }

  ClientModel? getById(String id) {
    try {
      return _clients.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addClient(ClientModel client) async {
    await _col?.doc(client.id).set(client.toMap());
  }

  Future<void> updateClient(ClientModel client) async {
    await _col?.doc(client.id).update(client.toMap());
  }

  Future<void> deleteClient(String id) async {
    await _col?.doc(id).delete();
  }

  List<ClientModel> get topClients {
    final sorted = List<ClientModel>.from(_clients);
    sorted.sort((a, b) => b.totalInvoiced.compareTo(a.totalInvoiced));
    return sorted.take(5).toList();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
