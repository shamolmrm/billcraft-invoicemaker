import 'package:flutter/foundation.dart';
import '../models/item_model.dart';
import '../core/constants/dummy_data.dart';

class ItemProvider extends ChangeNotifier {
  List<ItemModel> _items = List.from(dummyItems);
  String _searchQuery = '';
  String? _filterCategory;

  List<ItemModel> get items => _filteredItems;
  String get searchQuery => _searchQuery;
  String? get filterCategory => _filterCategory;

  List<ItemModel> get _filteredItems {
    List<ItemModel> result = _items;
    if (_filterCategory != null) {
      result = result.where((i) => i.category == _filterCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((i) =>
              i.name.toLowerCase().contains(q) ||
              (i.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    return result;
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String? category) {
    _filterCategory = category;
    notifyListeners();
  }

  ItemModel? getById(String id) {
    try {
      return _items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  void addItem(ItemModel item) {
    _items.insert(0, item);
    notifyListeners();
  }

  void updateItem(ItemModel item) {
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      _items[idx] = item;
      notifyListeners();
    }
  }

  void deleteItem(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }
}
