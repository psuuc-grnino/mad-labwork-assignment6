import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MapsApp());
}

class MapsApp extends StatelessWidget {
  const MapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  List <LatLng> tappedPoints = [];
  Set<Polyline>polylines = {};

  @override
  void initState() {
    super.initState();
    gotoCurrentLocation();
  }

  void gotoLocation (LatLng position){
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 12),
    ),
  );
  }

  void gotoCurrentLocation() async {
    if(!await checkLocationServicePermission())return;
    Geolocator.getPositionStream().listen((geoPosition){
      gotoLocation(LatLng(geoPosition.latitude, geoPosition.longitude));
    });
  }

  Future<bool> checkLocationServicePermission() async {
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Location service is turned-off. Please enable it in the settings for the app to work."),
        ),
      );
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Permission to use device's location is denied. Please enabled it int the settings."),
          ),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Permission to use device's location is denied. Please enabled it int the settings."),
        ),
      );
      return false;
    }
    return true;
  }

  void handleTap(LatLng position){
    setState(() {
      if(tappedPoints.length==2){
        tappedPoints.clear();
        markers.clear();
        polylines.clear();
      }
      tappedPoints.add(position);
      String label = tappedPoints.length==1?'Start Point':'End Point';
      markers.add(Marker(
        markerId: MarkerId('$position'),
        position: position,
        infoWindow: InfoWindow(title: label),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          tappedPoints.length==1?BitmapDescriptor.hueGreen:BitmapDescriptor.hueRed,
        ),
        ),);
        if(tappedPoints.length==2){
          polylines.add(Polyline(
            polylineId: PolylineId('route'),
            points: tappedPoints,
            color: Colors.blue,
            width: 5,
            ),);
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (controller){
          mapController = controller;
        },
        polylines: polylines,
        markers: markers,
        mapType: MapType.hybrid,
        mapToolbarEnabled: true,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: false,
        initialCameraPosition: CameraPosition(
          target: LatLng(15.97301021197306, 120.57115273080824),
          zoom: 10,
          ),
          onTap: handleTap,
          ),
    );
  }
}