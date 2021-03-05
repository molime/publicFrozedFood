import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class AddressModel {
  String uid;
  String addressLine;
  String postalCode;
  String countryName;
  String countryCode;
  String adminArea;
  String locality;
  String featureName;
  String subAdminArea;
  String subLocality;
  String thoroughfare;
  String subThroughFare;
  Map position;
  GeoFirePoint positionFirePoint;
  String reference;

  AddressModel({
    this.uid,
    this.thoroughfare,
    this.subLocality,
    this.subAdminArea,
    this.featureName,
    this.locality,
    this.adminArea,
    this.countryCode,
    this.countryName,
    this.addressLine,
    this.position,
    this.postalCode,
    this.subThroughFare,
    this.positionFirePoint,
    this.reference,
  });

  AddressModel.fromJson(
    Map<String, dynamic> json, {
    String uidReceived,
  }) {
    print({
      'addressModel.uid': uidReceived,
    });
    GeoPoint geoPoint = json['position']['geopoint'];
    uid = uidReceived;
    addressLine = json['addressLine'];
    postalCode = json['postalCode'];
    countryName = json['countryName'];
    countryCode = json['countryCode'];
    adminArea = json['adminArea'];
    locality = json['locality'];
    featureName = json['featureName'];
    subAdminArea = json['subAdminArea'];
    subLocality = json['subLocality'];
    thoroughfare = json['thoroughfare'];
    subThroughFare = json['subThroughFare'];
    position = {
      'geohash': json['position']['geohash'],
      'geopoint': json['position']['geopoint'],
    };
    positionFirePoint = GeoFirePoint(geoPoint.latitude, geoPoint.longitude);
    reference = json['reference'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['addressLine'] = this.addressLine;
    data['postalCode'] = this.postalCode;
    data['countryName'] = this.countryName;
    data['countryCode'] = this.countryCode;
    data['adminArea'] = this.adminArea;
    data['locality'] = this.locality;
    data['featureName'] = this.featureName;
    data['subAdminArea'] = this.subAdminArea;
    data['subLocality'] = this.subLocality;
    data['thoroughfare'] = this.subThroughFare;
    data['subThroughFare'] = this.subThroughFare;
    data['position'] = this.position;
    data['reference'] = this.reference;
    return data;
  }
}
