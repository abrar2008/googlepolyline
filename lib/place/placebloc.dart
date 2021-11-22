import 'dart:async';

import 'package:apitcheck/place/placeservice.dart';



class PlaceBloc {
  var _placeController = StreamController.broadcast();
  Stream get placeStream => _placeController.stream;

  void searchPlace(String keyword) {
    _placeController.sink.add("start");
    PlaceService.searchPlace(keyword).then((rs) {
      _placeController.sink.add(rs);
    });
  }

  void dispose() {
    _placeController.close();
  }
}
