import 'dart:collection';

import 'package:e_shop/Config/stripe.dart';
import 'package:e_shop/Models/creditCard.dart';
import 'package:flutter/foundation.dart';

class CreditCardData extends ChangeNotifier {
  List<CreditCard> _creditCards = [];
  CreditCard _creditCardSelected;
  bool _isCardsLoading = false;

  UnmodifiableListView<CreditCard> get creditCards {
    return UnmodifiableListView(_creditCards);
  }

  CreditCard get creditCardSelected {
    return _creditCardSelected;
  }

  bool get isCardsLoading {
    return _isCardsLoading;
  }

  Future<CreditCard> getCreditCard({cardId}) async {
    if (cardId == null) {
      return null;
    } else if (_creditCards.indexWhere(
          (element) => element.id == cardId,
        ) >=
        0) {
      return _creditCards.firstWhere(
        (element) => element.id == cardId,
      );
    } else {
      Map mapCard = await getOneCard(cardId: cardId);
      CreditCard creditCard = CreditCard.fromMap(map: mapCard);
      if (creditCard != null) {
        _creditCards.add(creditCard);
      }
      return creditCard;
    }
  }

  void setSelectedCard({CreditCard creditCard}) {
    _creditCardSelected = creditCard;
    notifyListeners();
  }

  void deleteSelectedCard() {
    _creditCardSelected = null;
    notifyListeners();
  }

  bool isSelectedCard({CreditCard creditCard}) {
    if (_creditCardSelected == null) {
      return false;
    } else {
      return _creditCardSelected.id == creditCard.id;
    }
  }

  void addCreditCard({CreditCard creditCard}) {
    if (_creditCards.indexWhere(
          (element) => element.id == creditCard.id,
        ) <
        0) {
      _creditCards.add(creditCard);
    }
    notifyListeners();
  }

  bool showLoadingCards() {
    return _isCardsLoading;
  }

  Future<void> initCreditCards() async {
    _isCardsLoading = true;
    List<dynamic> creditCardData = await getCustomerCards();
    if (creditCardData != null) {
      for (Map mapCard in creditCardData) {
        CreditCard creditCardAdd = CreditCard.fromMap(map: mapCard);
        if (_creditCards.indexWhere(
              (element) => element.id == creditCardAdd.id,
            ) <
            0) {
          _creditCards.add(
            creditCardAdd,
          );
        }
      }
    }
    _isCardsLoading = false;
    notifyListeners();
  }
}
