import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Models/address.dart';
import 'package:e_shop/Models/item.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

class ShoppingCart extends ChangeNotifier {
  List<ItemModel> _itemsCart = [];
  List<ItemModel> _dailyItems = [];
  AddressModel _selectedAddress;
  bool _addressSpinner = false;

  UnmodifiableListView<ItemModel> get itemsCart {
    return UnmodifiableListView(_itemsCart);
  }

  UnmodifiableListView<ItemModel> get dailyItems {
    return UnmodifiableListView(_dailyItems);
  }

  AddressModel get selectedAddress {
    return _selectedAddress;
  }

  bool get addressSpinner {
    return _addressSpinner;
  }

  void setSpinner(bool spinner) {
    _addressSpinner = spinner;
    notifyListeners();
  }

  void setSelectedAddress({AddressModel selectedAddress}) {
    _selectedAddress = selectedAddress;
    notifyListeners();
  }

  void deleteSelectedAddress() {
    _selectedAddress = null;
    notifyListeners();
  }

  void addToDaily({
    ItemModel itemModelAdd,
    List<Map> optionsDailyAdd,
    List<Map> sopasAdd,
    List<Map> entremesesAdd,
    List<Map> postresAdd,
    @required int count,
  }) {
    ItemModel itemModelCheck = ItemModel.fromItem(
      itemModelReplicate: itemModelAdd,
      optionsAdd: [],
      count: count,
      sopasAdd: sopasAdd,
      entremesAdd: entremesesAdd,
      postreAdd: postresAdd,
      optionsDailyAdd: optionsDailyAdd,
    );
    if (isInDaily(itemModelCheck: itemModelCheck)) {
      _dailyItems
          .firstWhere(
            (element) =>
                element.uid == itemModelCheck.uid &&
                dailySameOptions(
                  itemModelCheck: itemModelCheck,
                  itemModelCompare: element,
                ),
          )
          .addToCount(
            count: count,
          );
    } else {
      _dailyItems.add(
        itemModelCheck,
      );
    }
    notifyListeners();
  }

  void addToCart(
      {ItemModel itemModelAdd, List<Map> optionsAdd, @required int count}) {
    ItemModel itemModelCheck = ItemModel.fromItem(
      itemModelReplicate: itemModelAdd,
      optionsAdd: optionsAdd,
      count: count,
      optionsDailyAdd: [],
      sopasAdd: [],
      entremesAdd: [],
      postreAdd: [],
    );
    if (isInCart(itemModelCheck: itemModelCheck)) {
      _itemsCart
          .firstWhere(
            (element) =>
                element.uid == itemModelCheck.uid &&
                haveSameOptions(
                    optionsCompare: element.options,
                    optionsCheck: itemModelCheck.options),
          )
          .addToCount(count: count);
    } else {
      _itemsCart.add(
        itemModelCheck,
      );
    }
    notifyListeners();
  }

  void increaseQuantity({ItemModel itemModelQuant}) {
    if (isInCart(itemModelCheck: itemModelQuant)) {
      _itemsCart
          .firstWhere(
            (itemModel) =>
                itemModel.uid == itemModelQuant.uid &&
                haveSameOptions(
                  optionsCheck: itemModel.options,
                  optionsCompare: itemModelQuant.options,
                ),
          )
          .addCount();
    }
    notifyListeners();
  }

  void increaseDailyQuantity({ItemModel itemModel}) {
    if (isInDaily(itemModelCheck: itemModel)) {
      _dailyItems
          .firstWhere(
            (element) =>
                element.uid == itemModel.uid &&
                dailySameOptions(
                  itemModelCheck: itemModel,
                  itemModelCompare: element,
                ),
          )
          .addCount();
    }
    notifyListeners();
  }

  void decreaseQuant({ItemModel itemModelDecrease}) {
    if (isInCart(itemModelCheck: itemModelDecrease)) {
      if (itemModelDecrease.countAdded > 1) {
        _itemsCart
            .firstWhere(
              (element) =>
                  element.uid == itemModelDecrease.uid &&
                  haveSameOptions(
                    optionsCheck: element.options,
                    optionsCompare: itemModelDecrease.options,
                  ),
            )
            .decreaseCount();
      } else {
        _itemsCart.removeWhere(
          (element) =>
              element.uid == itemModelDecrease.uid &&
              haveSameOptions(
                optionsCompare: element.options,
                optionsCheck: itemModelDecrease.options,
              ),
        );
      }
    }
    notifyListeners();
  }

