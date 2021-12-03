import 'dart:math';

import 'package:e_shop/Address/address.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Config/mapsApi.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Widgets/myDrawer.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_geocoding/google_geocoding.dart' as googleCoding;
import 'package:google_place/google_place.dart' as googlePlace;

final geo = Geoflutterfire();

class AddAddress extends StatefulWidget {
  final bool isFromAddresses;

  AddAddress({
    this.isFromAddresses = false,
  });

  @override
  _AddAddressState createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  LatLng _initialPositon = LatLng(
    19.4326018,
    -99.1332049,
  );

  GoogleMapController _googleMapControllerontroller;

  final formKey = GlobalKey<FormState>();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final cName = TextEditingController();

  final cReference = TextEditingController();

  googleCoding.GoogleGeocoding ggcoding = googleCoding.GoogleGeocoding(
    LocalMapsApi().googleApiKey,
  );
  googlePlace.GooglePlace gPlace;

  //List<geocoder.Address> addresses = [];

  List<Map> locations = [];
  List<googleCoding.GeocodingResult> googleLocations = [];

  bool searching = false;

  bool showSpinner = false;

  //geocoder.Address addressSelected;

  Map locationSelected;
  Placemark locationSelectedAddress;

  googleCoding.GeocodingResult googleLocationSelected;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }
    Position position = await Geolocator.getCurrentPosition();
    _initialPositon = LatLng(position.latitude, position.longitude);
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
    gPlace = googlePlace.GooglePlace(LocalMapsApi().googleApiKey);
  }

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
              if (widget.isFromAddresses) {
                Route route = MaterialPageRoute(
                  builder: (context) => AddressScreen(),
                );
                Navigator.pushReplacement(context, route);
              } else {
                Route route = MaterialPageRoute(
                  builder: (context) => StoreHome(),
                );
                Navigator.pushReplacement(context, route);
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            if (googleLocationSelected == null) {
              showDialog(
                context: context,
                builder: (c) {
                  return ErrorAlertDialog(
                    message: "Por favor selecciona una dirección.",
                  );
                },
              );
            } else {
              setState(() {
                showSpinner = true;
              });
              GeoFirePoint myLocation = geo.point(
                latitude: googleLocationSelected.geometry.location.lat,
                longitude: googleLocationSelected.geometry.location.lng,
              );
              List<Placemark> placeMark = await placemarkFromCoordinates(
                  googleLocationSelected.geometry.location.lat,
                  googleLocationSelected.geometry.location.lng);
              Placemark placemarkFire = placeMark.first;
              await EcommerceApp.firestore
                  .collection(EcommerceApp.collectionUser)
                  .doc(
                    EcommerceApp.sharedPreferences.getString(
                      EcommerceApp.userUID,
                    ),
                  )
                  .collection(EcommerceApp.subCollectionAddress)
                  .add({
                //'addressLine': locationSelected['placemark'].addressLine,
                'addressLine': googleLocationSelected.formattedAddress,
                'postalCode': placemarkFire.postalCode,
                'countryName': placemarkFire.country,
                'countryCode': placemarkFire.isoCountryCode,
                'adminArea': placemarkFire.administrativeArea,
                'locality': placemarkFire.locality,
                'featureName': googleLocationSelected.formattedAddress,
                'subAdminArea': placemarkFire.subAdministrativeArea,
                'subLocality': placemarkFire.subLocality,
                'thoroughfare': placemarkFire.thoroughfare,
                'subThroughFare': placemarkFire.subThoroughfare,
                'reference': cReference.text.trim(),
                'position': myLocation.data
              });
              _googleMapControllerontroller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(
                      19.4326018,
                      -99.1332049,
                    ),
                    zoom: 15.0,
                  ),
                ),
              );
              setState(() {
                searching = false;
                showSpinner = false;
                googleLocations = [];
                markers = {};
                googleLocationSelected = null;
                _initialPositon = LatLng(
                  19.4326018,
                  -99.1332049,
                );
                cName.clear();
                cReference.clear();
              });
              SnackBar snackBar = SnackBar(
                content: Text(
                  "La nueva dirección se ha agregado con éxito.",
                ),
              );
              FocusScope.of(context).requestFocus(
                FocusNode(),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                snackBar,
              );
              if (!widget.isFromAddresses) {
                Route route = MaterialPageRoute(
                  builder: (context) => StoreHome(),
                );
                Navigator.pushReplacement(context, route);
              } else {
                Route route = MaterialPageRoute(
                  builder: (context) => AddressScreen(),
                );
                Navigator.pushReplacement(context, route);
              }
            }
          },
          label: Text(
            "Listo",
          ),
          backgroundColor: Colors.pink,
          icon: Icon(
            Icons.check,
          ),
        ),
        drawer: MyDrawer(),
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Stack(
            children: <Widget>[
              GoogleMap(
                onMapCreated: onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _initialPositon != null
                      ? _initialPositon
                      : LatLng(
                          19.4326018,
                          -99.1332049,
                        ),
                  zoom: 14.5,
                ),
                markers: Set<Marker>.of(markers.values),
              ),
              Positioned(
                top: 30.0,
                right: 15.0,
                left: 15.0,
                child: Column(
                  children: [
                    /*if (locationSelected == null) ...[
                      Container(
                        height: 50.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white),
                        child: TextField(
                          controller: cName,
                          decoration: InputDecoration(
                            hintText: 'Escribir dirección',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.only(left: 15.0, top: 15.0),
                            suffixIcon: Icon(
                              Icons.search,
                              size: 30.0,
                            ),
                          ),
                          onChanged: (value) async {
                            List<Map> addLook = await searchandNavigate(
                              searchValue: value,
                            );
                            setState(() {
                              searching = true;
                              locations = addLook;
                            });
                          },
                        ),
                      ),
                    ],*/
                    if (googleLocationSelected == null) ...[
                      Container(
                        height: 50.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white),
                        child: TextField(
                          controller: cName,
                          decoration: InputDecoration(
                            hintText: 'Escribir dirección',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.only(left: 15.0, top: 15.0),
                            suffixIcon: Icon(
                              Icons.search,
                              size: 30.0,
                            ),
                          ),
                          onChanged: (value) async {
                            List<googleCoding.GeocodingResult> addLook =
                                await searchGoogleAddress(
                              searchValue: value,
                            );
                            setState(() {
                              searching = true;
                              googleLocations = addLook;
                            });
                          },
                        ),
                      ),
                    ],
                    /*if (locations.length == 0 &&
                        !searching &&
                        locationSelected != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 5.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                20,
                              ),
                            ),
                          ),
                          child: ListTile(
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_forever,
                              ),
                              onPressed: () {
                                _googleMapControllerontroller.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng(
                                        19.4326018,
                                        -99.1332049,
                                      ),
                                      zoom: 15.0,
                                    ),
                                  ),
                                );
                                setState(
                                  () {
                                    _initialPositon = LatLng(
                                      19.4326018,
                                      -99.1332049,
                                    );
                                    markers = {};
                                    locationSelected = null;
                                  },
                                );
                              },
                            ),
                            tileColor: Colors.pink,
                            leading: Icon(
                              Icons.location_on,
                            ),
                            title: Text(locationSelected['placemark'].street),
                            onTap: () {
                              print("you Clicked me!!!");
                            },
                          ),
                        ),
                      ),
                    ],*/
                    if (googleLocations.length == 0 &&
                        !searching &&
                        googleLocationSelected != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 5.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                20,
                              ),
                            ),
                          ),
                          child: ListTile(
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_forever,
                              ),
                              onPressed: () {
                                _googleMapControllerontroller.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng(
                                        19.4326018,
                                        -99.1332049,
                                      ),
                                      zoom: 15.0,
                                    ),
                                  ),
                                );
                                setState(
                                  () {
                                    _initialPositon = LatLng(
                                      19.4326018,
                                      -99.1332049,
                                    );
                                    markers = {};
                                    googleLocationSelected = null;
                                  },
                                );
                              },
                            ),
                            tileColor: Colors.pink,
                            leading: Icon(
                              Icons.location_on,
                            ),
                            title:
                                Text(googleLocationSelected.formattedAddress),
                          ),
                        ),
                      ),
                    ],
                    /*if (locations.length > 0 && searching) ...[
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: locations.length,
                        itemBuilder: (BuildContext context, int index) {
                          Placemark placeShow = locations[index]['placemark'];
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    20,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                tileColor: Colors.white,
                                leading: Icon(
                                  Icons.location_on,
                                ),
                                title: Text(placeShow.street),
                                onTap: () {
                                  _googleMapControllerontroller.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: LatLng(
                                          locations[index]['location'].latitude,
                                          locations[index]['location']
                                              .longitude,
                                        ),
                                        zoom: 15.0,
                                      ),
                                    ),
                                  );
                                  String markerIdVal = createMarkerId();
                                  final MarkerId markerId =
                                      MarkerId(markerIdVal);

                                  // creating a new MARKER
                                  final Marker marker = Marker(
                                    markerId: markerId,
                                    position: LatLng(
                                      locations[index]['location'].latitude,
                                      locations[index]['location'].longitude,
                                    ),
                                    infoWindow: InfoWindow(
                                        title: markerIdVal, snippet: '*'),
                                  );
                                  setState(() {
                                    _initialPositon = LatLng(
                                        locations[index]['location'].latitude,
                                        locations[index]['location'].longitude);
                                    markers = {};
                                    markers[markerId] = marker;
                                    locationSelected = locations[index];
                                    searching = false;
                                    locations = [];
                                    cName.clear();
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],*/
                    if (googleLocations.length > 0 && searching) ...[
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: googleLocations.length,
                        itemBuilder: (BuildContext context, int index) {
                          //Placemark placeShow = locations[index]['placemark'];
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    20,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                tileColor: Colors.white,
                                leading: Icon(
                                  Icons.location_on,
                                ),
                                title: Text(
                                    googleLocations[index].formattedAddress),
                                onTap: () async {
                                  _googleMapControllerontroller.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: LatLng(
                                          googleLocations[index]
                                              .geometry
                                              .location
                                              .lat,
                                          googleLocations[index]
                                              .geometry
                                              .location
                                              .lng,
                                        ),
                                        zoom: 15.0,
                                      ),
                                    ),
                                  );
                                  String markerIdVal = createMarkerId();
                                  final MarkerId markerId =
                                      MarkerId(markerIdVal);

                                  // creating a new MARKER
                                  final Marker marker = Marker(
                                    markerId: markerId,
                                    position: LatLng(
                                      googleLocations[index]
                                          .geometry
                                          .location
                                          .lat,
                                      googleLocations[index]
                                          .geometry
                                          .location
                                          .lng,
                                    ),
                                    infoWindow: InfoWindow(
                                        title: markerIdVal, snippet: '*'),
                                  );
                                  List<Placemark> placeMark =
                                      await placemarkFromCoordinates(
                                          googleLocations[index]
                                              .geometry
                                              .location
                                              .lat,
                                          googleLocations[index]
                                              .geometry
                                              .location
                                              .lng);
                                  print({
                                    'street': placeMark.first.street,
                                    'name': placeMark.first.name,
                                    'subAdministrativeArea':
                                        placeMark.first.subAdministrativeArea,
                                    'administrativeArea':
                                        placeMark.first.administrativeArea,
                                    'isoCountryCode':
                                        placeMark.first.isoCountryCode,
                                    'country': placeMark.first.country,
                                    'locality': placeMark.first.locality,
                                    'postalCode': placeMark.first.postalCode,
                                    'subLocality': placeMark.first.subLocality,
                                    'thoroughfare':
                                        placeMark.first.thoroughfare,
                                    'subThoroughfare':
                                        placeMark.first.subThoroughfare,
                                  });
                                  setState(() {
                                    _initialPositon = LatLng(
                                        googleLocations[index]
                                            .geometry
                                            .location
                                            .lat,
                                        googleLocations[index]
                                            .geometry
                                            .location
                                            .lng);
                                    markers = {};
                                    markers[markerId] = marker;
                                    googleLocationSelected =
                                        googleLocations[index];
                                    searching = false;
                                    googleLocations = [];
                                    cName.clear();
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    /*if (locations.length == 0 &&
                        !searching &&
                        locationSelected != null) ...[
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        height: 50.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                          color: Colors.white,
                        ),
                        child: TextField(
                          controller: cReference,
                          decoration: InputDecoration(
                            hintText:
                                'Número interior, torre, departamento o referencia (opcional)',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.only(left: 15.0, top: 15.0),
                            suffixIcon: Icon(
                              Icons.house,
                              size: 30.0,
                            ),
                          ),
                        ),
                      ),
                    ],*/
                    if (googleLocations.length == 0 &&
                        !searching &&
                        googleLocationSelected != null) ...[
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        height: 50.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                          color: Colors.white,
                        ),
                        child: TextField(
                          controller: cReference,
                          decoration: InputDecoration(
                            hintText:
                                'Número interior, torre, departamento o referencia (opcional)',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.only(left: 15.0, top: 15.0),
                            suffixIcon: Icon(
                              Icons.house,
                              size: 30.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<googleCoding.GeocodingResult>> searchGoogleAddress(
      {@required String searchValue}) async {
    googleCoding.GeocodingResponse result = await ggcoding.geocoding
        .get(searchValue, null, language: 'es', region: 'mx');
    return result.results;
  }

  Future<List<Map>> searchandNavigate({@required String searchValue}) async {
    googleCoding.GeocodingResponse result = await ggcoding.geocoding
        .get(searchValue, null, language: 'es', region: 'mx');
    //print({'result': result.results[0].formattedAddress});
    List<Location> locationsFound = [];

    try {
      List<Location> newLocations = await locationFromAddress(searchValue);
      locationsFound = newLocations;
    } catch (err) {
      print({
        'err': err,
      });
    }

    List<Map> listMapReturn = [];
    if (locationsFound != null) {
      for (Location locationLoop in locationsFound) {
        /*print({
          'locationLoop.lat': locationLoop.latitude,
          'locationLoop.long': locationLoop.longitude
        });*/
        List<Placemark> listPlacemark = await placemarkFromCoordinates(
            locationLoop.latitude, locationLoop.longitude);
        Placemark placemark = listPlacemark[0];
        /*print({'placemark': placemark, 'placemark.name': placemark.name});*/
        listMapReturn.add({'location': locationLoop, 'placemark': placemark});
      }
    }

    return listMapReturn;
    /*setState(() {
      _initialPositon = LatLng(addresses[0].coordinates.latitude,
          addresses[0].coordinates.longitude);
    });
    _googleMapControllerontroller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(addresses[0].coordinates.latitude,
                addresses[0].coordinates.longitude),
            zoom: 10.0)));*/
  }

  String createMarkerId() {
    Random random = new Random();
    int randomNumber = random.nextInt(1001);
    return DateTime.now().millisecondsSinceEpoch.toString() +
        randomNumber.toString();
  }

  void onMapCreated(controller) {
    setState(() {
      _googleMapControllerontroller = controller;
    });
  }
}

class MyTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;

  MyTextField({
    Key key,
    this.controller,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        8.0,
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration.collapsed(
          hintText: hint,
        ),
        validator: (val) =>
            val.isEmpty ? "Este campo no puede estar vacío" : null,
      ),
    );
  }
}
