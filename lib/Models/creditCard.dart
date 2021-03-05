class CreditCard {
  final String id;
  final String brand;
  final String country;
  final int expMonth;
  final int expYear;
  final String last4;

  CreditCard({
    this.id,
    this.brand,
    this.country,
    this.expMonth,
    this.expYear,
    this.last4,
  });

  factory CreditCard.fromMap({Map map}) {
    CreditCard creditCard;
    if (map == null) {
      creditCard = null;
    } else {
      creditCard = CreditCard(
        id: map["id"],
        brand: map["card"]["brand"],
        country: map["card"]["country"],
        expMonth: map["card"]["exp_month"],
        expYear: map["card"]["exp_year"],
        last4: map["card"]["last4"],
      );
    }

    return creditCard;
  }
}
