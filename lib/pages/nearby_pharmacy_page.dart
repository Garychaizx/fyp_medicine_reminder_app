import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class NearbyPharmacyPage extends StatefulWidget {
  @override
  State<NearbyPharmacyPage> createState() => _NearbyPharmacyPageState();
}

class _NearbyPharmacyPageState extends State<NearbyPharmacyPage> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  final String _apiKey = "AIzaSyCi7DcpzzhOS5XL25JDWrLW4F0JEhrKnGY";

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // Get user's current location
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: _currentPosition!,
          infoWindow: InfoWindow(title: "You are here"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 14));

    _getNearbyPharmacies(_currentPosition!);
  }

  // Fetch nearby pharmacies using Google Places API
// Fetch nearby pharmacies using Google Places API
Future<void> _getNearbyPharmacies(LatLng userLocation) async {
  final url =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${userLocation.latitude},${userLocation.longitude}&radius=10000&type=pharmacy&key=$_apiKey";

  print("🔍 Fetching nearby pharmacies from: $url");

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("✅ API Response Status: ${data['status']}");
      print("📊 Total results found: ${data['results']?.length}");

      if (data['status'] == 'OK' && data['results'] != null) {
        setState(() {
          for (var place in data['results']) {
            final location = place['geometry']['location'];
            final LatLng latLng = LatLng(location['lat'], location['lng']);
            final String placeName = place['name'];

            print("📍 Found Pharmacy: $placeName at (${latLng.latitude}, ${latLng.longitude})");

            _markers.add(
              Marker(
                markerId: MarkerId(place['place_id']),
                position: latLng,
                infoWindow: InfoWindow(title: placeName),
              ),
            );
          }
        });

        // If markers were added, print confirmation
        if (_markers.isNotEmpty) {
          print("✅ ${_markers.length} pharmacy markers added to the map.");
        }
      } else {
        print("❌ No pharmacies found in this area.");
      }
    } else {
      print("❌ Error fetching places: ${response.reasonPhrase}");
    }
  } catch (e) {
    print("❌ Exception: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Nearby Pharmacies')),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }
}




// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';

// class NearbyPharmacyPage extends StatefulWidget {
//   const NearbyPharmacyPage({super.key});

//   @override
//   State<NearbyPharmacyPage> createState() => _NearbyPharmacyPageState();
// }

// class _NearbyPharmacyPageState extends State<NearbyPharmacyPage> {
//   final Completer<GoogleMapController> _controller = Completer();
//   LatLng _currentLocation = const LatLng(3.139, 101.6869); // Default: Kuala Lumpur
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);

//       setState(() {
//         _currentLocation = LatLng(position.latitude, position.longitude);
//         _isLoading = false;
//       });

//       final GoogleMapController controller = await _controller.future;
//       controller.animateCamera(CameraUpdate.newLatLng(_currentLocation));
//     } catch (e) {
//       print("Error getting location: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Nearby Pharmacies")),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : GoogleMap(
//               mapType: MapType.normal,
//               initialCameraPosition: CameraPosition(
//                 target: _currentLocation,
//                 zoom: 14.0,
//               ),
//               onMapCreated: (GoogleMapController controller) {
//                 _controller.complete(controller);
//               },
//               markers: {
//                 Marker(
//                   markerId: const MarkerId("current_location"),
//                   position: _currentLocation,
//                   infoWindow: const InfoWindow(title: "You are here"),
//                 ),
//               },
//             ),
//     );
//   }
// }
