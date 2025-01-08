import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'location_fetch.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? currentAddress;
  Position? _currentPosition;
  double? latitude;
  double? longitude;
  GoogleMapController? mapController;
  Location location = Location();
  Set<Marker> markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      markers.add(const Marker(
        markerId: MarkerId('marker1'),
        position: LatLng(37.7749, -122.4194),
        infoWindow: InfoWindow(title: 'San Francisco'),
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    getPosition();
  }

  void getPosition() async {
    _currentPosition = await LocationHandler.getCurrentPosition();
    currentAddress =
    await LocationHandler.getAddressFromLatLng(_currentPosition!);
  }

  Future<void> _getUserLocation() async {
    final userLocation = await location.getLocation();
    latitude = userLocation.latitude;
    longitude = userLocation.longitude;

    if (_currentPosition != null) {
      currentAddress =
      await LocationHandler.getAddressFromLatLng(_currentPosition!);
    }

    setState(() {
      markers = {
        Marker(
          markerId: const MarkerId('userLocation'),
          position: LatLng(latitude!, longitude!),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      };
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(latitude!, longitude!),
        15,
      ),
    );
  }

  Future<void> _onMapTapped(LatLng tappedPosition) async {
    latitude = tappedPosition.latitude;
    longitude = tappedPosition.longitude;

    currentAddress = await LocationHandler.getAddressFromLatLng(
      Position(
        latitude: tappedPosition.latitude,
        longitude: tappedPosition.longitude,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      ),
    );


    setState(() {
      markers = {
        Marker(
          markerId: const MarkerId('tappedLocation'),
          position: tappedPosition,
          infoWindow: const InfoWindow(title: 'Tapped Location'),
        ),
      };
    });
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(tappedPosition, 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Find any Location',style: TextStyle(fontWeight: FontWeight.bold),
        ),

      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            mapType:MapType.hybrid,
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.7749, -122.4194),
              zoom: 12,
            ),
            markers: markers,
            onTap: _onMapTapped,
          ),
          Positioned(
            bottom: 10,
            right: 60,
            left: 10,
            child: Container(
              height: MediaQuery.of(context).size.height / 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.white.withOpacity(0.9),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LAT : ${latitude ?? "37.7749"}',
                    ),
                    Text(
                      'LNG : ${longitude ?? "122.4194"}',
                    ),
                    Text(
                      'LOCATION : ${currentAddress ?? "San Francisco"}',
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            backgroundColor:
                            MaterialStateProperty.all(Colors.black),
                          ),
                          onPressed: () async {
                            await _getUserLocation();
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Find My Location ',
                                style: TextStyle(color: Colors.white),
                              ),
                              Icon(
                                Icons.location_on_outlined,
                                size: 17,
                                color: Colors.red,
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
