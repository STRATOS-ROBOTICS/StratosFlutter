import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/drawer.dart';

class NetworkHelper {
  NetworkHelper(
      {required this.startLng,
      required this.startLat,
      required this.endLng,
      required this.endLat});

  final String url = 'https://api.openrouteservice.org/v2/directions/';
  final String apiKey =
      '5b3ce3597851110001cf62486d5cfc78392446fba599f60bfeffe0dd';
  final String journeyMode =
      'driving-car'; // Change it if you want or make it variable
  final double startLng;
  final double startLat;
  final double endLng;
  final double endLat;

  Future getData() async {
    http.Response response = await http.get(Uri.parse(
        '$url$journeyMode?api_key=$apiKey&start=$startLng,$startLat&end=$endLng,$endLat'));
    print(
        "$url$journeyMode?$apiKey&start=$startLng,$startLat&end=$endLng,$endLat");

    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }
}

class PolylineORSPage extends StatelessWidget {
  static const String route = 'polyline';

  @override
  Widget build(BuildContext context) {
    final List<LatLng> polyPoints = []; // For holding Co-ordinates as LatLng
    final Set<Polyline> polyLines = {}; // For holding instance of Polyline
    final Set<Marker> markers = {}; // For holding instance of Marker
    var data;
    // Dummy Start and Destination Points
    double startLat = 44.837789;
    double startLng = -0.57918;
    double endLat = 41.902784;
    double endLng = 12.496366;

    var points = <LatLng>[];

    var pointsGradient = <LatLng>[
      LatLng(startLat, startLng),
      LatLng(endLat, endLng),
    ];

    void getJsonData() async {
      // Create an instance of Class NetworkHelper which uses http package
      // for requesting data to the server and receiving response as JSON format

      NetworkHelper network = NetworkHelper(
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
      );

      try {
        // getData() returns a json Decoded data
        data = await network.getData();

        // We can reach to our desired JSON data manually as following
        LineString ls =
            LineString(data['features'][0]['geometry']['coordinates']);

        for (int i = 0; i < ls.lineString.length; i++) {
          polyPoints.add(LatLng(ls.lineString[i][1], ls.lineString[i][0]));
        }

        if (polyPoints.length == ls.lineString.length) {
          print(ls);
          //print(polyPoints);
        }
      } catch (e) {
        print(e);
        //print(polyPoints);
      }
    }

    getJsonData();
    print(polyPoints);
    return Scaffold(
      appBar: AppBar(title: Text('Polylines')),
      drawer: buildDrawer(context, PolylineORSPage.route),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text('Polylines'),
            ),
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(51.5, -0.09),
                  zoom: 5.0,
                ),
                layers: [
                  TileLayerOptions(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c']),
                  PolylineLayerOptions(
                    polylines: [
                      Polyline(
                          points: polyPoints,
                          strokeWidth: 4.0,
                          color: Colors.purple),
                    ],
                  ),
                  PolylineLayerOptions(
                    polylines: [
                      Polyline(
                        points: pointsGradient,
                        strokeWidth: 4.0,
                        gradientColors: [
                          Color(0xffE40203),
                          Color(0xffFEED00),
                          Color(0xff007E2D),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//Create a new class to hold the Co-ordinates we've received from the response data

class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}
