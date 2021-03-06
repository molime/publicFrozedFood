import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:shared_preferences/shared_preferences.dart';

GoogleSignIn googleSignInLocal = GoogleSignIn(
    /*scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],*/
    );

class EcommerceApp {
  static const String appName = 'e-Shop';

  static SharedPreferences sharedPreferences;
  static User user;
  static FirebaseAuth auth;
  static FirebaseFirestore firestore;

  static String collectionUser = "users";
  static String collectionAdmin = "admins";
  static String collectionOrders = "orders";
  static String userCartList = 'userCart';
  static String subCollectionAddress = 'userAddress';
  static String subCollectionPaymentMethods = 'userPaymentMethods';
  static String collectionCategories = 'categories';
  static String collectionFeriados = 'feriados';

  static final String userName = 'name';
  static final String userEmail = 'email';
  static final String userPhotoUrl = 'photoUrl';
  static final String userUID = 'uid';
  static final String userAvatarUrl = 'url';
  static final String userStripeId = 'stripeId';

  static final String addressID = 'addressID';
  static final String totalAmount = 'totalAmount';
  static final String productID = 'productIDs';
  static final String paymentDetails = 'paymentDetails';
  static final String orderTime = 'orderTime';
  static final String isSuccess = 'isSuccess';
  static final String notificationsToken = 'notificationsToken';
}