  void decreaseDailyQuant({ItemModel itemModelDecrease}) {
    if (isInDaily(itemModelCheck: itemModelDecrease)) {
      if (itemModelDecrease.countAdded > 1) {
        _dailyItems
            .firstWhere(
              (element) =>
                  element.uid == itemModelDecrease.uid &&
                  dailySameOptions(
                    itemModelCheck: itemModelDecrease,
                    itemModelCompare: element,
                  ),
            )
            .decreaseCount();
      } else {
        _dailyItems.removeWhere(
          (element) =>
              element.uid == itemModelDecrease.uid &&
              dailySameOptions(
                itemModelCheck: itemModelDecrease,
                itemModelCompare: element,
              ),
        );
      }
    }
    notifyListeners();
  }

  void removeFromCart({ItemModel itemModelRemove}) {
    if (isInCart(itemModelCheck: itemModelRemove)) {
      _itemsCart.removeWhere(
        (element) =>
            element.uid == itemModelRemove.uid &&
            haveSameOptions(
              optionsCompare: element.options,
              optionsCheck: itemModelRemove.options,
            ),
      );
    }
    notifyListeners();
  }

  void removeFromDaily({ItemModel itemModelRemove}) {
    if (isInDaily(itemModelCheck: itemModelRemove)) {
      _dailyItems.removeWhere(
        (element) =>
            element.uid == itemModelRemove.uid &&
            dailySameOptions(
              itemModelCheck: itemModelRemove,
              itemModelCompare: element,
            ),
      );
    }
    notifyListeners();
  }

  void emptyCart() {
    _itemsCart = [];
    notifyListeners();
  }

  void emptyDaily() {
    _dailyItems = [];
    notifyListeners();
  }

  bool isInCart({ItemModel itemModelCheck}) {
    if (itemModelCheck != null) {
      int indexFound = _itemsCart.indexWhere(
        (element) =>
            element.uid == itemModelCheck.uid &&
            haveSameOptions(
              optionsCheck: element.options,
              optionsCompare: itemModelCheck.options,
            ),
      );
      return indexFound >= 0;
    } else {
      return false;
    }
  }

  bool isInDaily({ItemModel itemModelCheck}) {
    if (itemModelCheck != null) {
      int indexFound = _dailyItems.indexWhere(
        (element) =>
            element.uid == itemModelCheck.uid &&
            dailySameOptions(
              itemModelCheck: itemModelCheck,
              itemModelCompare: element,
            ),
      );
      return indexFound >= 0;
    } else {
      return false;
    }
  }

  bool haveSameOptions({List<Map> optionsCheck, List<Map> optionsCompare}) {
    if (optionsCheck != null && optionsCompare != null) {
      List<int> optionsCheckNumbers = [];
      List<int> optionsCompareNumbers = [];

      for (Map check in optionsCheck) {
        optionsCheckNumbers.add(check['optionNumber']);
      }

      for (Map compare in optionsCompare) {
        optionsCompareNumbers.add(compare['optionNumber']);
      }
      Function unOrdDeepEq = const DeepCollectionEquality.unordered().equals;

      return unOrdDeepEq(
        optionsCheck,
        optionsCompare,
      );
    } else if (optionsCheck == null && optionsCompare == null) {
      return true;
    } else {
      return false;
    }
  }

