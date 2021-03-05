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
import 'package:geocoder/geocoder.dart' as geocoder;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

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

  List<geocoder.Address> addresses = [];

  bool searching = false;

  bool showSpinner = false;

  geocoder.Address addressSelected;

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
            if (addressSelected == null) {
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
                latitude: addressSelected.coordinates.latitude,
                longitude: addressSelected.coordinates.longitude,
              );
              await EcommerceApp.firestore
                  .collection(EcommerceApp.collectionUser)
                  .doc(
                    EcommerceApp.sharedPreferences.getString(
                      EcommerceApp.userUID,
                    ),
                  )
                  .collection(EcommerceApp.subCollectionAddress)
                  .add({
                'addressLine': addressSelected.addressLine,
                'postalCode': addressSelected.postalCode,
                'countryName': addressSelected.countryName,
                'countryCode': addressSelected.countryCode,
                'adminArea': addressSelected.adminArea,
                'locality': addressSelected.locality,
                'featureName': addressSelected.featureName,
                'subAdminArea': addressSelected.subAdminArea,
                'subLocality': addressSelected.subLocality,
                'thoroughfare': addressSelected.thoroughfare,
                'subThroughFare': addressSelected.subThoroughfare,
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
                addresses = [];
                markers = {};
                addressSelected = null;
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
                          List<geocoder.Address> addLook =
                              await searchandNavigate(
                            searchValue: value,
                          );
                          setState(() {
                            searching = true;
                            addresses = addLook;
                          });
                        },
                      ),
                    ),
                    if (addresses.length > 0 && searching) ...[
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: addresses.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            tileColor: Colors.white,
                            leading: Icon(
                              Icons.location_on,
                            ),
                            title: Text(addresses[index].addressLine),
                            onTap: () {
                              _googleMapControllerontroller.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: LatLng(
                                      addresses[index].coordinates.latitude,
                                      addresses[index].coordinates.longitude,
                                    ),
                                    zoom: 15.0,
                                  ),
                                ),
                              );
                              String markerIdVal = createMarkerId();
                              final MarkerId markerId = MarkerId(markerIdVal);

                              // creating a new MARKER
                              final Marker marker = Marker(
                                markerId: markerId,
                                position: LatLng(
                                  addresses[index].coordinates.latitude,
                                  addresses[index].coordinates.longitude,
                                ),
                                infoWindow: InfoWindow(
                                    title: markerIdVal, snippet: '*'),
                              );
                              setState(() {
                                _initialPositon = LatLng(
                                    addresses[index].coordinates.latitude,
                                    addresses[index].coordinates.longitude);
                                markers = {};
                                markers[markerId] = marker;
                                addressSelected = addresses[index];
                                searching = false;
                                addresses = [];
                                cName.clear();
                              });
                            },
                          );
                        },
                      ),
                    ],
                    if (addresses.length == 0 &&
                        !searching &&
                        addressSelected != null) ...[
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        height: 50.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white),
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
        ), /*SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(
                    8.0,
                  ),
                  child: Text(
                    "Agregar nueva dirección",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
              Stack(
                children: [
                  GoogleMap(
                    compassEnabled: true,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    rotateGesturesEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: _initialPositon != null
                          ? _initialPositon
                          : LatLng(
                              19.4326018,
                              -99.1332049,
                            ),
                      zoom: 14.5,
                    ),
                    onMapCreated: (GoogleMapController controller) =>
                        _googleMapControllerontroller = controller,
                  ),
                ],
              ),
              */ /*Expanded(
                child: GoogleMap(
                  compassEnabled: true,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  rotateGesturesEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: _initialPositon != null
                        ? _initialPositon
                        : LatLng(
                            19.4326018,
                            -99.1332049,
                          ),
                    zoom: 14.5,
                  ),
                  onMapCreated: (GoogleMapController controller) =>
                      _googleMapControllerontroller = controller,
                ),
              ),*/ /*
              */ /*AddressSearchBuilder(
                geoMethods: geoMethods,
                controller: cName,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<Address>> snapshot, {
                  TextEditingController controller,
                  Future<void> Function() searchAddress,
                  Future<Address> Function(Address address) getGeometry,
                }) {
                  return AddressSearchDialog(
                    snapshot: snapshot,
                    controller: controller,
                    searchAddress: searchAddress,
                    getGeometry: getGeometry,
                    onDone: (Address address) {
                      setState(() {
                        _initialPositon = LatLng(
                            address.coords.latitude, address.coords.longitude);
                      });
                    },
                  );
                },
              )*/ /*
              */ /*Form(
                key: formKey,
                child: Column(
                  children: [
                    MyTextField(
                      hint: "Nombre",
                      controller: cName,
                    ),
                    MyTextField(
                      hint: "Teléfono",
                      controller: cPhoneNumber,
                    ),
                    MyTextField(
                      hint: "Número de casa / departamento",
                      controller: cFlatNumber,
                    ),
                    MyTextField(
                      hint: "Ciudad",
                      controller: cCity,
                    ),
                    MyTextField(
                      hint: "Estado",
                      controller: cState,
                    ),
                    MyTextField(
                      hint: "Código Postal",
                      controller: cPinCode,
                    ),
                  ],
                ),
              ),*/ /*
            ],
          ),
        ),*/
      ),
    );
  }

  Future<List<geocoder.Address>> searchandNavigate(
      {@required String searchValue}) async {
    List<geocoder.Address> addressesFound = await geocoder.Geocoder.google(
            LocalMapsApi().googleApiKey,
            language: "esp")
        .findAddressesFromQuery(searchValue);
    return addressesFound;
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
