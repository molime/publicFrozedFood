import 'dart:collection';

import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Models/category.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final categoriesRef = EcommerceApp.firestore.collection(
  EcommerceApp.collectionCategories,
);

class CategoryData extends ChangeNotifier {
  List<CategoryElement> _categories = [];
  CategoryElement _categorySelected;
  int _indexSelected;
  bool _isCategoriesLoading = false;

  int get indexSelected {
    return _categories
        .indexWhere((element) => element.uid == _categorySelected.uid);
  }

  UnmodifiableListView<CategoryElement> get categories {
    return UnmodifiableListView(_categories);
  }

  CategoryElement get categorySelected {
    return _categorySelected;
  }

  int get categoryCount {
    return _categories.length;
  }

  bool get isCategoriesLoading {
    return _isCategoriesLoading;
  }

  bool showLoadingCategories() {
    return _isCategoriesLoading;
  }

  void setCategory({CategoryElement categoryElement}) {
    if (_categories
            .indexWhere((element) => element.uid == categoryElement.uid) <
        0) {
      _categories.add(categoryElement);
      _categorySelected = _categories
          .firstWhere((element) => element.uid == categoryElement.uid);
      _indexSelected = _categories
          .indexWhere((element) => element.uid == categoryElement.uid);
      notifyListeners();
    } else {
      _categorySelected = _categories
          .firstWhere((element) => element.uid == categoryElement.uid);
      _indexSelected = _categories
          .indexWhere((element) => element.uid == categoryElement.uid);
      notifyListeners();
    }
  }

  Future<void> initCategories() async {
    _isCategoriesLoading = true;
    QuerySnapshot querySnapshot = await categoriesRef.get();

    for (DocumentSnapshot doc in querySnapshot.docs) {
      if (_categories.indexWhere((element) => element.uid == doc.id) < 0) {
        _categories.add(
          CategoryElement.fromDocument(
            doc: doc,
          ),
        );
      }
    }
    _isCategoriesLoading = false;
    notifyListeners();
  }
}