  bool dailySameOptions({
    ItemModel itemModelCheck,
    ItemModel itemModelCompare,
  }) {
    if (itemModelCheck.postres != null &&
        itemModelCompare.postres != null &&
        itemModelCheck.entremeses != null &&
        itemModelCompare.entremeses != null &&
        itemModelCheck.sopas != null &&
        itemModelCompare.sopas != null &&
        itemModelCheck.optionsDaily != null &&
        itemModelCompare.optionsDaily != null) {
      List<int> optionsCheck = [];
      List<int> optionsCompare = [];

      List<int> sopasCheck = [];
      List<int> sopasCompare = [];

      List<int> entremesCheck = [];
      List<int> entremesCompare = [];

      List<int> postreCheck = [];
      List<int> postreCompare = [];

      List<bool> comparisonResults = [];

      for (Map oCheck in itemModelCheck.optionsDaily) {
        optionsCheck.add(oCheck['optionNumber']);
      }

      for (Map oCompare in itemModelCompare.optionsDaily) {
        optionsCompare.add(oCompare['optionNumber']);
      }

      for (Map sCheck in itemModelCheck.sopas) {
        sopasCheck.add(sCheck['optionNumber']);
      }

      for (Map sCompare in itemModelCompare.sopas) {
        sopasCompare.add(sCompare['optionNumber']);
      }

      for (Map eCheck in itemModelCheck.entremeses) {
        entremesCheck.add(eCheck['optionNumber']);
      }

      for (Map eCompare in itemModelCompare.entremeses) {
        entremesCompare.add(eCompare['optionNumber']);
      }

      for (Map pCheck in itemModelCheck.postres) {
        postreCheck.add(pCheck['optionNumber']);
      }

      for (Map pCompare in itemModelCompare.postres) {
        postreCompare.add(pCompare['optionNumber']);
      }

      Function unOrdDeepEq = const DeepCollectionEquality.unordered().equals;

      comparisonResults.add(
        unOrdDeepEq(
          optionsCheck,
          optionsCompare,
        ),
      );

      comparisonResults.add(
        unOrdDeepEq(
          sopasCheck,
          sopasCompare,
        ),
      );

      comparisonResults.add(
        unOrdDeepEq(
          entremesCheck,
          entremesCompare,
        ),
      );

      comparisonResults.add(
        unOrdDeepEq(
          postreCheck,
          postreCompare,
        ),
      );

      return !comparisonResults.contains(
        false,
      );
    } else {
      return false;
    }
  }

  int shoppingCartCount() {
    int count = 0;
    if (_itemsCart.length > 0) {
      for (ItemModel itemModel in _itemsCart) {
        count += itemModel.countAdded;
      }
    }
    if (_dailyItems.length > 0) {
      for (ItemModel itemModel in _dailyItems) {
        count += itemModel.countAdded;
      }
    }
    return count;
  }

  ItemModel getItemModel({ItemModel itemModelCheck}) {
    if (!isInCart(itemModelCheck: itemModelCheck)) {
      return null;
    } else {
      return _itemsCart.firstWhere(
        (element) =>
            element.uid == itemModelCheck.uid &&
            haveSameOptions(
              optionsCompare: element.options,
              optionsCheck: itemModelCheck.options,
            ),
      );
    }
  }

  ItemModel getDailyModel({ItemModel itemModel}) {
    if (!isInDaily(itemModelCheck: itemModel)) {
      return null;
    } else {
      return _dailyItems.firstWhere(
        (element) =>
            element.uid == itemModel.uid &&
            dailySameOptions(
              itemModelCheck: itemModel,
              itemModelCompare: element,
            ),
      );
    }
  }

  double getTotalAmount() {
    double totalAmount = 0;
    if (_itemsCart.length > 0) {
      for (ItemModel itemModel in _itemsCart) {
        double realPrice = discountedPrice(
          price: itemModel.price,
          discount: itemModel.discount,
        );
        for (Map option in itemModel.options) {
          realPrice += option["price"];
        }
        double totalPrice = realPrice * itemModel.countAdded;
        totalAmount += totalPrice;
      }
    }
    if (_dailyItems.length > 0) {
      for (ItemModel itemModel in _dailyItems) {
        double realPrice = discountedPrice(
          price: itemModel.price,
          discount: itemModel.discount,
        );
        for (Map option in itemModel.optionsDaily) {
          realPrice += option["price"];
        }
        double totalPrice = realPrice * itemModel.countAdded;
        totalAmount += totalPrice;
      }
    }
    return totalAmount;
  }

  double getItemsTotalAmount() {
    double totalAmount = 0;
    if (_itemsCart.length > 0) {
      for (ItemModel itemModel in _itemsCart) {
        double realPrice = discountedPrice(
          price: itemModel.price,
          discount: itemModel.discount,
        );
        for (Map option in itemModel.options) {
          realPrice += option["price"];
        }
        double totalPrice = realPrice * itemModel.countAdded;
        totalAmount += totalPrice;
      }
    }
    return totalAmount;
  }

