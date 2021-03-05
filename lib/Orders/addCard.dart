import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Config/stripe.dart';
import 'package:e_shop/Data/creditCard_data.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/Models/creditCard.dart';
import 'package:e_shop/Orders/placeOrderPayment.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Widgets/myDrawer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:provider/provider.dart';

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
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool showSpinner = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
              ),
              CreditCardWidget(
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
            ],
          ),
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
