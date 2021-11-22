import 'dart:async';

import 'package:apitcheck/place/placeservice.dart';




class PlaceBloc {
  var placeController = StreamController();
  Stream get placeStream => placeController.stream;

  void searchPlace(String keyword) {
    placeController.sink.add("start");
    PlaceService.searchPlace(keyword).then((rs) {
      placeController.sink.add(rs);
    });
  }

  void dispose() {
    placeController.close();
  }
}