  double getDailyTotalAmount() {
    double totalAmount = 0;
    if (_dailyItems.length > 0) {
      for (ItemModel itemModel in _dailyItems) {
        double realPrice = discountedPrice(
          price: itemModel.price,
          discount: itemModel.discount,
        );
        for (Map option in itemModel.optionsDaily) {
          realPrice += option["price"];
        }
        double totalPrice = realPrice * itemModel.countAdded;
        totalAmount += totalPrice;
      }
    }
    return totalAmount;
  }

  double getItemTotal({ItemModel itemModel}) {
    if (isInCart(
      itemModelCheck: itemModel,
    )) {
      return _itemsCart
          .firstWhere(
            (element) =>
                element.uid == itemModel.uid &&
                haveSameOptions(
                  optionsCheck: itemModel.options,
                  optionsCompare: element.options,
                ),
          )
          .getItemTotal();
    } else {
      return 0.0;
    }
  }

  double getItemDailyTotal({ItemModel itemModel}) {
    if (isInDaily(itemModelCheck: itemModel)) {
      return _dailyItems
          .firstWhere(
            (element) =>
                element.uid == itemModel.uid &&
                dailySameOptions(
                  itemModelCheck: itemModel,
                  itemModelCompare: element,
                ),
          )
          .getItemDailyTotal();
    } else {
      return 0.0;
    }
  }

  List<String> getProductUids() {
    List<String> productUids = [];
    if (_itemsCart.length > 0) {
      for (ItemModel itemModel in _itemsCart) {
        productUids.add(itemModel.uid);
      }
    }
    return productUids;
  }

  List<String> getDailyUids() {
    List<String> productUids = [];
    if (_dailyItems.length > 0) {
      for (ItemModel itemModel in _dailyItems) {
        productUids.add(
          itemModel.uid,
        );
      }
    }
    return productUids;
  }

  List<Map> itemsCartToJson() {
    List<Map> itemsCartJson = [];
    if (_itemsCart.length > 0) {
      for (ItemModel itemModel in _itemsCart) {
        itemsCartJson.add(
          itemModel.toJson(),
        );
      }
    }
    return itemsCartJson;
  }

  List<Map> itemsDailyToJson() {
    List<Map> itemsDailyJson = [];
    if (_dailyItems.length > 0) {
      for (ItemModel itemModel in _dailyItems) {
        itemsDailyJson.add(
          itemModel.toJson(),
        );
      }
    }
    return itemsDailyJson;
  }

  bool allDailyItemsBelongToday({DateTime today}) {
    if (_dailyItems.length > 0) {
      List<bool> checkResults = [];
      for (ItemModel itemModel in _dailyItems) {
        checkResults.add(
          itemModel.isSameDate(
            dateTime: today,
          ),
        );
      }
      return !checkResults.contains(false);
    } else {
      return false;
    }
  }

  Future<bool> dailyStillAvailable({
    @required DateTime dateTime,
  }) async {
    List<bool> resultsCheck = [];
    QuerySnapshot query = await EcommerceApp.firestore
        .collection("dailyMenus")
        .where(
          "dayAvailable",
          isEqualTo: DateTime(
            dateTime.year,
            dateTime.month,
            dateTime.day,
          ),
        )
        .get();
    for (ItemModel itemModel in _dailyItems) {
      DocumentSnapshot doc = query.docs.firstWhere(
        (element) => element.id == itemModel.uid,
        orElse: () => null,
      );
      if (doc == null) {
        resultsCheck.add(
          false,
        );
      } else {
        print({
          'disponibilidad': (doc.data() as Map)['disponibilidad'],
        });
        int remaining = (doc.data() as Map)['disponibilidad'] != null
            ? (doc.data() as Map)['disponibilidad']
            : null;
        if (remaining == null) {
          resultsCheck.add(false);
        } else {
          print({
            'remaining': remaining,
            'countAdded': itemModel.countAdded,
          });
          bool isStillAvailable = remaining >= itemModel.countAdded;
          resultsCheck.add(
            isStillAvailable,
          );
        }
      }
    }
    print({
      'resultsCheck': resultsCheck,
      "responseReturn": !resultsCheck.contains(
        false,
      ),
    });
    return !resultsCheck.contains(
      false,
    );
  }

  Future<void> updateDisponibilidades() async {
    print("updating disponibilidades");
    if (_dailyItems.length > 0) {
      for (ItemModel itemModel in _dailyItems) {
        await itemModel.updateDisponibilidad();
      }
    }
    notifyListeners();
  }
}
