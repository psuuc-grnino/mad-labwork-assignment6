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
  Set<Marker> markers = {
    Marker(markerId: MarkerId('01'), position: LatLng(15, 15)),
    Marker(markerId: MarkerId('02'), position: LatLng(15, 16)),
  };

  void getLocation(LatLng position){
    markers.clear();
    markers.add(Marker(markerId: MarkerId('$position'), position: position));
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 12),
    ),
  );
    setState(() {
      
    });
  }

  void gotoLocation (LatLng position){
    markers.clear();
    markers.add(
      Marker(
        markerId: MarkerId('$position'), 
        position: position,
        infoWindow: InfoWindow(
          title: 'My Location',
        )),
        );
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 12),
    ),
  );
    setState(() {
      
    });
  }

  void gotoCurrentLocation() async {
    if(!await checkLocationServicePermission()){
      return;
    }
    await Geolocator.getPositionStream().listen((geoPosition){
      gotoLocation(LatLng(geoPosition.latitude, geoPosition.longitude));
    });
  }

  @override
  void initState() {
    super.initState();
    gotoCurrentLocation();
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
    //print("Location services is on");
    return true;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (controller){
          mapController = controller;
        },
        markers: markers,
        mapType: MapType.hybrid,
        mapToolbarEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: false,
        initialCameraPosition: CameraPosition(
          target: LatLng(15.97301021197306, 120.57115273080824),
          zoom: 10,
          ),
          onTap: (position){
            print(position.latitude);
            print(position.longitude);
            getLocation(position);
          },
          ),
    );
  }
}