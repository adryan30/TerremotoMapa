import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class QuakeMap extends StatefulWidget {
  QuakeMap({Key key}) : super(key: key);

  _QuakeMapState createState() => _QuakeMapState();
}

Map _data;
List _features;

class _QuakeMapState extends State<QuakeMap> {
  GoogleMapController mapController;

  final LatLng _center = LatLng(-9.755560, -36.663970);

  final Map<String, Marker> _markers = {};
  Future<void> _onMapCreated(GoogleMapController controller) async {
    _data = await getQuake();
    _features = _data["features"];

    setState(() {
      _markers.clear();
      for (int quake = 0; quake < _features.length; quake++) {
        String _quakeID = _features[quake]["id"].toString();
        double _quakeMag =
            double.parse(_features[quake]["properties"]["mag"].toString());
        String _quakePlace = _features[quake]["properties"]["place"];

        var _timeFormat = DateFormat.yMMMMd().add_Hm();
        int _quakeTime = _features[quake]["properties"]["time"];
        String _formattedTime = _timeFormat
            .format(DateTime.fromMillisecondsSinceEpoch(_quakeTime))
            .toString();

        final marker = Marker(
          markerId: MarkerId(_quakeID),
          position: LatLng(_features[quake]["geometry"]["coordinates"][1],
              _features[quake]["geometry"]["coordinates"][0]),
          infoWindow: InfoWindow(
              title:
                  "ID: $_quakeID | Magnitude: ${_quakeMag.toStringAsFixed(2)}",
              snippet: "$_quakePlace",
              onTap: () {
                _showAlertMessage(
                    context, _formattedTime, _quakeMag.toStringAsFixed(2));
              }),
        );
        _markers[_quakeID] = marker;
      }
      print(_markers.keys);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Terremoto V2.0"),
          centerTitle: true,
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 2.0,
          ),
          markers: _markers.values.toSet(),
        ),
      ),
    );
  }
}

Future<Map> getQuake() async {
  String _jsonURL =
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson';

  http.Response response = await http.get(_jsonURL);

  return jsonDecode(response.body);
}

void _showAlertMessage(BuildContext context, String time, String mag) {
  var alert = AlertDialog(
    title: Text("Terremoto - Magnitude $mag"),
    content: Text("Horário: $time"),
    actions: <Widget>[
      FlatButton(
        onPressed: () => Navigator.pop(context),
        child: Text("OK"),
      )
    ],
  );
  showDialog(context: context, builder: (context) => alert);
}
