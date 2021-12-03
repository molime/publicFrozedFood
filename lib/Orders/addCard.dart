import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Config/stripe.dart';
import 'package:e_shop/Data/creditCard_data.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/Models/creditCard.dart';
import 'package:e_shop/Orders/placeOrderPayment.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/Widgets/myDrawer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';

class AddCard extends StatefulWidget {
  final bool fromCardPage;

  AddCard({
    this.fromCardPage = false,
  });

  @override
  _AddCardState createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  String cardNumber = '';
  TextEditingController cardNumberController = TextEditingController();
  String expiryDate = '';
  TextEditingController expiryDateController = TextEditingController();
  String cardHolderName = '';
  TextEditingController cardHolderNameController = TextEditingController();
  String cvvCode = '';
  TextEditingController cvvController = TextEditingController();
  bool isCvvFocused = false;
  bool showSpinner = false;
  ScrollController _scrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final formKey = GlobalKey<FormState>();

  OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );

  @override
  void initState() {
    // TODO: implement initState
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        key: scaffoldKey,
        appBar: MyAppBar(
          leadingWidget: IconButton(
              icon: Icon(
                Icons.chevron_left,
              ),
              onPressed: () {
                if (widget.fromCardPage) {
                  Route route = MaterialPageRoute(
                    builder: (context) => PaymentPage(),
                  );
                  Navigator.pushReplacement(
                    context,
                    route,
                  );
                } else {
                  Route route = MaterialPageRoute(
                    builder: (context) => StoreHome(),
                  );
                  Navigator.pushReplacement(
                    context,
                    route,
                  );
                }
              }),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            if (formKey.currentState.validate()) {
              setState(() {
                showSpinner = true;
              });
              Map result = await createPaymentMethod(
                customer: EcommerceApp.sharedPreferences.getString(
                  EcommerceApp.userStripeId,
                ),
                number: cardNumber.trim(),
                expMonth: int.parse(
                  expiryDate.split('/')[0].trim(),
                ),
                expYear: int.parse(
                  '20' + expiryDate.split('/')[1].trim(),
                ),
                cvc: cvvCode.trim(),
              );

              setState(() {
                showSpinner = false;
                cardNumber = '';
                expiryDate = '';
                cvvCode = '';
                cardHolderName = '';
              });

              if (result == null) {
                showDialog(
                  context: context,
                  builder: (c) {
                    return ErrorAlertDialog(
                      message:
                          "Hubo un error registrando esta tarjeta. Por favor vuelva a intentarlo.",
                    );
                  },
                );
              } else {
                Provider.of<CreditCardData>(context, listen: false)
                    .addCreditCard(
                  creditCard: CreditCard.fromMap(
                    map: result,
                  ),
                );
                Fluttertoast.showToast(
                  msg: "Se ha registrado tu tarjeta con éxito.",
                );
                if (!widget.fromCardPage) {
                  Route route = MaterialPageRoute(
                    builder: (context) => StoreHome(),
                  );
                  Navigator.pushReplacement(
                    context,
                    route,
                  );
                } else {
                  Route route = MaterialPageRoute(
                    builder: (context) => PaymentPage(),
                  );
                  Navigator.pushReplacement(
                    context,
                    route,
                  );
                }
              }
            } else {
              showDialog(
                context: context,
                builder: (c) {
                  return ErrorAlertDialog(
                    message: "Tarjeta no válida.",
                  );
                },
              );
            }
          },
          label: Text(
            "Agregar tarjeta",
          ),
          backgroundColor: Colors.pink,
          icon: Icon(
            Icons.credit_card,
          ),
        ),
        drawer: MyDrawer(),
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: SafeArea(
            child: ListView(
              controller: _scrollController,
              shrinkWrap: true,
              children: [
                SizedBox(
                  height: 30,
                ),
                CreditCardWidget(
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  showBackView: isCvvFocused,
                  obscureCardNumber: true,
                  obscureCardCvv: true,
                  isHolderNameVisible: true,
                  cardBgColor: Colors.red,
                  isSwipeGestureEnabled: true,
                  onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {
                    print('credit card change');
                  },
                  /*customCardTypeIcons: <CustomCardTypeIcon>[
                    CustomCardTypeIcon(
                      cardType: CardType.mastercard,
                      cardImage: Image.asset(
                        'assets/mastercard.png',
                        height: 48,
                        width: 48,
                      ),
                    ),
                  ],*/
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            CreditCardForm(
                              formKey: formKey,
                              obscureCvv: true,
                              obscureNumber: true,
                              cardNumber: cardNumber,
                              cvvCode: cvvCode,
                              isHolderNameVisible: true,
                              isCardNumberVisible: true,
                              isExpiryDateVisible: true,
                              cardHolderName: cardHolderName,
                              expiryDate: expiryDate,
                              themeColor: Colors.blue,
                              textColor: Colors.black,
                              onCreditCardModelChange: onCreditCardModelChange,
                              cardNumberDecoration: InputDecoration(
                                labelText: 'Number',
                                hintText: 'XXXX XXXX XXXX XXXX',
                                hintStyle:
                                    const TextStyle(color: Colors.blueGrey),
                                labelStyle:
                                    const TextStyle(color: Colors.blueGrey),
                                focusedBorder: border,
                                enabledBorder: border,
                              ),
                              expiryDateDecoration: InputDecoration(
                                hintStyle:
                                    const TextStyle(color: Colors.blueGrey),
                                labelStyle:
                                    const TextStyle(color: Colors.blueGrey),
                                focusedBorder: border,
                                enabledBorder: border,
                                labelText: 'Expired Date',
                                hintText: 'XX/XX',
                              ),
                              cvvCodeDecoration: InputDecoration(
                                hintStyle:
                                    const TextStyle(color: Colors.blueGrey),
                                labelStyle:
                                    const TextStyle(color: Colors.blueGrey),
                                focusedBorder: border,
                                enabledBorder: border,
                                labelText: 'CVV',
                                hintText: 'XXX',
                              ),
                              cardHolderDecoration: InputDecoration(
                                hintStyle:
                                    const TextStyle(color: Colors.blueGrey),
                                labelStyle:
                                    const TextStyle(color: Colors.blueGrey),
                                focusedBorder: border,
                                enabledBorder: border,
                                labelText: 'Card Holder',
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50.0,
                    ),
                  ],
                ),
                SizedBox(
                  height: 50.0,
                ),
              ],
            ),
          ),
          /*Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
              ),
              CreditCardWidget(
                height: MediaQuery.of(context).size.height * 0.40,
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
                obscureCardNumber: true,
                obscureCardCvv: true,
                labelCardHolder: "Nombre",
              ),
              SizedBox(
                height: 40,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CreditCardForm(
                        cardHolderName: cardHolderName,
                        cardNumber: cardNumber,
                        cvvCode: cvvCode,
                        expiryDate: expiryDate,
                        themeColor: Colors.blue,
                        onCreditCardModelChange: onCreditCardModelChange,
                        formKey: formKey,
                        obscureCvv: true,
                        obscureNumber: true,
                        cardNumberDecoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.credit_card,
                            color: Theme.of(context).primaryColor,
                          ),
                          focusColor: Theme.of(context).primaryColor,
                          hintText: "Número de tarjeta",
                        ),
                        expiryDateDecoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).primaryColor,
                          ),
                          focusColor: Theme.of(context).primaryColor,
                          hintText: "Expiración",
                        ),
                        cvvCodeDecoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.security,
                            color: Theme.of(context).primaryColor,
                          ),
                          focusColor: Theme.of(context).primaryColor,
                          hintText: "CVV",
                        ),
                        cardHolderDecoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.drive_file_rename_outline,
                            color: Theme.of(context).primaryColor,
                          ),
                          focusColor: Theme.of(context).primaryColor,
                          hintText: "Nombre en la tarjeta",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 100,
              ),
            ],
          ),*/
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    print({
      'areEqual': cardHolderName == creditCardModel.cardHolderName,
      'cardHolderName': cardHolderName,
      'creditCardModel.cardHolderName': creditCardModel.cardHolderName
    });
    if (cardHolderName != creditCardModel.cardHolderName) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
