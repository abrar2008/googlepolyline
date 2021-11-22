import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apitcheck/place/placeItem.dart';
import 'package:apitcheck/place/place_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class ControllerMap extends GetxController{
  GoogleMapController? controller;
  Location location = new Location();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? locationData;

  FocusNode nodeFrom = FocusNode();
  FocusNode nodeTo = FocusNode();
  bool checkAutoFocus = false, inputFrom = false, inputTo = false;
  List<Map<String, dynamic>> dataFrom = [];
  List<Map<String, dynamic>> dataTo = [];
  var addressFrom, addressTo;
  var placeBloc = PlaceBloc();
  String? valueFrom, valueTo;
  List<PlaceItemRes>? places;
  List<PlaceItemRes>? places2;
  // point 
  String? point;
  String? duration;
  String? distance;
  final Set<Polyline> polyline = {};


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }
  FromData(index,context){
  /*  dataFrom.clear();*/
    Map<String, dynamic> value = {
      "name": places!
          .elementAt(index)
          .name,
      "address": places!
          .elementAt(index)
          .address,
      "lat":
      places!.elementAt(index).lat,
      "long":
      places!.elementAt(index).lng
    };
    print('dataFrom: ' + value.toString());
    FocusScope.of(context).requestFocus(nodeTo);
    dataFrom.add(value);
    valueFrom = places!.elementAt(index).name.toString();
    addressFrom = TextEditingController(text:valueFrom);
    inputTo = true;
    places!.clear();
    update();
    //new address from

    print(dataFrom);

  }
  ToData(context,index){

    Map<String, dynamic> value = {
      "name": places2!
          .elementAt(index)
          .name,
      "address": places2!
          .elementAt(index)
          .address,
      "lat":
      places2!.elementAt(index).lat,
      "long":
      places2!.elementAt(index).lng
    };
    print('dataTo: ' + value.toString());
      valueTo = places2!
          .elementAt(index)
          .name
          .toString();
      addressTo =
          TextEditingController(
              text: places2!
                  .elementAt(index)
                  .name
                  .toString());
      FocusScope.of(context)
          .requestFocus(
          new FocusNode());
      dataTo.add(value);
      print(dataTo);
    places2!.clear();
    //dataTo.clear();
      update();
      //directions
      // DrawRoute();

  }
  getlocation(){
    location.onLocationChanged.listen((LocationData currentLocation) {
      print(currentLocation.toString());
      controller!.animateCamera(CameraUpdate.newCameraPosition(
          new CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(currentLocation.latitude!.toDouble(), currentLocation.longitude!.toDouble()),
              tilt: 0,
              zoom: 18.00)));
      updateMarkerAndCircle(currentLocation);
      // Use current location
    });
  }
 
 
 //marker
  void updateMarkerAndCircle(LocationData newLocalData) {

    final MarkerId markerIdFrom = MarkerId("My Location");
    final Marker marker = Marker(
        markerId: markerIdFrom,
        //position: LatLng(_fromLocation.latitude, _fromLocation.longitude),
        position: LatLng(newLocalData.latitude!.toDouble(), newLocalData.longitude!.toDouble()),
        infoWindow: InfoWindow(title: "Current"),
        icon:
        // ? BitmapDescriptor.fromAsset("assets/currentmarker.png")
        // : BitmapDescriptor.fromAsset("assets/currentmarker.png"),
        BitmapDescriptor.defaultMarker

    );
      markers[markerIdFrom] = marker;
      update();

    print(markers.toString());

  }
//setpolylines
  setPolylines(LatLng A, LatLng B) async {
    //flag = false;
    String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${A.latitude},${A.longitude}&destination=${B.latitude},${B.longitude}&key=AIzaSyBR7rrSUi4o118-vGLhDI_f6buJOnZr900";
    http.Response response = await http.get(Uri.parse(url));
    Map values = jsonDecode(response.body);
    point = values["routes"][0]["overview_polyline"]["points"];
    distance = values["routes"][0]["legs"][0]["distance"]["text"];
    duration = values["routes"][0]["legs"][0]["duration"]["text"];
    //secondsD = values["routes"][0]["legs"][0]["duration"]["value"];
      polyline.add(Polyline(
          polylineId: PolylineId('route1'),
          visible: true,
          points: convertToLatLng(decodePoly(point.toString())),
          width: 6,
          color: Color(0xff2a2e36),
          startCap: Cap.roundCap,
          endCap: Cap.buttCap));
      update();
     addMakers(A,B);


    return values["routes"][0]["overview_polyline"]["points"];
  }
  
  //addmarker
  addMakers(var a,var b) {
    final MarkerId markerIdFrom = MarkerId("from_address");
    final MarkerId markerIdTo = MarkerId("to_address");
    // var _dataFrom = dataFrom;
    var _dataTo = dataTo;

    final Marker marker = Marker(
      markerId: markerIdFrom,
      position: LatLng(a.latitude, a.longitude),
      // position: LatLng(from_l.latitude, from_l.longitude),
      infoWindow: InfoWindow(title: "Current"),
      icon: BitmapDescriptor.defaultMarker,
      onTap: () {
        // _onMarkerTapped(markerId);
      },
    );

    final Marker markerTo = Marker(
        markerId: markerIdTo,
        //position: LatLng(to_l.latitude, to_l.longitude),
        position: LatLng(b.latitude, b.longitude),
        infoWindow: InfoWindow(
            title: "dropout" ),
        icon: BitmapDescriptor.defaultMarker);

      markers[markerIdFrom] = marker;
      markers[markerIdTo] = markerTo;
    controller!.animateCamera(CameraUpdate.newCameraPosition(
        new CameraPosition(
            bearing: 192.8334901395799,
            target: LatLng(b.latitude!.toDouble(), b.longitude!.toDouble()),
            tilt: 0,
            zoom: 18.00)));
      update();
  }



  static List<LatLng> convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  static List decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = [];
    int index = 0;
    int len = poly.length;
    int c = 0;
    // repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negative then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    /*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }


}